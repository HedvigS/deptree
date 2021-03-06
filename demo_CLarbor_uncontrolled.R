source("package_dependencies.R")
source("CLarbor_functions.R")

value_df <- read_tsv("data/tidied/value_df.tsv")

external_variable <- read_tsv("data/tidied/external_variables_df.tsv")

dep_matrix <- dependency_matrix_cond_MI(value_df)

write_tsv(dep_matrix %>% 
            as.data.frame() %>% 
            rownames_to_column(),
          "output/depmatrices/feature_dependencies_uncontrolled.tsv")

best_CLarbor <- CLarbor_from_dep_matrix_check_all_roots(dep_matrix, return.all = T)

best_CLarbor_df <- make_CLarbor_df(best_CLarbor$best.arbor)

write_tsv(as_tibble(best_CLarbor_df) %>% type_convert(), "output/CLarbors/best_CLarbor_uncontrolled.tsv")
write_file(best_CLarbor$root, "output/CLarbors/best_root_uncontrolled.txt")

all_CLarbors <- best_CLarbor$all.arbors
try(saveRDS(all_CLarbors, "output/CLarbors/all_CLarbors_uncontrolled.RDS"))
