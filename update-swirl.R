loadNamespace("devtools")
loadNamespace("git2r")
if (file.exists("swirl")) {
  local({
    repo <- git2r::repository("swirl")
    git2r::pull(repo)
  })
} else {
  git2r::clone("https://github.com/wush978/swirl.git", local_path = "swirl")
}
pkg <- devtools::build("swirl", manual = TRUE)
path <- contrib.url(".", type = "source")
unlink(dir(path, pattern = "swirl*", full.names = TRUE))
file.copy(pkg, path)
tools::write_PACKAGES(path, verbose = TRUE)
repo <- git2r::repository(".")
git2r::add(repo, file.path(path, pkg))
git2r::add(repo, path)
version <- read.dcf(file.path("swirl", "DESCRIPTION"))[,"Version"]
git2r::commit(repo, sprintf("swirl: %s", version))
git2r::push(repo)
unlink(pkg)
