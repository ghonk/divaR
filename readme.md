# DIVA
## DIVergent Autoencoder, Artifical Neural Network Classifier 
### Implemented in R

This repository includes a collection of functions that implement the DIVA artificial neural network classification architecture in R. Executing `source('init.r')` from within the repository's local diectory runs a demonstration of the model on 7 category structures (the classic Shepard, Hovland and Jenkins [(1961)](http://psycnet.apa.org/journals/mon/75/13/1/) elemental category structures and a 4-class problem) and returns the resulting training accuracy, an accuracy plot and an `.rdata` file with the result.    

First, load the model functions

```
source('utils.r')
```

The model takes a list object named `model`

It contains the networks hyperparameters (defaults below)
```
model <- list(
  num_blocks    = 20,
  num_inits     = 5,
  wts_range     = 1,
  num_hids      = 3,
  learning_rate = 0.15,
  beta_val      = 5,
  out_rule      = 'sigmoid')
```

The inputs are saved as a matrix in `model$inputs`

The catgeory labels are saved as a vector in `model$labels`

```
cases <- demo_cats(category_type)
  model$inputs <- cases$inputs
  model$labels <- cases$labels
```

Run the model with 
```
result <- run_diva(model)
```

Shepard, R. N., Hovland, C. I., & Jenkins, H. M. (1961). Learning and memorization of classifications. Psychological monographs: General and applied, 75(13), 1.
