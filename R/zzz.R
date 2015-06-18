.onAttach <- function(libname, pkgname){

  # Manually update the version number
  v <- "0.1"

  # Startup message
  packageStartupMessage(paste("umbrella (version ", v ,")", sep=""))
  packageStartupMessage("GitHub version of package\nJason D. Carlisle <jason.d.carlisle@gmail.com>")

}
