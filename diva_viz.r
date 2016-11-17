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
      # # # change plot setup
      par(mfrow=c(2, 3))
      
      a_data <- prez_data[comp_results[[cat_type]]$model$labels == 1,]
      b_data <- prez_data[comp_results[[cat_type]]$model$labels == 2,]
      
      for (dim_plot_num in 1:3) {
        # # # create plot
        idx_plot <- scatterplot3d(a_data[,1], a_data[,2], a_data[,3], pch = '', 
      	  xlim = c(0,1), ylim = c(0,1), zlim = c(0,1), 
      	  xlab = 'hidden_one', ylab = 'hidden_two', zlab = 'hidden_three')
      	
        # # # get img coords
      	idx_plot_coords_a <- 
      	  idx_plot$xyz.convert(a_data[,1], a_data[,2], a_data[,3])
      	idx_plot_coords <- 
          idx_plot$xyz.convert(prez_data[,1], prez_data[,2], prez_data[,3])
        
        # # # print exemplars
        for (exemp_image in 1:length(all_images)) {
          if ((comp_results[[cat_type]]$model$label[[exemp_image]] == 1) == TRUE) {
            rasterImage(all_images[[exemp_image]], 
              idx_plot_coords$x[exemp_image], idx_plot_coords$y[exemp_image], 
              idx_plot_coords$x[exemp_image] + .75, idx_plot_coords$y[exemp_image] + .75)
          }
        }

        title(main = NULL)
        if (dim_plot_num == 2) {
          title(main = paste0('DIVA Channel A Hidden Activation - Block ', i, ' Catgeory: ', cat_type))
        }

        color_vec <- 
          as.numeric(substr(rownames(prez_data[comp_results[[cat_type]]$model$labels == 1,]),
            dim_plot_num, dim_plot_num)) + 1

        text(idx_plot_coords_a$x, idx_plot_coords_a$y, labels = rownames(a_data), 
          col = c('purple', 'darkgreen')[color_vec], cex = 1.5)
      }

      for (dim_plot_num in 1:3) {
        # # # create plot
        idx_plot <- scatterplot3d(b_data[,1], b_data[,2], b_data[,3], pch = '', 
          xlim = c(0,1), ylim = c(0,1), zlim = c(0,1), 
          xlab = 'hidden_one', ylab = 'hidden_two', zlab = 'hidden_three')
        
        # # # get img coords
        idx_plot_coords_b <- 
          idx_plot$xyz.convert(b_data[,1], b_data[,2], b_data[,3])
        idx_plot_coords <- 
          idx_plot$xyz.convert(prez_data[,1], prez_data[,2], prez_data[,3])
        
        # # # # print exemplars
        for (exemp_image in 1:length(all_images)) {
          if ((comp_results[[cat_type]]$model$label[[exemp_image]] == 2) == TRUE) {
            rasterImage(all_images[[exemp_image]], 
              idx_plot_coords$x[exemp_image], idx_plot_coords$y[exemp_image], 
              idx_plot_coords$x[exemp_image] + .75, idx_plot_coords$y[exemp_image] + .75)
          }
        }

        title(main = NULL)
        if (dim_plot_num == 2) {
          title(main = paste0('DIVA Channel B Hidden Activation - Block ', i, ' Catgeory: ', cat_type))
        }
        
        color_vec <- 
          as.numeric(substr(rownames(prez_data[comp_results[[cat_type]]$model$labels == 1,]),
            dim_plot_num, dim_plot_num)) + 1

        text(idx_plot_coords_b$x, idx_plot_coords_b$y, labels = rownames(b_data), 
          col = c('purple', 'darkgreen')[color_vec], cex = 1.5)
      }

    	ani.pause()
    
    }}, movie.name = paste0('type_', cat_type, '.gif'), ani.width = 1500, ani.height = 1200
  )
}
