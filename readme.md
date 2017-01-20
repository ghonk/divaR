# DIVA
## DIVergent Autoencoder, Artifical Neural Network Classifier 
### Implemented in R (see also N. Conaway's [Matlab implementation](https://github.com/nolanbconaway/DIVA))

This repository includes a collection of functions that implement the DIVA artificial neural network classification architecture in R (Kurtz, [2007](http://link.springer.com/article/10.3758/BF03196806); [2015](http://www.sciencedirect.com/science/article/pii/S0079742115000146)). Executing `source('init.r')` from within the repository's local diectory runs a demonstration of the model on 7 category structures (the classic Shepard, Hovland and Jenkins [(1961)](http://psycnet.apa.org/journals/mon/75/13/1/) elemental category structures and a 4-class problem) and returns the resulting training accuracy, an accuracy plot and an `.rdata` file with the result. A *brief* tutorial follows.    

### Tutorial
First, load the model functions

```
source('utils.r')
```

The model takes a list object named `model`

It contains the network's hyperparameters (defaults below), inputs, and class labels.
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

The class labels are saved as a vector in `model$labels`

```
cases <- demo_cats(category_type)
  model$inputs <- cases$inputs
  model$labels <- cases$labels
```

Run the model with 
```
result <- run_diva(model)
```

Note (adapted from [original DIVA repo](https://github.com/nolanbconaway/DIVA))

For almost all situations, inputs should be scaled to [-1 +1]. However, the target activations should be scaled to [0 1], in order to permit logistic output units. By default, the program automatically computes targets as scaled versions of the inputs (`targets <- inputs / 2 + 0.5`). This is done in utils.r, `run_diva` function.

By default, DIVA uses linear output units for continuous datasets, and logistic outputs for binary datasets. This option is set using outputrule: 'sigmoid' for logistic units, other values will result in linear. When linear outputs are used, SSE will be the error measure. Cross-entropy error is used for logistic outputs. Hidden units are always logistic.


### References
Kurtz, K. J. (2007). The divergent autoencoder (DIVA) model of category learning. Psychonomic Bulletin & Review, 14(4), 560-576.

Kurtz, K. J. (2015). Chapter Three-Human Category Learning: Toward a Broader Explanatory Account. Psychology of Learning and Motivation, 63, 77-114.

Shepard, R. N., Hovland, C. I., & Jenkins, H. M. (1961). Learning and memorization of classifications. Psychological monographs: General and applied, 75(13), 1.
