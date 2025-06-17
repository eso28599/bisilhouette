#' Check if there are at least two unique row clusters.
#'
#' @param row_clustering binary matrix indicating row clustering,
#'                        shape(N, k).
#'
#' @noRd
#' @return TRUE if there are not at least three unique row clusters, bool.
check_unique <- function(row_clustering) {
  if (sum(colSums(row_clustering) != 0) < 3) {
    return(TRUE)
  }
  row_clustering <- row_clustering[, colSums(row_clustering) != 0]
  n_clusts <- ncol(row_clustering)
  equal <- diag(n_clusts)
  for (i in 1:(n_clusts - 1)) {
    for (j in (i + 1):n_clusts) {
      check <- all(row_clustering[, i] == row_clustering[, j])
      equal[i, j] <- check
      equal[j, i] <- check
    }
  }
  return(nrow(unique(equal)) < 3)
}

#' Calculate the a and b values for the kth bicluster.
#'
#' @param distances distance (over the columns in question) matrix,
#'                   shape (N, N).
#' @param indices binary vector indicating row cluster, shape (N, ).
#' @param k current row cluster index, int.
#' @param n_clusts_row number of row clusters, int.
#' @param clust_two binary matrix indicating row clustering,
#'                   shape(N, n_clusts_row).
#'
#' @noRd
#' @return bisil: bisilhouette score, float.
calculate_scores <- function(distances, indices, k,
                             n_clusts_row, row_clustering) {
  b_vec <- c()
  # calculate a values
  if (sum(indices) == 1) {
    # if only one element belongs to row cluster, set a=0
    a_vals <- 0
  } else {
    a_vals <- apply(
      distances[indices, indices],
      1, function(x) sum(x) / (length(x) - 1)
    )
  }
  # calculate b values
  # indices for other clusters
  other <- (1:n_clusts_row)[-k]
  b_vals <- vector("list", length = (n_clusts_row - 1))
  t <- 1
  # consider every other cluster
  for (l in other) {
    oth_ind <- row_clustering[, l] == 1
    if ((sum(oth_ind) == 0) || all(oth_ind == indices)) {
      # if the other cluster is empty,
      # or if the other cluster is the same as the current cluster
      # set b=Inf
      b_val <- rep(Inf, sum(indices))
    } else if ((sum(oth_ind) == 1) || (sum(indices) == 1)) {
      # if either cluster has only one element
      # need to calculate mean differently
      b_val <- mean(distances[indices, oth_ind])
    } else {
      b_val <- rowMeans(distances[indices, oth_ind])
    }
    b_vec <- c(b_vec, mean(b_val))
    b_vals[[t]] <- b_val
    t <- t + 1
  }
  b_vals <- b_vals[[which.min(b_vec)]]
  if (all(b_vals == Inf) || (all(b_vals == 0) && all(a_vals == 0))) {
    # if all b values are Inf, set score to 0
    # this corresponds to all other clusters being empty
    # or the same as the current cluster
    # if all a and b values are 0, set score to 0
    # this corresponds to the current cluster being empty
    bis_vals <- 0
    bisil_score <- 0
  } else {
    bis_vals <- (b_vals - a_vals) / apply(rbind(b_vals, a_vals), 2, max)
    bisil_score <- mean(bis_vals)
  }
  return(list("bisil" = bisil_score, "bis_vals" = bis_vals))
}

#' @title Calculate the bisilhouette score without repeats
#'
#' @param data data matrix, shape (N, p).
#' @param row_clustering binary matrix indicating row clustering,
#'                        shape(N, K).
#' @param col_clustering binary matrix indicating column clustering,
#'                        shape(p, K).
#' @param method distance metric to use, str. Default is "euclidean".
#' @noRd
#'
#' @return list containing;
#'             - bisil: bisilhouette score, float.
#'             - vals: individual sample scores, shape (N, ).
#'             - repeat: if TRUE, a random row cluster has been added
#'                      and repeats are needed, bool.
calculate_bis <- function(data, row_clustering,
                          col_clustering,
                          method = "euclidean") {
  n_clusts <- ncol(row_clustering)
  bisil_score <- rep(0, length = n_clusts)

  # ensure there are at least three unique row clusters
  while (check_unique(row_clustering)) {
    row_clustering <- cbind(
      row_clustering,
      stats::rbinom(nrow(row_clustering), 1, 0.1)
    )
  }
  n_clusts_row <- ncol(row_clustering)
  rep <- ifelse(n_clusts_row == n_clusts, FALSE, TRUE)

  # calculate score for each cluster
  bis_vals <- vector("list", length = n_clusts)
  for (k in 1:n_clusts) {
    indices <- row_clustering[, k] == 1
    # if row or col cluster empty, set score to 0
    if ((sum(indices) == 0) || (sum(col_clustering[, k] == 1) == 0)) {
      bisil_score[k] <- bisil_score[k] + 0
    } else {
      # subset data using column cluster k
      new_data <- data[, (col_clustering[, k] == 1)]
      if (method == "cosine") {
        distances <- 1 - lsa::cosine(t(as.matrix(new_data)))
      } else {
        distances <- as.matrix(stats::dist(new_data, method))
      }
      # calculate scores
      scores <- calculate_scores(
        distances, indices, k,
        n_clusts_row, row_clustering
      )
      bisil_score[k] <- bisil_score[k] + scores$bisil
      bis_vals[[k]] <- scores$bis_vals
    }
  }
  # calculate overall score
  bisil <- ifelse(sum(bisil_score != 0) <= 1,
    sum(bisil_score),
    sum(bisil_score) / (sum(bisil_score != 0))
  )
  return(list("bisil" = bisil, "vals" = bis_vals, "repeat" = rep))
}

#' @title Calculate the bisilhouette score.
#'
#' @param data data matrix, shape (N, p).
#' @param row_clustering binary matrix indicating row clustering,
#'                       shape(N, k).
#' @param col_clustering binary matrix indicating column clustering,
#'                       shape(p, k).
#' @param method distance metric to use, str. Default is "euclidean".
#' @param seed seed if seed should be set for random number generation, int.
#'             Default is FALSE.
#' @param n_reps number of repetitions if random biclusters added, int.
#'               Default is 10.
#'
#' @examples
#' data <- matrix(stats::rnorm(50), nrow = 10)
#' row_clustering <- cbind(
#'   stats::rbinom(10, 1, 0.5),
#'   stats::rbinom(10, 1, 0.5),
#'   stats::rbinom(10, 1, 0.5)
#' )
#' col_clustering <- cbind(
#'   stats::rbinom(5, 1, 0.5),
#'   stats::rbinom(5, 1, 0.5),
#'   stats::rbinom(5, 1, 0.5)
#' )
#' bisilhouette(data, row_clustering, col_clustering)
#' @export
#' @return list containing;
#'              - bisil: bisilhouette score, float.
#'              - vals: individual sample scores, shape (N, ).
bisilhouette <- function(data, row_clustering, col_clustering,
                         method = "euclidean", seed = TRUE, n_reps = 10) {
  # Error handling
  if (any(dim(data) != c(nrow(row_clustering), nrow(col_clustering)))) {
    stop("Dimensions of data and clustering matrices do not match.")
  }
  if (ncol(row_clustering) != ncol(col_clustering)) {
    stop("Number of row and column clusters do not match.")
  }
  # if no biclusters are present, return 0
  if (sum(row_clustering) == 0 || sum(col_clustering) == 0) {
    return(list("bisil" = 0, "vals" = rep(0, nrow(row_clustering))))
  }
  if (!seed) set.seed(seed)
  data <- scale(data)
  # initial results
  results <- calculate_bis(data, row_clustering, col_clustering, method)
  bisil <- results$bisil
  vals <- results$vals
  # repeat if necessary
  if (results$rep) {
    for (i in 1:(n_reps - 1)) {
      res_rep <- calculate_bis(
        data, row_clustering,
        col_clustering, method
      )
      bisil <- bisil + res_rep$bisil
      vals <- lapply(
        seq_along(vals),
        function(k) vals[[k]] + res_rep$vals[[k]]
      )
    }
    bisil <- bisil / n_reps
    vals <- lapply(vals, function(x) x / 10)
  }
  return(list("bisil" = bisil, "vals" = vals))
}
