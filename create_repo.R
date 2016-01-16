
sapply(
  c("devtools", "miniCRAN"), 
  function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg)
      library(pkg, character.only = TRUE)
    }
  }
)

target.github.pkgs.full <- c("wush978/swirl", "wush978/slidify", "wush978/slidifyLibraries")
target.github.pkgs <- basename(target.github.pkgs.full)
target.github.pkgs.deps <- lapply(
  target.github.pkgs.full,
  function(path) {
    url <- sprintf("https://raw.githubusercontent.com/%s/master/DESCRIPTION", path)
    tmp.path <- tempfile()
    download.file(url, tmp.path)
    dcf <- read.dcf(tmp.path)
    fields <- c("Depends", "Imports", "Suggests")
    retval <- lapply(fields[fields %in% colnames(dcf)], function(field) {
      tools:::.extract_dependency_package_names(dcf[,field])
    })
    unlist(retval, use.names = FALSE)
  }
)
target.github.pkgs.deps <- unlist(target.github.pkgs.deps)
target.cran.pkgs <- miniCRAN::pkgDep(target.github.pkgs.deps)
target.cran.pkgs <- setdiff(target.cran.pkgs, target.github.pkgs)

types <- c("source", "mac.binary", "mac.binary.mavericks", "win.binary")
R.version <- c("3.2")
pkgAvail <- function(...) {
  tryCatch(miniCRAN::pkgAvail(...), error = function(e) NULL)
}
for(type in types) {
  pkgs.existed <- pkgAvail(".", type = type, Rversion = R.version)
  pkgs.target <- setdiff(target.cran.pkgs, pkgs.existed)
  makeRepo(pkgs.target, path = ".", type = type, Rversion = R.version, quiet = TRUE)
}

get_path <- function(type, Rversion) {
  switch(
    type,
    "source" = "src/contrib",
    "mac.binary" = sprintf("bin/macosx/contrib/%s", Rversion),
    "mac.binary.mavericks" = sprintf("bin/macosx/mavericks/contrib/%s", Rversion),
    "win.binary" = sprintf("bin/windows/contrib/%s", Rversion),
    stop("Unknown type")
  )
}

get_compressor <- function(type) {
  tgz <- function(tarfile, files) {
    tar(tarfile, files, compression = "gzip")
  }
  switch(
    type,
    "source" = tgz,
    "mac.binary" = tgz,
    "mac.binary.mavericks" = tgz,
    "win.binary" = zip,
    stop("Unknown type")
  )
}

get_ext <- function(type) {
  switch(
    type,
    "source" = ".tar.gz",
    "mac.binary" = ".tgz",
    "mac.binary.mavericks" = ".tgz",
    "win.binary" = ".zip",
    stop("Unknown type")
  )
}

lapply(
  target.github.pkgs.full, 
  function (path) {
    name <- basename(path)
    url <- sprintf("https://github.com/%s/archive/master.zip", path)
    tmp.path <- tempfile(fileext = ".zip")
    download.file(url, tmp.path)
    tmp.dir <- tempfile()
    dir.create(tmp.dir)
    unzip(tmp.path, exdir = tmp.dir)
    pkg.src <-  devtools::build(file.path(tmp.dir, sprintf("%s-master", name)))
    pkg.dir <- tempfile()
    dir.create(pkg.dir)
    untar(pkg.src, exdir = pkg.dir)
    stopifnot(!file.exists(file.path(pkg.dir, name, "src"))) # no compilation of the package
    version <- read.dcf(file.path(pkg.dir, name, "DESCRIPTION"))[1,"Version"]
    current.wd <- getwd()
    for(type in types) {
      dest <- sprintf("%s/%s/%s_%s%s", current.wd, get_path(type, R.version), name, version, get_ext(type))
      if (file.exists(dest)) file.remove(dest)
      compressor <- get_compressor(type)
      tryCatch({
        setwd(pkg.dir)
        compressor(dest, name)
      }, finally = setwd(current.wd))
      tryCatch({
        setwd(dirname(dest))
        tools::write_PACKAGES(type = ifelse(type == "mac.binary.mavericks", "mac.binary", type))
      }, finally = setwd(current.wd))
    }
  })

library(git2r)
target.github.pkgs.hash <- sapply(
  target.github.pkgs.full,
  function(path) {
    # git ls-remote git://github.com/<user>/<project>.git
    git2r::remote_ls(sprintf("https://github.com/%s.git", path))["refs/heads/master"]
  })

if (file.exists(".git")) {
  invisible(file.remove(dir(".git", all.files = TRUE, full.names = TRUE, recursive = TRUE)))
}
repo <- git2r::init(".")
git2r::add(repo, c("bin", "src"))

message <- sprintf("%s : %s", target.github.pkgs.full, target.github.pkgs.hash)
message <- paste(message, collapse  = "\n")
commit <- git2r::commit(repo, message = message)
git2r::remote_add(repo, "origin", url = "git@github.com:wush978/R.git")
# git2r::push(repo, "origin", "refs/head/master")
system("git checkout -b gh-pages")
system("git push -uf origin gh-pages")
