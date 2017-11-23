argv <- commandArgs(TRUE)
target <- argv[1]
target.repo <- argv[2]
if (is.na(target.repo)) {
  target.repo <- sprintf("https://github.com/wush978/%s.git", target)
}
loadNamespace("devtools")
loadNamespace("git2r")
if (file.exists(target)) {
  local({
    repo <- git2r::repository(target)
    git2r::pull(repo)
  })
} else {
  git2r::clone(target.repo, local_path = target)
}
pkg <- devtools::build(target, manual = TRUE)
path <- contrib.url("./R", type = "source")
unlink(dir(path, pattern = sprintf("%s*", target), full.names = TRUE))
file.copy(pkg, path)
tools::write_PACKAGES(path, verbose = TRUE)
repo <- git2r::repository("R")
git2r::add(repo, file.path(path, pkg))
git2r::add(repo, path)
version <- read.dcf(file.path(target, "DESCRIPTION"))[,"Version"]
git2r::commit(repo, sprintf("%s: %s", target, version))
if (!exists("credentials")) credentials <- NULL
git2r::push(repo, credentials = credentials)
unlink(pkg)
