Welcome to the Github page for the `bisilhouette` package: an intrinsic biclustering measure.

# Installation 
To install this package in `r` you can do any of the following
```{r}
devtools::install_packages(bisilhouette) # requires devtools package to be installed
```

# Description 
The bisilhouette score is an extension of the silhouette score to the bicluster case. It is a measure of the quality of a biclustering, which like the silhouette score takes into account the compactness and separation of the biclusters.

This page details the use of the functions within the `bisilhouette` function, for more details on the definiton of the score, please see the ..... (add link?)

# Examples 
We ilustrate the use of the `bisilhouette` function which takes as input the $N\times p$ `data` matrix, and bicluster membership informtation, either via the input `biclusters` or via 

This makes `bisilhouette` compatible with the output of functions from the popular `biclust`package.
```{r}
data <- matrix(stats::rnorm(100), nrow = 10)
row_clustering <- cbind(
  stats::rbinom(100, 1, 0.5),
  stats::rbinom(100, 1, 0.5),
  stats::rbinom(100, 1, 0.5)
)
col_clustering <- cbind(
  stats::rbinom(100, 1, 0.5),
  stats::rbinom(100, 1, 0.5),
  stats::rbinom(100, 1, 0.5)
)
bisil <- bisilhouette(data, row_clustering, col_clustering)
bisil$bisil # the bisilhouette score
bisil$vals # a list containing vectors of the bisilhouette coefficients for each bicluster 
```

## Visualisation
The function `plot_bisil` produces a visualisation of the bisilhouette scores.  The individual bisilhouette coefficients for each of the rows is shown along the x axis, with rows grouped into the assigned biclusters (denoted by different colours). The mean coefficient is represented by the dashed line. 
```{r}
bisil_plot(data, row_clustering, col_clustering)
```

### Examples
1. Bisilhouette plot for synthetic data with 3 views and 5 biclusters using the true column clusters and 3 out of 5 of the correct row clusters with the remaining row clusters having been reassigned randomly.  

[Synthetic data](vignettes/shuffled_bisil_plot.pdf)

2. Bisilhouette plot for biclusters obtained from a single cell transcriptomic dataset. 

[Synthetic data](vignettes/sc_bisil_plot.pdf)

Note that the axes ranges are different as the bisilhouette score is not comporable across distinct datasets.


## Input
The biclusters are represented either by 


The binary $N\times k$ matrix `row_clustering` which contains row membership information of the $k$ biclusters. Similarly, the binary $p\times k$ matrix `col_clustering` contains column membership information regarding the $k$ biclusters.

### row_clustering/col_clustering
For data with $100$ samples and $10$ features and $3$ biclusters, possible input structures are detailed below.

```{r}
# (a)
row_clustering <- cbind(
  stats::rbinom(100, 1, 0.5),
  stats::rbinom(100, 1, 0.5),
  stats::rbinom(100, 1, 0.5)
)
col_clustering <- cbind(
  stats::rbinom(10, 1, 0.5),
  stats::rbinom(10, 1, 0.5),
  stats::rbinom(10, 1, 0.5)
)
```

### biclusters

Alternatively, `biclusters` can be provided which contains either:

(i) A list, the $i^{th}$ element of which is a list of vectors of the row and columns associated with the $i^{th}$ bicluster.

```{r}
biclusters <- list(list(stats::rbinom(100, 1, 0.5), stats::rbinom(10, 1, 0.5)),
                   list(stats::rbinom(100, 1, 0.5), stats::rbinom(10, 1, 0.5)),
                   list(stats::rbinom(100, 1, 0.5), stats::rbinom(10, 1, 0.5))
)
```

(ii) A list, the $i^{th}$ element of which is a list of vectors of the row and columns indices associated with the $i^{th}$ bicluster.

```{r}
biclusters <- list(list(random(100, ), stats::rbinom(10, 1, 0.5)),
                   list(stats::rbinom(100, 1, 0.5), stats::rbinom(10, 1, 0.5)),
                   list(stats::rbinom(100, 1, 0.5), stats::rbinom(10, 1, 0.5))
)
```

If you use this score in your work please cite: Orme, Ella S.C., Theodoulos Rodosthenous, and Marina Evangelou. "Multi-view biclustering via non-negative matrix tri-factorisation." arXiv e-prints (2025): arXiv-2502.
