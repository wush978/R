if (package_version(R.version) < package_version("3.2.3")) local({
  msg <- sprintf("The version of R (%s) is not compatible with the course content. Please visit https://mran.revolutionanalytics.com/snapshot/2017-04-01/ to upgrade your R.", package_version(R.version))
  Encoding(msg) <- "UTF-8"
  stop(msg)
})


local({
  repos <- "https://wush978.github.io/R"
  if (!suppressWarnings(require(remotes))) install.packages("remotes", repos = "http://cran.csie.ntu.edu.tw")
  if (!require(remotes)) {
    browseURL("https://github.com/wush978/DataScienceAndR/wiki/Windows%E4%B8%AD%E6%96%87%E4%BD%BF%E7%94%A8%E8%80%85%E8%88%87Rstudio%E7%9A%84%E7%92%B0%E5%A2%83%E8%AE%8A%E6%95%B8%E8%AA%BF%E6%A0%A1")
    stop("Filed to install package: \"remotes\". The possible reason is that the path contains chinese character. Please check https://github.com/wush978/DataScienceAndR/wiki/Windows%E4%B8%AD%E6%96%87%E4%BD%BF%E7%94%A8%E8%80%85%E8%88%87Rstudio%E7%9A%84%E7%92%B0%E5%A2%83%E8%AE%8A%E6%95%B8%E8%AA%BF%E6%A0%A1 for resolving the issue.")
  }
  if (!suppressWarnings(require(pvm))) utils::install.packages("pvm", repos = "https://wush978.github.io/R", type = "source")
  if (!require(pvm)) {
    browseURL("https://github.com/wush978/DataScienceAndR/wiki/Windows%E4%B8%AD%E6%96%87%E4%BD%BF%E7%94%A8%E8%80%85%E8%88%87Rstudio%E7%9A%84%E7%92%B0%E5%A2%83%E8%AE%8A%E6%95%B8%E8%AA%BF%E6%A0%A1")
    stop("Filed to install package: \"remotes\". The possible reason is that the path contains chinese character. Please check https://github.com/wush978/DataScienceAndR/wiki/Windows%E4%B8%AD%E6%96%87%E4%BD%BF%E7%94%A8%E8%80%85%E8%88%87Rstudio%E7%9A%84%E7%92%B0%E5%A2%83%E8%AE%8A%E6%95%B8%E8%AA%BF%E6%A0%A1 for resolving the issue.")
  }
  pvm::metamran.update()
  pvm.path <- sprintf("https://raw.githubusercontent.com/wush978/pvm-list/master/dsr-%s.yml", package_version(R.version))
  tmp.path <- tempfile(fileext = ".yml")
  .warn <- getOption("warn")
  # use warning message to check if the version of R is supported or not
  tryCatch({
    options(warn = 2)
    download.file(pvm.path, tmp.path)
  }, error = function(e) {
    print(conditionMessage(e))
    if (grepl("404", conditionMessage(e))) {
      browseURL("https://github.com/wush978/DataScienceAndR/wiki/%E4%B8%8D%E6%94%AF%E6%8F%B4%E7%9A%84%E7%89%88%E6%9C%AC")
      message("The version of your R is not supported. Please download R-3.3.3 from https://mran.revolutionanalytics.com/snapshot/2017-04-01/ ")
    }
    stop(conditionMessage(e))
  }, finally = {
    options(warn = .warn)
  })
  pvm::import.packages(tmp.path, Ncpus = 2)
  utils::install.packages("swirl", repos = repos)
  library(swirl)
  library(curl)
  library(methods)
  try(uninstall_course("DataScienceAndR"), silent=TRUE)
  install_course_url(sprintf("%s/course/DataScienceAndR.zip", repos))
})
