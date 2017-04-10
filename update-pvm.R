loadNamespace("devtools")
loadNamespace("git2r")
if (file.exists("pvm")) {
  local({
    repo <- git2r::repository("pvm")
    git2r::pull(repo)
  })
} else {
  git2r::clone("https://github.com/wush978/pvm.git", local_path = "pvm")
}
pkg <- devtools::build("pvm", manual = TRUE)
path <- contrib.url(".", type = "source")
unlink(dir(path, pattern = "pvm*", full.names = TRUE))
file.copy(pkg, path)
tools::write_PACKAGES(path, verbose = TRUE)
repo <- git2r::repository(".")
git2r::add(repo, file.path(path, pkg))
git2r::add(repo, path)
version <- read.dcf(file.path("pvm", "DESCRIPTION"))[,"Version"]
git2r::commit(repo, sprintf("pvm: %s", version))
if (!exists("credentials")) credentials <- NULL
git2r::push(repo, credentials = credentials)
unlink(pkg)
