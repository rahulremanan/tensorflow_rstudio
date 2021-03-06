
# record of load error message
.load_error_message <- NULL

tf_on_load <- function(libname, pkgname) {

  # attempt to load tensorflow
  tf <<- tryCatch(import("tensorflow"), error = function(e) e)
  if (inherits(tf, "error")) {
    .load_error_message <<- tf$message
    tf <<- NULL
  }

  # verify minimum required TF version
  if (!is.null(tf)) {
    tf_version <- tryCatch(tf$VERSION, error = function(e) NULL)
    tf_version <- gsub("\\.$", "", gsub("[A-Za-z_]+", "", tf_version))
    if (is.null(tf_version) || package_version(tf_version) < "0.12") {
      .load_error_message <<- paste("The tensorflow package requires version 0.12",
                                    "or later of TensorFlow")
      tf <<- NULL
    }
  }

  # if we loaded tensorflow then register tf help topics
  if (!is.null(tf))
    register_tf_help_topics()
}

tf_on_attach <- function(libname, pkgname) {
  if (is.null(tf)) {
    packageStartupMessage(.load_error_message)
    packageStartupMessage("If you have not yet installed TensorFlow, see ",
                          "https://www.tensorflow.org/get_started/")
    packageStartupMessage("Configuration:")
    config <- tf_config()
    packageStartupMessage(" python:    ", config$python)
    packageStartupMessage(" libpython: ", config$libpython)
    packageStartupMessage(" numpy:     ", config$numpy)
  }
}
