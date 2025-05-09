% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/visualisations.r
\name{bisil_plot}
\alias{bisil_plot}
\title{Bisilhouette plot}
\usage{
bisil_plot(data, row_clusters, col_clusters, filename = NULL)
}
\arguments{
\item{data}{A matrix of data (n x p).}

\item{row_clusters}{A matrix of row cluster indices (n x k).}

\item{col_clusters}{A matrix of column cluster indices (p x k).}

\item{filename}{The filename to save the plot,
if NULL the plot is not saved. Default is NULL.}
}
\value{
A ggplot object
}
\description{
Plot the bisilhouette score for each sample.
}
\examples{
data <- matrix(stats::rnorm(50), nrow = 10)
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
bisil_plot(data, row_clustering, col_clustering)
}
