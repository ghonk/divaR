# setwd('C:/Users/garre/Dropbox/aa projects/DIVA/r')

source('init.r')

load('diva_run.rdata')

library(animation)
library(scatterplot3d)
library(png)
library(raster)

# # # get images
image_list <- paste0('img/', dir('img/'))

# # # read images as PNG
all_images <- lapply(image_list, readPNG)

# # # name images in the list
names(all_images) <- substr(image_list, 5, 7) 

for (cat_type in 1:length(comp_results)) {
  saveGIF({
    for (i in 1:dim(comp_results[[cat_type]]$model$hid_acti_list[[1]])[3]) {
      # # # grab hidden activation for block i
      prez_data <- t(comp_results[[cat_type]]$model$hid_acti_list[[1]][,,i])
      # # # name rows in hidden activation/block matrix
      rownames(prez_data) <- c('000', '001', '010', '011', '100', '101', '110', '111')
    	# # # set GIF interval
    	ani.options(interval = .06)
      # # # change plot magrins
      par(mar=c(6.1,5.1,7.1,3.1))
      
      # # # create plot
      idx_plot <- scatterplot3d(prez_data[,1], prez_data[,2], prez_data[,3], pch = '', 
    	  xlim = c(0,1), ylim = c(0,1), zlim = c(0,1), 
    	  xlab = 'hidden_one', ylab = 'hidden_two', zlab = 'hidden_three',
    	  main = paste0('DIVA Hidden Activation - Block ', i, ' Catgeory: ', cat_type))
    	
      # # # get img coords
    	idx_plot_coords <- 
    	  idx_plot$xyz.convert(prez_data[,1], prez_data[,2], prez_data[,3])
    	
      # # # print exemplars
      for (i in 1:length(all_images)) {
        rasterImage(all_images[[i]], idx_plot_coords$x[i], idx_plot_coords$y[i], 
          idx_plot_coords$x[i] + .75, idx_plot_coords$y[i] + .75)
      }

      text(idx_plot_coords$x, idx_plot_coords$y, labels = rownames(prez_data), 
        col = c('red', 'blue')[comp_results[[6]]$model$labels])

    	ani.pause()
    
    }}, movie.name = paste0('type_', cat_type, '.gif'), ani.width = 600, ani.height = 600
  )
}
