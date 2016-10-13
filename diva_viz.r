source('init.r')

load('diva_run.rdata')

library(animation)
library(scatterplot3d)

saveGIF({
  for (i in 1:dim(comp_results[[6]]$model$hid_acti_list[[1]])[3]) {
    prez_data <- t(comp_results[[6]]$model$hid_acti_list[[1]][,,i])
    rownames(prez_data) <- c('000', '001', '010', '011', '100', '101', '110', '111')
  	
  	ani.options(interval = .06)

  	idx_plot <- scatterplot3d(prez_data[,1], prez_data[,2], prez_data[,3], pch = '', 
  	  xlim = c(0,1), ylim = c(0,1), zlim = c(0,1), 
  	  xlab = 'hidden_one', ylab = 'hidden_two', zlab = 'hidden_three',
  	  main = paste0('DIVA Hidden Activation - Block ', i))
  	
  	idx_plot_coords <- 
  	  idx_plot$xyz.convert(prez_data[,1], prez_data[,2], prez_data[,3])
  	text(idx_plot_coords$x, idx_plot_coords$y, labels = rownames(prez_data), 
  	  col = c('red', 'blue')[comp_results[[6]]$model$labels])

  	ani.pause()
  
  }}, movie.name = 'type1.gif', ani.width = 600, ani.height = 600
)

