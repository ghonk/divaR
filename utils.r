# # # setwd('C:/Users/garre/Dropbox/aa projects/DIVA')

# # backprop
# #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
backprop <- function(out_wts, in_wts, out_activation, current_target, 
                     hid_activation, hid_activation_raw, ins_w_bias, learning_rate){

  # # # calc error on output units
  out_delta <- 2 * (out_activation - current_target)
  
  # # # calc error on hidden units
  hid_delta <- out_delta %*% t(out_wts)
  hid_delta <- hid_delta[,2:ncol(hid_delta)] * sigmoid_grad(hid_activation_raw)
  
  # # # calc weight changes
  out_delta <- learning_rate * (t(hid_activation) %*% out_delta)
  hid_delta <- learning_rate * (t(ins_w_bias) %*% hid_delta)

  # # # adjust wts
  out_wts <- out_wts - out_delta
  in_wts <- in_wts - hid_delta

  return(list(out_wts = out_wts, 
              in_wts  = in_wts))

}

# forward_pass
# conduct forward pass
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
forward_pass <- function(in_wts, out_wts, inputs, out_rule) {
  # # # init needed vars
  num_feats <- ncol(out_wts)
  num_cats  <- dim(out_wts)[3]
  num_stims <- nrow(inputs)
  if (is.null(num_stims)) {num_stims <- 1}

  
  # # # add bias to ins
  bias_units <- matrix(rep(1, num_stims), ncol = 1, nrow = num_stims)
  ins_w_bias <- cbind(bias_units,
    matrix(inputs, nrow = num_stims, ncol = num_feats, byrow = TRUE))

  # # # ins to hids propagation
  hid_activation_raw <- ins_w_bias %*% in_wts
  hid_activation <- sigmoid(hid_activation_raw)

  # # # add bias unit to hid activation
  hid_activation <- cbind(bias_units, hid_activation)  

  # # # hids to outs propagation
  out_activation <- array(rep(0, (num_stims * num_feats * num_cats)), 
    dim = c(num_stims, num_feats, num_cats))
  # # NEED VECTORIZED HERE
  for (category in 1:num_cats) {
  	out_activation[,,category] <- hid_activation %*% out_wts[,,category]
  }
  
  # # # apply output activatio rule
  if(out_rule == 'sigmoid') {
  	out_activation <- sigmoid(out_activation)
  }

  return(list(out_activation     = out_activation, 
              hid_activation     = hid_activation,
              hid_activation_raw = hid_activation_raw, 
              ins_w_bias         = ins_w_bias))

}

# get_wts
# generate net weights
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
get_wts <- function(num_feats, num_hids, num_cats, wts_range, wts_center) {
  # # # set bias
  bias <- 1
  
  # # # generate wts between ins and hids
  in_wts <- 
    (matrix(runif((num_feats + bias) * num_hids), ncol = num_hids) - 0.5) * 2 
  in_wts <- wts_center + (wts_range * in_wts)

  # # # generate wts between hids and outs
  out_wts <- 
    (array(runif((num_hids + bias) * num_feats * num_cats), 
      dim = c((num_hids + bias), num_feats, num_cats)) - 0.5) * 2
  out_wts <- wts_center + (wts_range * out_wts)   
  
  return(list(in_wts  = in_wts, 
              out_wts = out_wts))

}

# global_scale
# scale inputs to 0/1
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
global_scale <- function(x) { x / 2 + 0.5 }

# response_rule
# convert output activations to classification
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
response_rule <- function(out_activation, target_activation, beta_val){
  num_feats <- ncol(out_activation)
  num_cats  <- dim(out_activation)[3]
  num_stims <- nrow(target_activation)
  if (is.null(num_stims)) {num_stims <- 1}

  # # # calc error  
  ssqerror <- array(as.vector(
    apply(out_activation, 3, function(x) {x - target_activation})),
      c(num_stims, num_feats, num_cats))
  ssqerror <- ssqerror ^ 2
  ssqerror[ssqerror < 1e-7] <- 1e-7
  
  # # # generate focus weights
  if(dim(out_activation)[3] > 2 | dim(out_activation)[1] > 1){
    stop('Not coded for >2 channels or batch mode, sorry!')
  } else {
    
    # # # candidate for errors:
    diversities <- 
      exp(beta_val * abs(matrix(dist(out_activation))[num_feats:((num_feats*2)-1)]))  
    diversities[diversities > 1e+7] <- 1e+7

    # divide diversities by sum of diversities
    fweights = diversities / sum(diversities)

    # # # apply focus weights; then get sum for each category
    ssqerror <- t(apply(ssqerror, 3, function(x) sum(x * fweights))) 
    ssqerror <- 1 / ssqerror
  }

return(list(ps       = (ssqerror / sum(ssqerror)), 
            fweights = fweights, 
            ssqerror = ssqerror))

}

# run_diva
# trains vanilla diva
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
run_diva <- function(model) {
  # # # extract model vars
  attach(model)
  # # # get new seed
  seed <- runif(1) * 100000 * runif(1)
  set.seed(seed)
  # # # set mean value of weights
  wts_center <- 0 
  # # # convert targets to 0/1
  targets <- global_scale(model$inputs) 
  
  # # # init size parameter variables
  num_feats   <- ncol(inputs)
  num_stims   <- nrow(inputs)
  num_cats    <- length(unique(labels))
  num_updates <- num_blocks * num_stims
  
  # # # init training accuracy matrix
  training <- 
    matrix(rep(NA, num_updates * num_inits), nrow = num_updates, ncol = num_inits)
  
  # # # initialize and run DIVA models
  for (model_num in 1:num_inits) {
  	
    # # # generate weights
  	wts_list <- get_wts(num_feats, num_hids, num_cats, wts_range, wts_center)
    attach(wts_list)

    # # # generate presentation order
  	prez_order <- as.vector(apply(replicate(num_blocks, seq(1, num_stims)), 
  	  2, sample, num_stims))

    # # # iterate over each trial in the presentation order 
    for (trial_num in 1:num_updates) {
      current_input  <- inputs[prez_order[[trial_num]], ]
      current_target <- targets[prez_order[[trial_num]], ]
      current_class  <- labels[prez_order[[trial_num]]] 

      # # # complete forward pass
      fp_result <- forward_pass(in_wts, out_wts, current_input, out_rule)
      attach(fp_result)

      # # # calculate classification probability
      rr_result <- response_rule(out_activation, current_target, beta_val)
      attach(rr_result)

      # # # store classification accuracy
      training[trial_num, model_num] = ps[current_class]

      # # # back propagate error to adjust weights
      class_wts <- out_wts[,,current_class]
      class_activation <- out_activation[,,current_class]

      adjusted_wts <- backprop(class_wts, in_wts, class_activation, current_target,  
               hid_activation, hid_activation_raw, ins_w_bias, learning_rate)

      out_wts[,,current_class] <- adjusted_wts$out_wts
      in_wts <- adjusted_wts$in_wts

      detach(fp_result)
      detach(rr_result)

    }
    
    detach(wts_list)
  
  }

training_means <- 
  rowMeans(matrix(rowMeans(training), nrow = num_blocks, ncol = num_stims, byrow = TRUE))
detach(model)
return(list(training = training_means))

}

# shj_cats
# loads shj category structures
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
shj_cats <- function(type){
  
  if (type == 1) {
    in_patterns <- 
      matrix(c(1,  1,  1,
	             1,  1, -1,
	             1, -1,  1,
  	           1, -1, -1,
	            -1, -1,  1,
	            -1, -1, -1,
	            -1,  1,  1,
	            -1,  1, -1), nrow = 8, ncol = 3, byrow = TRUE)		

  } else if (type == 2){
  	in_patterns <-
  	  matrix(c(1,  1,  1,
  	  	       1,  1, -1,
       	      -1, -1,	 1,
	            -1, -1, -1,
	            -1,	 1,	 1,
	            -1,	 1, -1,
	  	         1, -1,	 1,
		           1, -1, -1), nrow = 8, ncol = 3, byrow = TRUE)
  
  } else if (type == 3){
  	in_patterns <-
  	  matrix(c(1,  1,  1,
  	  	       1,  1, -1,
  	  	       1, -1,  1, 
  	          -1,  1, -1,
  	           1, -1, -1, 
  	          -1,  1,  1, 
  	          -1, -1,  1, 
  	          -1, -1, -1), nrow = 8, ncol = 3, byrow = TRUE)
  
  } else if (type == 4){
    in_patterns <-
      matrix(c(1,  1,  1,
               1,  1, -1,
               1, -1,  1,
              -1,  1,  1,
               1, -1, -1,
              -1,  1, -1,
              -1, -1,  1,
              -1, -1, -1), nrow = 8, ncol = 3, byrow = TRUE)
  
  } else if (type == 5){
    in_patterns <-
      matrix(c(1,  1,  1,
               1,  1, -1,
               1, -1,  1,
              -1, -1, -1,
               1, -1, -1,
              -1,  1,  1,
              -1,  1, -1,
              -1, -1,  1), nrow = 8, ncol = 3, byrow = TRUE)
  
  } else if (type == 6){
    in_patterns <-
      matrix(c(1,  1,  1,
               1, -1, -1,
              -1,  1, -1,
              -1, -1,  1,
               1,  1, -1,
               1, -1,  1,
              -1,  1,  1,
              -1, -1, -1), nrow = 8, ncol = 3, byrow = TRUE)
  }

cat_assignment <- c(1, 1, 1, 1, 2, 2, 2, 2)

return(list(inputs = in_patterns, 
			      labels = cat_assignment))

}

# sigmoid
# returns sigmoid evaluated elementwize in X
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
sigmoid <- function(x) {
  g = 1 / (1 + exp(-x))
  return(g)

}

# sigmoid gradient
# returns the gradient of the sigmoid function evaluated at x
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
sigmoid_grad <- function(x) {
  return(g = ((sigmoid(x)) * (1 - sigmoid(x))))

}