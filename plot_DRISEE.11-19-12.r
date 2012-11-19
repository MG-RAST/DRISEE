plot_DRISEE <- function(
                        file_in,
                        bps_indexed = 1,
                        figure_width = 500,
                        figure_height = 500,
                        figure_res = NA
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

     USAGE: plot_DRISEE(
          file_in = no default arg             # (string)  input data file
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
  
  image_out = gsub(" ", "", paste(file_in, ".DRISEE.png"))

  if (  bps_indexed == 1 ){
    my_data <<- data.matrix(read.table(file_in, row.names=1, header=TRUE, sep="\t", comment.char="", quote="", skip=2))
  }else if ( bps_indexed == 0 ) {
    my_data <<- data.matrix(read.table(file_in, row.names=NULL, header=TRUE, sep="\t", comment.char="", quote="", skip=2))
  }else {
    stop("invalid bps_indexed value specified --- has to be 0 or 1")
  }

  num_header_fields = dim(as.matrix(dimnames(my_data)[[2]]))[1]

  A_err <- (dimnames(my_data)[[2]])[num_header_fields-6] # get data headers for error containing columns
  T_err <- (dimnames(my_data)[[2]])[num_header_fields-5]
  C_err <- (dimnames(my_data)[[2]])[num_header_fields-4]
  G_err <- (dimnames(my_data)[[2]])[num_header_fields-3]
  N_err <- (dimnames(my_data)[[2]])[num_header_fields-2]
  InDel_err <- (dimnames(my_data)[[2]])[num_header_fields-1]
  Total_err <- (dimnames(my_data)[[2]])[num_header_fields]
  sum_err = (my_data[,A_err] + my_data[,T_err] + my_data[,C_err] + my_data[,G_err] + my_data[,N_err] + my_data[,InDel_err])
  
  test_header =   as.matrix(strsplit(gsub("#", "", readLines(con=file_in, n=2)),"\t"))
  
  CairoPNG(image_out, width = figure_width, height = figure_height, pointsize = 12, res = fiure_res , units = "px")


  plot(sum_err,  type="l", col="darkmagenta", main = gsub(" ", "", paste(file_in, "::DRISEE_profile")), xlab = "bp position", ylab = "error abundance", ylim=c(0,100))
  lines(my_data[,A_err], type="l", col="green")
  lines(my_data[,T_err], type="l", col="red")
  lines(my_data[,C_err], type="l", col="blue")
  lines(my_data[,G_err], type="l", col="yellow")
  lines(my_data[,N_err], type="l", col="black")
  lines(my_data[,InDel_err], type="l", col="brown")
  
  legend( 
         max(100), 
         c(
           paste("Total_err", "=", test_header[[2]][8], sep="\t"), # total Err
           paste(test_header[[1]][2], "=", test_header[[2]][2], sep="\t"),
           paste(test_header[[1]][3], "=", test_header[[2]][3], sep="\t"),
           paste(test_header[[1]][4], "=", test_header[[2]][4], sep="\t"),
           paste(test_header[[1]][5], "=", test_header[[2]][5], sep="\t"),
           paste(test_header[[1]][6], "=", test_header[[2]][6], sep="\t"),
           paste("InDel_err",  "=", test_header[[2]][7], sep="\t") #InDel Err
           ),
         col=c("darkmagenta", "green", "red", "blue", "yellow", "black", "brown"),
         lty=1
         )

  dev.off()

}
