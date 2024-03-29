cat("Loading transform\n")
# loadNamespace("git2r")
loadNamespace("swirlify")
transform <- function(prehook = NULL, posthook = NULL, dir.course.name = FALSE) {
  .check.question <- function(obj, expected.keys) {
    stopifnot(!duplicated(names(obj)))
    if (length(setdiff(names(obj), expected.keys)) != 0) {
      stop(sprintf("Unknown component: %s", paste(setdiff(names(obj), expected.keys), collapse = ",")))
    }
  }
  path <- getOption("swirlify_lesson_file_path")
  src.path <- gsub("yaml", "src.yaml", path)
  parsed <- yaml::yaml.load_file(src.path)
  lesson.name <- basename(dirname(normalizePath(src.path)))
  if (dir.course.name) {
    course.name <- basename(dirname(dirname(normalizePath(src.path))))
  } else {
    course.repo <- git2r::repository(dirname(dirname(normalizePath(src.path))))
    course.name <- gsub(".git", "", basename(git2r::remote_url(course.repo, "origin")), fixed = TRUE)
  }
  for(i in seq_along(parsed)) {
    tryCatch({
      if (!is.null(prehook)) parsed[[i]] <- prehook(parsed[[i]])
      # attributes checking
    	switch(
    	  parsed[[i]]$Class,
      	  "cmd_question" = {
      	    .check.question(parsed[[i]], c("Class", "Output", "CorrectAnswer", "AnswerTests", "Hint"))
            if (is.null(parsed[[i]]$CorrectAnswer)) {
              .output <- parsed[[i]]$Output
              Encoding(.output) <- "UTF-8"
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
              cat(sprintf("(%d)Hint is missing. Insert the CorrectAnswer as Hint\n", i))
              parsed[[i]]$Hint <- parsed[[i]]$CorrectAnswer
            }
        	}, # cmd_question
      	"mult_question" = {
    	    .check.question(parsed[[i]], c("Class", "Output", "AnswerChoices", "CorrectAnswer", "AnswerTests", "Hint"))
      	},
    	  "script" = {
          .check.question(parsed[[i]], c("Class", "Output", "Script", "AnswerTests"))    	    
    	  },
    	  "text" = {
    	    .check.question(parsed[[i]], c("Class", "Output"))
    	  },
    	  "meta" = {
    	    .check.question(parsed[[i]], c("Class", "Course", "Lesson", "Author", "Type", "Organization", "Version"))
    	    stopifnot(parsed[[i]]$Course == course.name)
    	    stopifnot(parsed[[i]]$Lesson == lesson.name)
    	  },
      	stop(sprintf("Unknown Class: %s", parsed[[i]]$Class))
    	) # switch
      if (!is.null(posthook)) parsed[[i]] <- posthook(parsed[[i]])
    }, error = function(e) {
      if (interactive()) browser()
      cat(sprintf("(%d) An error is occurred!\n", i))
      dput(parsed[[i]])
      stop(conditionMessage(e))
    }) # tryCatch
  } # for
  .f <- file(path, "w", encoding = "UTF-8")
  write(yaml::as.yaml(parsed), file = .f)
  close(.f)
}

transform_all <- function(prehook = NULL, posthook = NULL, dir.course.name = FALSE) {
  course_src_list <- dir(".", "lesson.src.yaml", recursive = TRUE)
  course_list <- gsub("lesson.src.yaml", "lesson.yaml", course_src_list, fixed = TRUE)
  .init.targets <- which(!file.exists(course_list))
  lapply(.init.targets, function(.i) {
    file.copy(course_src_list[.i], course_list[.i])
  })
  origin_course <- getOption("swirlify_lesson_file_path")
  tryCatch({
    lapply(course_list, function(path) {
      print(path)
      swirlify::set_lesson(path, FALSE, TRUE)
      suppressWarnings(transform(prehook, posthook, dir.course.name))
    })
  }, finally = {
    if (!is.null(origin_course)) swirlify::set_lesson(origin_course)
  })
}

correct_utf8_space <- function(path) {
  src <- readLines(path)
  utf8.s <- rawToChar(as.raw(c(0xc2,0xa0)))
  s <- rawToChar(as.raw(0x20))
  dst <- gsub(utf8.s, s, src, fixed = TRUE)
  stopifnot(!grepl(utf8.s, dst))
  write(dst, path)
}

correct_utf8_space_all <- function() {
  src_list <- dir(".", "lesson.src.yaml", recursive = TRUE)
  lapply(src_list, correct_utf8_space)
  invisible(NULL)
}
