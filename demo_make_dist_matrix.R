library(tidyverse)
library(cluster)

data <- read_tsv("data/tidied/value_df.tsv") %>% 
  column_to_rownames("ID") 

#We're making 3 sets of distances matrices:
#entirely unweigthed
#weighted by Clarbor but not controlled for the external factors
#weighted by CLarbor and controlled for external factors.

#the weighted ones will be approximated to euclidean distances by squaring the weights and taking the square roots of the distance matrix.

#unweighted distances
gower_dist_unweighted <- as.matrix(daisy(data, metric = "gower")) %>% 
  sqrt()

write_tsv(as.data.frame(gower_dist_unweighted), "output/distance_matrices/unweighted_dist.tsv")

#weighted distances but uncontrolled for external factors
CLarbor_uncontrolled_weights <- read_tsv("output/CLarbors/best_CLarbor_uncontrolled.tsv") %>% 
  mutate(Weight = if_else(Weight <= .Machine$double.eps, 0, Weight)) %>% 
  dplyr::select(-Dependency) %>% 
  rename(to = `Target feature`, weight = Weight, from = `Source feature`) %>%   
  distinct(to, weight, .keep_all = T) 

#roots don't have any incoming edges and therefore no weight, we will here find them and set their weights to 1
CLarbor_uncontrolled_roots <- CLarbor_uncontrolled_weights %>% 
  filter(!(from %in% to)) %>%
  dplyr::select(from) %>% 
  distinct() %>% 
  rename(to = from) %>%
  mutate(weight = 1)

Clarbor_uncontrolled_weights_incl_roots <- CLarbor_uncontrolled_weights %>% 
  full_join(CLarbor_uncontrolled_roots) %>% 
  dplyr::select(-from) %>% 
  right_join(tibble(to = colnames(data))) %>% 
  mutate(weight = replace_na(weight, 0))

gower_dist_weighted_uncontrolled <- as.matrix(daisy(data, metric = "gower", weights = Clarbor_uncontrolled_weights_incl_roots$weight^2)) %>% 
  sqrt()

write_tsv(as.data.frame(gower_dist_weighted_uncontrolled), "output/distance_matrices/weighted_uncontrolled_dist.tsv")

#weighted distances and controlled for external factors
CLarbor_controlled_weights <- read_tsv("output/CLarbors/best_CLarbor_controlled.tsv") %>% 
  mutate(Weight = if_else(Weight <= .Machine$double.eps, 0, Weight)) %>% 
  dplyr::select(-Dependency) %>% 
  rename(to = `Target feature`, weight = Weight, from = `Source feature`) %>%   
  distinct(to, weight, .keep_all = T)

#roots don't have any incoming edges and therefore no weight, we will here find them and set their weights to 1
CLarbor_controlled_roots <- CLarbor_controlled_weights %>% 
  filter(!(from %in% to)) %>% 
  dplyr::select(from) %>% 
  distinct() %>% 
  rename(to = from) %>%
  mutate(weight = 1)

Clarbor_controlled_weights_incl_roots <- CLarbor_controlled_weights %>% 
  full_join(CLarbor_controlled_roots) %>% 
  dplyr::select(-from) %>% 
  right_join(tibble(to = colnames(data))) %>% 
  mutate(weight = replace_na(weight, 0)) 

gower_dist_weighted_controlled <- as.matrix(daisy(data, metric = "gower", weights = Clarbor_controlled_weights_incl_roots$weight^2)) %>% 
  sqrt()

write_tsv(as.data.frame(gower_dist_weighted_controlled), "output/distance_matrices/weighted_controlled_dist.tsv")