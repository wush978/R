repos <- "http://wush978.github.io/R"
local({
  check_package <- function(pkg) {
    if (!suppressWarnings(suppressMessages(require(pkg, character.only = TRUE)))) {
      install.packages(pkg, repos = repos)
    }
  }
  lapply(c("rappdirs", "bitops", "curl", "httpuv"), check_package)
  utils::install.packages("swirl", repos = repos)
})
library(swirl)
library(curl)
library(methods)
try(uninstall_course("DataScienceAndR"), silent=TRUE)
install_course_url(sprintf("%s/course/DataScienceAndR.zip", repos))
