
source('utils.r')

# # # test out diagonal approach for pairwise diffs w n>2 cats

# # # Initialize model parameters
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
model <- list(num_blocks    = 20,
			  num_inits     = 5,
			  wts_range     = 1,
			  num_hids      = 3,
			  learning_rate = 0.15,
			  beta_val      = 5,
			  out_rule      = 'sigmoid') # linear / tan not implemented

#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# # # run demo ? 
demo <- TRUE  # run demo
# demo <- FALSE # run something else

if (demo == TRUE) {
  # # # create training results 
  training = matrix(rep(0, model$num_blocks * 7), ncol = 7)
  
  # # # initialize model and run it on each SHJ category structure
  for (shj in 1:7) { 
  	print(shj)
    # # # get shj stimuli
    cases <- shj_cats(shj)
    model$inputs <- cases$inputs
    model$labels <- cases$labels

    # # # train model
    result <- run_diva(model)

  # # # add result to training matrix
  training[,shj] <- result$training

  }

  # # # display results
  print(training)
  train_plot(training)
  save.image('diva_run.rdata')
}

# warnings()


