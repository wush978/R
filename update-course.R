loadNamespace("devtools")
loadNamespace("git2r")
if (file.exists("DataScienceAndR")) {
  local({
    repo <- git2r::repository("DataScienceAndR")
    git2r::pull(repo)
  })
} else {
  git2r::clone("https://github.com/wush978/DataScienceAndR.git", local_path = "DataScienceAndR", branch = "course")
}
unlink(dir("R/course", "DataScienceAndR.zip", full.names = TRUE))
targets <- dir("DataScienceAndR", all.files = TRUE, recursive = TRUE, full.names = TRUE, include.dirs = FALSE)
targets.exclude <- dir(file.path("DataScienceAndR", ".git"), all.files = TRUE, recursive = TRUE, full.names = TRUE, include.dirs = FALSE)
targets <- setdiff(targets, targets.exclude)
zip(dst <- file.path("R", "course", "DataScienceAndR.zip"), files = targets)
# pkg <- devtools::build("swirl", manual = TRUE)
# path <- contrib.url(".", type = "source")
# unlink(dir(path, pattern = "swirl*", full.names = TRUE))
# file.copy(pkg, path)
# tools::write_PACKAGES(path, verbose = TRUE)
repo <- git2r::repository("R")
git2r::checkout(repo, "gh-pages")
git2r::add(repo, dst)
# git2r::add(repo, path)
version <- local({
  repo2 <- git2r::repository("DataScienceAndR")
  git2r::branch_target(git2r::head(repo2))
})
git2r::commit(repo, sprintf("course: %s", version))
if (!exists("credentials")) credentials <- NULL
git2r::push(repo, credentials = credentials)
# unlink(pkg)
