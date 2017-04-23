if (package_version(R.version) > package_version("3.3.3")) local({
  msg <- sprintf("你的R的版本(%s)剛上線，翻轉教室需要針對這個版本做調校。請先到 https://mran.revolutionanalytics.com/snapshot/2017-04-01/ 安裝3.3.3版本的R", package_version(R.version))
  Encoding(msg) <- "UTF-8"
  stop(msg)
})

if (package_version(R.version) < package_version("3.2.3")) local({
  msg <- sprintf("The version of R (%s) is not compatible with the course content. Please visit https://mran.revolutionanalytics.com/snapshot/2017-04-01/ to upgrade your R.", package_version(R.version))
  Encoding(msg) <- "UTF-8"
  stop(msg)
})


local({
  repos <- "https://wush978.github.io/R"
  if (!require(remotes)) install.packages("remotes", repos = "http://cran.csie.ntu.edu.tw")
  if (!require(pvm)) utils::install.packages("pvm", repos = "https://wush978.github.io/R", type = "source")
  pvm::import.packages("https://raw.githubusercontent.com/wush978/pvm-list/master/dsr.yml")
  utils::install.packages("swirl", repos = repos)
  library(swirl)
  library(curl)
  library(methods)
  try(uninstall_course("DataScienceAndR"), silent=TRUE)
  install_course_url(sprintf("%s/course/DataScienceAndR.zip", repos))
})
