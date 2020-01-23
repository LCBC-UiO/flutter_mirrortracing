detach(unload = TRUE)
stopifnot(require(jsonlite)) # install.packages(c("jsonlite","png"))
stopifnot(require(png))

# NOTE: the path will have to change
input_csv_fn <- "~/Downloads/mirrortracing"

d_in <- read.csv(input_csv_fn, sep="\t", stringsAsFactors=FALSE)

g_debug <- TRUE


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

d_in = d_in[d_in$SubmissionId == "5961891",]

l_row_in <- d_in[1,]

img_bytes    <- jsonlite::base64_dec(as.character(l_row_in$image_png))
img          <- png::readPNG(img_bytes)
l_trajectory <- jsonlite::parse_json(json=as.character(l_row_in$trajectory))

system("make -C /home/fkrull/workspace/mirrortracing")
install.packages('../../../mirrortracing/mirrortracing_1.0.tar.gz',Ncpus=4); 
require(mirrortracing)

# qc_trajectory(l_trajectory, 1)

l_img <- NULL
l_img[["r"]] <- img[,,1]
l_img[["g"]] <- img[,,2]
l_img[["b"]] <- img[,,3]
l_img[["a"]] <- img[,,4]

# calc max distance (cm -> px)
cm2px <- ncol(img[,,1]) / l_row_in$image_width_cm;
px2cm <- 1/cm2px

system.time({
l_trajectory <- qc_trajectory(l_trajectory=l_trajectory, max_sample_dist_px=2*cm2px)
})

system.time({
l_img_out <- redraw_trajectory(l_img=l_img, l_trajectory=l_trajectory)
})

img[,,1] <- l_img_out[["r"]]
img[,,2] <- l_img_out[["g"]]
img[,,3] <- l_img_out[["b"]]
img[,,4] <- l_img_out[["a"]]

system.time({
l_rmsd <- calc_rmsd_px(star=img[,,2] | img[,,3], paint=img[,,1])
})

m_dists <- l_rmsd$dists
# convert to cm
m_dists <- m_dists * px2cm
vis_max_err_cm <- 5^2
m_dists[m_dists>vis_max_err_cm] <- vis_max_err_cm
m_dists <- m_dists / vis_max_err_cm
img[,,1] <- apply(m_dists,c(1,2),function(x) col2rgb(hsv((1-x)*0.9,1,1))[1]/255)
img[,,2] <- apply(m_dists,c(1,2),function(x) col2rgb(hsv((1-x)*0.9,1,1))[2]/255)
img[,,3] <- apply(m_dists,c(1,2),function(x) col2rgb(hsv((1-x)*0.9,1,1))[3]/255)

#img[,,1] <- hsv(h = m_dists, s = 1, v = 1, alpha=1)
plot.new()
rasterImage(img,0,0,1,1)

# img[,,2] <- 0

# for (line in l_trajectory) {
#   for (sample in line) {
#     x <- traj_x(sample)+1 # convert to R, 1-based index
#     y <- traj_y(sample)+1
#     cat(sprintf("x:%f, y:%f\n", x, y))
#     if (x < 1) next()
#     if (y < 1) next()
#     if (x > ncol(img)) next()
#     if (y > nrow(img)) next()
#     img[y,x,2] <- 1
#     img[y,x,4] <- 0
#   }
# }



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

print(pl1, position=c(0, .0, .5, .5), more=TRUE)
print(pl2, position=c(0, .5, 0.5, 1), more=TRUE)
print(pb1, position=c(0.5, .5, 1, 1), more=TRUE)
print(pb2, position=c(0.5, 0, 1, .5))
