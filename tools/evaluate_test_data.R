#!/usr/bin/env Rscript

require(jsonlite) # install.packages(c("jsonlite","png"))
require(png)

# NOTE: the path will have to change
input_csv_fn <- "~/Downloads/data-132996-2019-12-05-1018-utf.txt"

d_in <- read.csv(input_csv_fn, sep="\t", stringsAsFactors=FALSE)



# get image channels rgba 
cr <- function(d) d[1]
cg <- function(d) d[2]
cb <- function(d) d[3]
ca <- function(d) d[4]

# get values of a sample from trajectory
traj_x       <- function(sample) sample[[1]]
traj_y       <- function(sample) sample[[2]]
traj_time_ms <- function(sample) sample[[3]]

# get pixel of image
get_pixel <- function(img, x, y) {
  if (x < 1) return (NA)
  if (y < 1) return (NA)
  if (x > ncol(img)) return (NA)
  if (y > nrow(img)) return (NA)
  return(img[y,x,])
} 

evaluate_image <- function(l_row_in) {
  img_bytes    <- jsonlite::base64_dec(as.character(l_row_in$image_png))
  img          <- png::readPNG(img_bytes)
  l_trajectory <- jsonlite::parse_json(json=as.character(l_row_in$trajectory))
  l_out <- list()
  # evaluate samples
  l_out$num_samples_total <- 0
  l_out$num_samples_outside <- 0
  l_out$num_boundary_crossings <- 0
  is_inside_prev <- NA
  for (line in l_trajectory) {
    for (sample in line) {
      x <- traj_x(sample)+1 # convert to R, 1-based index
      y <- traj_y(sample)+1
      pix <- get_pixel(img, x, y)
      is_inside   <- ! is.na(pix) && (cg(pix) > 0 || cb(pix) > 0)
      is_boundary <- ! is.na(pix) && cb(pix) > 0
      l_out$num_samples_total   <- l_out$num_samples_total   + 1
      l_out$num_samples_outside <- l_out$num_samples_outside + ifelse(is_inside, 0, 1)
      if ( ! is_boundary ) {
        if ( ! is.na(is_inside_prev) && is_inside_prev != is_inside ) {
          l_out$num_boundary_crossings <- l_out$num_boundary_crossings + 1
        }
        is_inside_prev <- is_inside
      }
    }
  }
  # evaluate pixels
  l_out$num_pixels_total   <- 0
  l_out$num_pixels_outside <- 0
  for (i in 1:nrow(img)) {
    for (j in 1:ncol(img)) {
      pix <- get_pixel(img, j, i)
      stopifnot(!is.na(pix))
      is_line     <- (cr(pix) > 0)
      is_inside   <- (cg(pix) > 0 || cb(pix) > 0)
      if (! is_line) {
        next()
      }
      l_out$num_pixels_total   <- l_out$num_pixels_total   + 1
      l_out$num_pixels_outside <- l_out$num_pixels_outside + ifelse(is_inside, 0, 1)
    }
  }
  l_out$num_continuous_lines <- length(l_trajectory)
  l_out$total_time_ms <- traj_time_ms(tail(tail(l_trajectory,n=1)[[1]],n=1)[[1]])
  l_out$drawing_time_ms <- (function(){
    drawing_time <- 0
    for (line in l_trajectory) {
      drawing_time <- drawing_time + traj_time_ms(tail(line, n=1)[[1]]) - traj_time_ms(head(line, n=1)[[1]])
    }
    return(drawing_time)
  })()
  l_out
}

calc_trial_ids <- function(d_tr) {
  day_fmt <- "%Y-%m-%d"
  l_currIds    <- list() # will be used as dictionary: "subj_id"->"trial_id"
  v_ids <- sapply(1:nrow(d_tr), function(i) {
    curr_subjid <- as.character(d_tr$subj_id[i])
    curr_day    <- strftime(d_tr$date[i], format=day_fmt)
    # is first entry or day has changed?
    if (is.null(l_currIds[[curr_subjid]]) || l_currIds[[curr_subjid]]$date != curr_day) {
      # init/reset entry
      l_currIds[[curr_subjid]] <<- list(
        date=curr_day
        ,trialid=1
      )
    } else {
      # increase trial ID counter
      l_currIds[[curr_subjid]]$trialid <<- l_currIds[[curr_subjid]]$trialid + 1
    }
    l_currIds[[curr_subjid]]$trialid
  })
  v_ids
}

# copy some values
date_fmt_in <- "%Y-%m-%dT%H:%M:%S"
d_out <- data.frame(
  subj_id     = d_in$subj_id
  ,project_id = d_in$project_id
  ,wave_id    = d_in$wave_id
  ,date       = strptime(d_in$date, format=date_fmt_in)
  ,trial_id   = calc_trial_ids(
                data.frame(
                  subj_id=d_in$subj_id
                  ,date=strptime(d_in$date, format=date_fmt_in)
                )
              )
)


# apply evaluation and append to d_out
l_tmp <- apply(d_in, 1, function(x) evaluate_image(as.list(x)))
d_tmp <- data.frame(matrix(unlist(l_tmp), nrow=length(l_tmp), byrow=T), stringsAsFactors=FALSE)
colnames(d_tmp) <- names(l_tmp[[1]])
d_out <- cbind(d_out, d_tmp)
