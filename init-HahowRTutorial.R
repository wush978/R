if (package_version(R.version) < package_version("3.2.3")) local({
  msg <- sprintf("The version of R (%s) is not compatible with the course content. Please visit https://mran.revolutionanalytics.com/snapshot/2017-04-01/ to upgrade your R.", package_version(R.version))
  Encoding(msg) <- "UTF-8"
  stop(msg)
})


local({
  repos <- "https://wush978.github.io/R"
  if (!suppressWarnings(require(remotes))) install.packages("remotes", repos = "http://cran.csie.ntu.edu.tw")
  if (!suppressWarnings(require(pvm))) utils::install.packages("pvm", repos = "https://wush978.github.io/R", type = "source")
  pvm::import.packages(sprintf("https://raw.githubusercontent.com/wush978/pvm-list/master/dsr-%s.yml", package_version(R.version)))
  pkgs.repos <- available.packages(contrib.url(repos, "source"))
  pkgs.installed <- installed.packages()
  check.result <- try(pkgs.repos["swirl", "Version"] == pkgs.installed["swirl", "Version"], silent = TRUE)
  if (!isTRUE(check.result)) {
    utils::install.packages("swirl", repos = repos)
  }
  library(swirl)
  library(curl)
  library(methods)
  try(uninstall_course("HahowRTutorial"), silent=TRUE)
  install_course_url(sprintf("%s/course/HahowRTutorial.zip", repos))
})
