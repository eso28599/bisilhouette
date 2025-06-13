data <- matrix(stats::rnorm(50), nrow = 10)
# 3 unique biclusters
row_clustering <- cbind(
  stats::rbinom(10, 1, 0.5),
  stats::rbinom(10, 1, 0.5),
  stats::rbinom(10, 1, 0.5)
)
col_clustering <- cbind(
  stats::rbinom(5, 1, 0.5),
  stats::rbinom(5, 1, 0.5),
  stats::rbinom(5, 1, 0.5)
)
bisil <- bisilhouette(data, row_clustering, col_clustering)
bisil_plot(data, row_clustering, col_clustering)
bisil_cos <- bisilhouette(
  data, row_clustering, col_clustering,
  method = "cosine"
)

# 3 biclusters, 2 unique rows
rep_row <- stats::rbinom(10, 1, 0.5)
row_clustering <- cbind(
  rep_row,
  rep_row,
  stats::rbinom(10, 1, 0.5)
)
col_clustering <- cbind(
  stats::rbinom(5, 1, 0.5),
  stats::rbinom(5, 1, 0.5),
  stats::rbinom(5, 1, 0.5)
)
while (sum(col_clustering) == 0) {
  col_clustering <- cbind(
    stats::rbinom(5, 1, 0.5),
    stats::rbinom(5, 1, 0.5),
    stats::rbinom(5, 1, 0.5)
  )
}
bisil <- bisilhouette(data, row_clustering, col_clustering)
bisil_plot(data, row_clustering, col_clustering)

# 2 unique biclusters
row_clustering <- cbind(
  stats::rbinom(10, 1, 0.5),
  stats::rbinom(10, 1, 0.5)
)
col_clustering <- cbind(
  stats::rbinom(5, 1, 0.5),
  stats::rbinom(5, 1, 0.5)
)
while (sum(col_clustering) == 0) {
  col_clustering <- cbind(
    stats::rbinom(5, 1, 0.5),
    stats::rbinom(5, 1, 0.5)
  )
}
bisil <- bisilhouette(data, row_clustering, col_clustering)
bisil_plot(data, row_clustering, col_clustering)

# 1 bicluster
row_clustering <- cbind(
  stats::rbinom(10, 1, 0.5)
)
col_clustering <- cbind(
  stats::rbinom(5, 1, 0.5)
)
while (sum(col_clustering) == 0) {
  col_clustering <- cbind(
    stats::rbinom(5, 1, 0.5)
  )
}
bisil <- bisilhouette(data, row_clustering, col_clustering)
bisil_plot(data, row_clustering, col_clustering)
