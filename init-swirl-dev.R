local({
  repos <- "https://wush978.github.io/R"
  if (!require(remotes)) install.packages("remotes", repos = "http://cran.csie.ntu.edu.tw")
  if (!require(pvm)) remotes::install_github("wush978/pvm@dcbcb71f529e805493058732b70505759a8f0501")
  pvm::import.packages("https://raw.githubusercontent.com/wush978/pvm-list/master/dsr.yml")
  utils::install.packages("swirl", repos = repos)
  library(swirl)
  library(curl)
  library(methods)
  try(uninstall_course("DataScienceAndR"), silent=TRUE)
  install_course_url(sprintf("%s/course/DataScienceAndR.zip", repos))
})
