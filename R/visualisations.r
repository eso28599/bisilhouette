# ---------------------------------
# functions for visualisation
# ---------------------------------

#' @title Data frame plot
#' @description Function to create a data frame for
#'              plotting from bisilhouette coefficients.
#' @param values A list of bisilhouette scores.
#'
#' @noRd
#' @return A data frame for plotting.
df_plot <- function(values) {
  x <- c()
  y <- c()
  cluster <- c()
  for (i in seq_along(values)) {
    x <- c(x, seq_along(values[[i]]))
    y <- c(y, sort(values[[i]]))
    cluster <- c(cluster, rep(i, length(values[[i]])))
  }
  x <- seq_along(x)
  return(data.frame(x = x, y = y, clust = cluster))
}

#' @title X breaks
#' @description Function to determine the breaks for the x-axis.
#' @param df A data frame of bisilhouette scores.
#'
#' @noRd
#' @return A vector of breaks for the x-axis.
x_breaks <- function(df) {
  n_c <- length(unique(df$clust))
  ticks <- c()
  num <- c(0)
  for (i in 1:n_c) {
    num <- c(num, sum(df$clust == i))
    ticks <- c(ticks, floor(sum(df$clust == i) / 2))
  }
  return(cumsum(num[1:(n_c)]) + ticks)
}

#' @title Break function
#' @description Function to determine the breaks for the y-axis.
#' @param lower A vector of the lower values of the bisilhouette scores.
#'
#' @noRd
#' @return A vector of breaks for the y-axis.
y_breaks <- function(lower) {
  if (min(lower) < 0) {
    return(seq(-1, 1, 0.2)[seq(-1, 1, 0.2) > (min(lower) - 0.2)])
  } else {
    return(seq(0, 1, 0.2))
  }
}

#' @title Bisilhouette plot
#' @description Plot the bisilhouette score for each sample.
#' @param data A matrix of data (n x p).
#' @param row_clusters A matrix of row cluster indices (n x k).
#' @param col_clusters A matrix of column cluster indices (p x k).
#' @param filename The filename to save the plot,
#'                 if NULL the plot is not saved. Default is NULL.
#' @examples
#' data <- matrix(rnorm(100), nrow = 10)
#' row_clusters <- matrix(rbinom(10, 1, 0.5), nrow = 10)
#' col_clusters <- matrix(rbinom(10, 1, 0.5), nrow = 10)
#' bisil_plot(data, row_clusters, col_clusters)
#' @return A ggplot object
#' @export bisil_plot
bisil_plot <- function(data, row_clusters, col_clusters, filename = NULL) {
  # remove empty biclusters
  if (sum(colSums(col_clusters) == 0) > 0) {
    row_clusters <- row_clusters[, colSums(col_clusters) != 0]
    col_clusters <- col_clusters[, colSums(col_clusters) != 0]
    print("Empty biclusters removed.")
  }
  # error check
  if (ncol(col_clusters) == 0) {
    stop("No biclusters found.")
  }
  #
  scores <- calculate_bis(data, row_clusters, col_clusters)
  df <- df_plot(scores$vals)
  breaks_y <- y_breaks(df$y)
  breaks_x <- x_breaks(df)
  bis_val <- scores$sil
  p <- ggplot2::ggplot(df) +
    ggplot2::geom_col(
      ggplot2::aes(
        x = x, y = y, group = clust, color = clust,
        fill = clust
      ),
      width = 1, position = ggplot2::position_dodge()
    ) +
    ggplot2::scale_y_continuous(breaks = breaks_y, limits = c(
      min(breaks_y),
      max(breaks_y)
    )) +
    ggplot2::scale_x_continuous(
      breaks = breaks_x,
      labels = seq_len(ncol(row_clusters))
    ) +
    ggplot2::scale_color_viridis_c() +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::ylab("Bisilhouette score") +
    ggplot2::xlab("Bicluster") +
    ggplot2::geom_hline(
      yintercept = bis_val,
      linetype = "dashed", color = "black"
    ) +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position = "none", axis.text = ggplot2::element_text(size = 12),
      axis.title = ggplot2::element_text(size = 14),
      axis.ticks = ggplot2::element_line(linewidth = 0.4),
      axis.line = ggplot2::element_line(size = 0.4)
    )

  if (!is.null(filename)) {
    ggplot2::ggsave(filename, p)
  }
  return(p)
}
