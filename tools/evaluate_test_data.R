#!/usr/bin/env Rscript

require(jsonlite) # install.packages(c("jsonlite","png"))
require(png)

# NOTE: the path will have to change
input_csv_fn <- "~/Downloads/mirrortracing"

d_in <- read.csv(input_csv_fn, sep="\t", stringsAsFactors=FALSE)

# maybe "save" button pressed more than once:
d_in <- d_in[!duplicated(d_in$date),]
# only s2c ids
d_in <- d_in[d_in$subj_id > 1700000 & d_in$subj_id < 1800000, ]


g_debug <- F


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
  cat(l_row_in$SubmissionId)
  cat("\n")
  img_bytes    <- jsonlite::base64_dec(as.character(l_row_in$image_png))
  img          <- png::readPNG(img_bytes)
  l_trajectory <- jsonlite::parse_json(json=as.character(l_row_in$trajectory))
  if (g_debug) { writeBin(img_bytes, con=sprintf("/tmp/mirrortracing_img_%s.png", l_row_in$SubmissionId)) }
  l_out <- list()
  l_out$total_time_ms <- traj_time_ms(tail(tail(l_trajectory,n=1)[[1]],n=1)[[1]])
  l_out$drawing_time_ms <- (function(){
    drawing_time <- 0
    for (line in l_trajectory) {
      drawing_time <- drawing_time + traj_time_ms(tail(line, n=1)[[1]]) - traj_time_ms(head(line, n=1)[[1]])
    }
    return(drawing_time)
  })()
  # img
  cm2px <- length(img[1,,1]) / as.numeric(l_row_in$image_width_cm)
  px2cm <- 1/cm2px
  l_img <- NULL
  l_img[["r"]] <- img[,,1]
  l_img[["g"]] <- img[,,2]
  l_img[["b"]] <- img[,,3]
  l_img[["a"]] <- img[,,4]
  l_trajectory <- qc_trajectory(l_trajectory=l_trajectory, max_sample_dist_px=2*cm2px)
  l_img_out <- redraw_trajectory(l_img=l_img, l_trajectory=l_trajectory)
  img[,,1] <- l_img_out[["r"]]
  img[,,2] <- l_img_out[["g"]]
  img[,,3] <- l_img_out[["b"]]
  img[,,4] <- l_img_out[["a"]]
  l_rmsd <- calc_rmsd_px(star=img[,,2] | img[,,3], paint=img[,,1])
  l_out$rmsd_cm <- l_rmsd$rmsd * px2cm
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



d_out




library(lattice)

box_settings_u <- trellis.par.get("box.rectangle")
box_settings_u$lty <- 1
box_settings_u$lwd <- 2
box_settings_u$col <- "black"
box_settings_b <- trellis.par.get("box.umbrella")
box_settings_b$lty <- 1
box_settings_b$lwd <- 2
box_settings_b$col <- "black"

par_s <- list(box.rectangle=box_settings_b, box.umbrella=box_settings_u)

pl1 <- xyplot(d_out$drawing_time_ms ~ d_out$trial_id, group = d_out$subj_id, type = "b", par.settings = par_s)
pl2 <- xyplot(d_out$rmsd_cm ~ d_out$trial_id, group = d_out$subj_id, type = "b", par.settings = par_s)
pb1 <- bwplot(d_out$rmsd_cm ~ d_out$trial_id, horizontal=F, par.settings = par_s)
pb2 <- bwplot(d_out$drawing_time_ms ~ d_out$trial_id, horizontal=F, par.settings = par_s)

pdf ("/tmp/mirrortracing_plot.pdf", 7,7)
print(pl1, position=c(0, .0, .5, .5), more=TRUE)
print(pl2, position=c(0, .5, 0.5, 1), more=TRUE)
print(pb1, position=c(0.5, .5, 1, 1), more=TRUE)
print(pb2, position=c(0.5, 0, 1, .5))
dev.off()




if (F) {


img_star <- img[,,2]+img[,,3]
m_dist <- img[,,1]



get_smallest_dist2 <- function(img_star, i0, j0) {
  dist_s <- .Machine$double.xma
  for (i in 1:nrow(img_star)) {
    dists <- sapply(seq_along(1:dim(img_star)[2]), function(j)
      ifelse (img_star[i,j] > 0, ((i0-i)^2+(j0-j)^2)^0.5, .Machine$double.xma)
    )
    dist_s <- min(c(dist_s, dists))
  }
  return(dist_s)
}

get_smallest_dist <- function(img_star, i0, j0) {
  dist_s <- .Machine$double.xma
  for (i in 1:nrow(img_star)) {
    for (j in 1:ncol(img_star)) {
      # is it a pixel on star?
      if (img_star[i,j] > 0) {
        # get distance
        dist_curr <- ((i0-i)^2+(j0-j)^2)^0.5
        # update min?
        #cat(sprintf("%f\n",dist_curr))
        dist_s <- min(dist_curr, dist_s)
      }
    }
  }
  return(dist_s)
}

m_dist[,] <- 0
for (i in 1:nrow(m_dist)) {
  cat(sprintf("%d\n",i))
  for (j in 1:ncol(m_dist)) {
    m_dist[i,j] <- get_smallest_dist(img_star, i,j )

  }
}

image(m_dist)

load("/tmp/bla.Rdata")
start <-50
end <- 150
m_dist <- m_dist[start:end,start:end]
img_star <- img_star[start:end,start:end]
image(img_star)






m_dist[,] <- 0



get_smallest_dist3 <- function(d_star, i0, j0) {
  vin <- c(i0,j0)
  min(sapply(d_star, function(x) {
    # ((i0-x[1])^2+(j0-x[2])^2)^0.5
    dist( rbind(vin, x) )
  }))
}

m_dist[,] <- 0
d_star <- get_star_points(img_star)
for (i in 1:nrow(m_dist)) {
  cat(sprintf("%d\n",i))
  for (j in 1:ncol(m_dist)) {
    m_dist[i,j] <- get_smallest_dist(img_star, i,j )

  }
}
image(m_dist)


mindist <- function() {
  l_mindist <- NULL
  l_mindist$c <- 0

  l_mindist$add <- function(x)(
    l_mindist$c <<- l_mindist$c + 1
  )
  l_mindist$sub <- function(x)(
    l_mindist$c <<- l_mindist$c - 1
  )
  return(l_mindist)
}


# Function closures

MinDist <- function() {
  l_mindist <- NULL
  l_mindist$m_dist <- matrix()

  # init
  l_mindist$init <- function(img_star) {
    l_mindist$m_dist    <<- img_star
    l_mindist$m_dist[,] <<- ifelse(img_star[,] > 0, 0, -1)
    l_mindist$d_star    <<- (function() {
      r <- data.frame()
      for (i in 1:nrow(img_star)) {
        for (j in 1:ncol(img_star)) {
          if (img_star[i,j] > 0) {
            r <- rbind(r, data.frame(i=i,j=j))
          }
        }
      }
      return(as.matrix(r))
    })()
  }
  # get cached distance of i,j to start (in pixels)
  l_mindist$getdist <- function(i,j) {
    # already computed?
    if (l_mindist$m_dist[i,j] < 0) {
      # calculate distance
      vin <- c(i,j)
      l_mindist$m_dist[i,j] <<- min(apply(l_mindist$d_star, 1, function(x) {
        dist <- dist( rbind(vin, x) )
        #dist <- ((i-x[1])^2+(j-x[2])^2)^0.5
        #cat(sprintf("i:%d,j:%d -- x1:%d,x2:%d   %f\n", vin[1],vin[2], x[1], x[2], dist))
        return(dist)
      }))
    }
    return(l_mindist$m_dist[i,j])
  }
  # getters
  l_mindist$m <- function() {
    l_mindist$m_dist
  }
  l_mindist$dstar <- function() {
    #plot(l_mindist$dstar()[,1],l_mindist$dstar()[,2])
    l_mindist$d_star
  }
  return(l_mindist)
}


o_mindist <- mindist()
o_mindist$init(img_star)


# for (i in 1:nrow(m_dist)) {
#   cat(sprintf("%d\n",i))
#   for (j in 1:ncol(m_dist)) {
#     l_mindist$getdist(i,j)
#   }
# }
# image(l_mindist$m())

system.time(
  (function() {
    l_mindist <- mindist()
    l_mindist$init(img_star)
    img_draw <- img[,,1]
    for (i in 1:nrow(img_draw)) {
      cat(sprintf("row %d\n",i))
      for (j in 1:ncol(img_draw)) {
        if (img_draw[i,j] > 0) {
          l_mindist$getdist(i,j)
        }
      }
    }
  })()
)
image(l_mindist$m())


#mindist_init <- function(md, )

}