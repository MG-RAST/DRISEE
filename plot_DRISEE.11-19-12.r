plot_DRISEE <- function(
                        file_in,
                        bps_indexed = 1,
                        figure_width = 500,
                        figure_height = 500
                        )
  
{
  # load packages
  suppressPackageStartupMessages(library(Cairo))
  
  # define sub functions
  func_usage <- function() {
    writeLines("
     You supplied no arguments

     DESCRIPTION: (plot_DRISEE):
     Script to plot DRISEE *.DRISEE or *.DRISEE.per files as a line graph
     Script will detect if file is *.DRISEE or *.DRISEE.per.
     Other files will be treated as if they were *.DRISEE
     Note that the key always show error as percentage (this is not a bug), but that the y-axis
     will display percent error (for *.DRISEE.per) or error abundance (all other).

     USAGE: plot_DRISEE(
          file_in = no default arg             # (string)  input data file (*.DRISEE or *.DRISEE.per)
          bps_indexed                 = 1      # integer boolean indicating if the bp's are indexed or not
          figure_width                = 1000,  # usually pixels, inches if eps is selected; png is default
          figure_height               = 1000,  # usually pixels, inches if eps is selected; png is default
          figure_res                  = NA     # usually pixels, inches if eps is selected; png is default

     CITATION: 
          Keegan KP, Trimble WL, Wilkening J, Wilke A, Harrison T, et al. (2012)
          A Platform-Independent Method for Detecting Errors in Metagenomic Sequencing Data: DRISEE. 
          PLoS Comput Biol 8(6): e1002541. doi:10.1371/journal.pcbi.1002541
)\n"
               )
    stop("plot_DRISEE stopped\n\n")
  }

  if ( nargs() == 0 ){
    func_usage()
  }

  image_out = gsub(" ", "", paste(file_in, ".png")) # create filename with extension for output image
  #image_out = gsub(" ", "", paste(file_in, ".pdf")) # create filename with extension for output image
  
  if (  bps_indexed == 1 ){
    my_data <<- data.matrix(read.table(file_in, row.names=1, header=TRUE, sep="\t", comment.char="", quote="", skip=2))
  }else if ( bps_indexed == 0 ) {
    my_data <<- data.matrix(read.table(file_in, row.names=NULL, header=TRUE, sep="\t", comment.char="", quote="", skip=2))
  }else {
    stop("invalid bps_indexed value specified --- has to be 0 or 1")
  }

  num_header_fields <<- dim(as.matrix(dimnames(my_data)[[2]]))[1]

  A_err <<- (dimnames(my_data)[[2]])[num_header_fields-5] # get data headers for error containing columns
  T_err <- (dimnames(my_data)[[2]])[num_header_fields-4]
  C_err <- (dimnames(my_data)[[2]])[num_header_fields-3]
  G_err <- (dimnames(my_data)[[2]])[num_header_fields-2]
  N_err <<- (dimnames(my_data)[[2]])[num_header_fields-2]
  InDel_err <<- (dimnames(my_data)[[2]])[num_header_fields]
  #Total_err <- (dimnames(my_data)[[2]])[num_header_fields]
  sum_err = (my_data[,A_err] + my_data[,T_err] + my_data[,C_err] + my_data[,G_err] + my_data[,N_err] + my_data[,InDel_err])
  
  test_header <<-   as.matrix(strsplit(gsub("#", "", readLines(con=file_in, n=2)),"\t"))
  
  png(filename = image_out, width = figure_width, height = figure_height, type = "Xlib")
  #pdf(file = image_out, width = figure_width, height = figure_height)

  if (  length(grep(".per$",file_in)) == 1 ){
    my_title = gsub(" ", "", paste(file_in, "::DRISEE.percent_profile"))
    y_axis_max = 100
    my_ylab = "error percent"
  }else{
    my_title = gsub(" ", "", paste(file_in, "::DRISEE.abundance_profile"))
    y_axis_max = max(my_data) + (max(my_data)/10)
    my_ylab = "error abundance"
  }

  plot(sum_err,  type="l", col="darkmagenta", main = my_title, xlab = "bp position", ylab = my_ylab, ylim=c(0,y_axis_max))
  lines( my_data[,A_err], type="l", col="green" )
  lines( my_data[,T_err], type="l", col="red" )
  lines( my_data[,C_err], type="l", col="blue" )
  lines( my_data[,G_err], type="l", col="yellow" )
  lines( my_data[,N_err], type="l", col="black" )
  lines( my_data[,InDel_err], type="l", col="brown" )
  
  legend( 
         max(y_axis_max), 
         c(
           paste("Total_err", "=", round( as.numeric(test_header[[2]][8]), digits = 2 ), "%", sep=" "), # total Err
           paste(test_header[[1]][2], "=      ", round( as.numeric(test_header[[2]][2]), digits = 2 ), "%", sep=" "),
           paste(test_header[[1]][3], "=      ", round( as.numeric(test_header[[2]][3]), digits = 2 ), "%", sep=" "),
           paste(test_header[[1]][4], "=      ", round( as.numeric(test_header[[2]][4]), digits = 2 ), "%", sep=" "),
           paste(test_header[[1]][5], "=      ", round( as.numeric(test_header[[2]][5]), digits = 2 ), "%", sep=" "),
           paste(test_header[[1]][6], "=      ", round( as.numeric(test_header[[2]][6]), digits = 2 ), "%", sep=" "),
           paste("InDel_err",  "=", round( as.numeric(test_header[[2]][7]), digits = 2 ), "%", sep=" ") #InDel Err
           ),
         col=c("darkmagenta", "green", "red", "blue", "yellow", "black", "brown"),
         lty=1
         )

  dev.off()

}
