
source('utils.r')

# # # issue - weights seem to not update between model runs
# # # issue - fweights are not accurate
# # # test out diagonal approach for pairwise diffs w n>2 cats

# # # Initialize model parameters
model <- list(num_blocks    = 20,
			  num_inits     = 5,
			  wts_range     = 1,
			  num_hids      = 3,
			  learning_rate = 0.15,
			  beta_val      = 5,
			  out_rule      = 'sigmoid') # linear / tan not implemented

training = matrix(rep(0, model$num_blocks * 6), ncol = 6)
for (shj in 1:6) { 
  
  # # # get shj stimuli
  cases <- shj_cats(shj)
  model$inputs <- cases$inputs
  model$labels <- cases$labels

  # # # train model
  result <- run_diva(model)

# # # add result to training matrix
training[,shj] <- result$training

}

# display results
print(training)
train_plot(training)
save.image('diva_run.rdata')

# warnings()


