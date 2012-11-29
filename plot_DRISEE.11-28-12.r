plot_DRISEE <- function(
                        file_in,
                        image_type = c("png", "pdf"),
                        bps_indexed = 1,
                        image_width = 0,
                        image_height = 0,
                        debug = 0
                        )
  
{
  # load packages
  # suppressPackageStartupMessages(library(Cairo))
  #require(ggplot2)

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
          file_in                     = no default # (string) # input data file (*.DRISEE or *.DRISEE.per)
          image_type                  = pdf        # (string) # c(\"pdf\", \"png\") # specifiy the image type
          image_width                 = 6|500      # (int):   # image width:  default = 6 inches for pdf or 1000 pixels for png
          image_height                = 6|500      # (int):   # image height: default = 6 inches for pdf or 1000 pixels for png
          bps_indexed                 = 1          # integer boolean indicating if the bp's are indexed or not
          debug                       = 0          # 1 for debug mode

     CITATION: 
          Keegan KP, Trimble WL, Wilkening J, Wilke A, Harrison T, et al. (2012)
          A Platform-Independent Method for Detecting Errors in Metagenomic Sequencing Data: DRISEE. 
          PLoS Comput Biol 8(6): e1002541. doi:10.1371/journal.pcbi.1002541
)\n"
               )
    stop("plot_DRISEE stopped\n\n")
  }

  # give the usage if the function is called with no arguments
  if ( nargs() == 0 ){
    func_usage()
  }

  # set pdf as the image_type if none was specified
  if( length(image_type) == 2 ){ image_type = "pdf" }
  
  # set output names and defaults for png and pdf output types
  if ( length(grep("png",image_type) ) == 1 ){
    image_out <<- gsub(" ", "", paste(file_in, ".png")) # set the output file name
    if ( as.integer(image_width + image_height) == 0 ){ # set defaults for width and height if none are selected
      image_width = 500
      image_height = 500
    }
  }else if ( length(grep("pdf",image_type) ) == 1 ){
    image_out <<- gsub(" ", "", paste(file_in, ".pdf")) # set the output file name
    if ( as.integer(image_width + image_height) == 0 ){ # set defaults for width and height if none are selected
      image_width = 6 
      image_height = 6
    }
  }else{
    paste("image_type:", image_type)
    stop("could not specifiy an image type")
  }

  
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
  sum_err = (my_data[,A_err] + my_data[,T_err] + my_data[,C_err] + my_data[,G_err] + my_data[,N_err] + my_data[,InDel_err])
  
  test_header <<-   as.matrix(strsplit(gsub("#", "", readLines(con=file_in, n=2)),"\t"))

  if (  length(grep(".per$",file_in)) == 1 ){
    my_title = gsub(" ", "", paste(file_in, "::DRISEE.percent_profile"))
    y_axis_max = 100
    my_ylab = "error percent"
  }else{
    my_title = gsub(" ", "", paste(file_in, "::DRISEE.abundance_profile"))
    y_axis_max = max(my_data)
    my_ylab = "error abundance"
  }


  if (  length(grep("png",image_type)) == 1 ){
    png(filename = image_out, width = image_width, height = image_height)
  } else if (  length(grep("pdf",image_type)) == 1 ){
    pdf(file = image_out, width = image_width, height = image_height, fonts="Helvetica")
  }
   
  #plot(sum_err,  type="l", col="darkmagenta", main = my_title, xlab = "bp position", ylab = my_ylab, ylim=c(0,y_axis_max))
  plot(sum_err,  type="l", col="darkmagenta", xlab = "bp position", ylab = my_ylab, ylim=c(0,y_axis_max))
  title(my_title, cex.main = 1)
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
