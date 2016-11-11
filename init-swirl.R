local({
  check_package <- function(pkg) {
    if (!suppressWarnings(suppressMessages(require(pkg, character.only = TRUE)))) {
      install.packages(pkg, repos = "http://wush978.github.io/R")
    }
  }
  lapply(c("rappdirs", "bitops", "curl"), check_package)
  utils::install.packages("swirl", repos = "http://wush978.github.io/R")
})
library(swirl)
library(curl)
library(methods)
try(uninstall_course("DataScienceAndR"), silent=TRUE)
install_course_github("wush978", "DataScienceAndR", "course")
