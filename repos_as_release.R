utils::install.packages("pvm", repos = "https://wush978.github.io/R", type = "source")
R.date <- pvm::R.release.dates[sprintf('%s.%s', R.version['major'], R.version['minor'])]
if (is.na(R.date)) {
  repos <- "http://cran.r-project.org"
} else {
  repos <- sprintf('https://cran.microsoft.com/snapshot/%s', R.date + 7)
}
. <- sprintf("options(repos = c(CRAN = '%s'))\n\n", repos)
cat(., file = "~/.Rprofile")
