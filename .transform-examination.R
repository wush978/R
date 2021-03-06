cat("Loading transform\n")
transform <- function() {
  path <- getOption("swirlify_lesson_file_path")
  src.path <- gsub("yaml", "src.yaml", path)
  parsed <- yaml::yaml.load_file(src.path)
  for(i in seq_along(parsed)) {
	if (parsed[[i]]$Class == "cmd_question") {
      if (is.null(parsed[[i]]$CorrectAnswer)) {
        .output <- parsed[[i]]$Output
		.output <- iconv(.output, from="UTF-8", to="BIG5")
        .is_valid <- local({
          sum(strsplit(.output, "")[[1]] == "`") == 2
        })
        if (!.is_valid) stop(sprintf("CorrectAnswer is missing at step %d(%s)", i, .output))
        .answer <- regmatches(.output, regexec("`(.*)`", .output))[[1]][2]
        cat(sprintf("CorrectAnswer is missing. Insert the expression %s as CorrectAnswer\n", .answer))
        parsed[[i]]$CorrectAnswer <- .answer
      }
      if (is.null(parsed[[i]]$AnswerTests)) {
        cat(sprintf("(%d)AnswerTests is missing. Insert the CorrectAnswer as AnswerTests.\n", i))
        parsed[[i]]$AnswerTests <- sprintf('omnitest(\'%s\')', parsed[[i]]$CorrectAnswer)
      }
      if (is.null(parsed[[i]]$Hint)) {
        parsed[[i]]$Hint <- "There is no hint for examination"
      }
    }
  }
  write(yaml::as.yaml(parsed), file = path)
}

transform_all <- function() {
  course_list <- dir(".", "lesson.yaml", recursive = TRUE)
  origin_course <- getOption("swirlify_lesson_file_path")
  tryCatch({
    lapply(course_list, function(path) {
      print(path)
      if ("swirlify" %in% loadedNamespaces()) swirlify::set_lesson(path, FALSE, TRUE)
      suppressWarnings(transform())
    })
  }, finally = {
    set_lesson(origin_course)
  })
}
