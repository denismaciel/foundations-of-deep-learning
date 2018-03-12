library(httr)
library(tidyverse)

# Read in the MNIST test dataset
test <- read_csv("./data/mnist_test.csv", col_names = FALSE)

# Rename the first column to name and add id
test <- test %>% 
  rename(labels = X1) %>% 
  mutate(ids = 1:nrow(.)) %>% 
  select(ids, labels, everything())

# Pick one digit and sample n_samples of it to get prediction for
digit <- 2L
n_samples <- 500

test_filtered <- test %>% 
  filter(labels == digit) %>% 
  sample_n(n_samples)

ids <- test_filtered$ids
labels <- test_filtered$labels

features <- test_filtered %>% 
  select(matches("X\\d{1,3}")) %>% 
  as.matrix() 

body <- list(input = features)
r <- httr::POST("http://localhost:5000/predict",
                body = body,
                encode = "json")
r_content <- content(r)

prediction_prob <- r_content %>%
  map(~ unlist(.x)) %>%
  unlist()

df <- data_frame(
  prediction_prob, 
  digit,
  ids = ids %>%
    map(~ rep(.x, 10)) %>%
    unlist()
  ) %>% 
  group_by(ids) %>% 
  mutate(
    is_max_prob = prediction_prob == max(prediction_prob),
    pred_label = as.integer(row_number() - 1)
  ) %>%
  ungroup()

# Accuracy of Predictions
df %>% 
  filter(is_max_prob) %>% 
  mutate(is_correct_prediction = digit == pred_label) %>% 
  pull(is_correct_prediction) %>% 
  table()

p <- df %>% 
  filter(is_max_prob) %>% 
  count(pred_label) %>% 
  filter(n != max(n)) %>% 
  mutate(pred_label = factor(pred_label, levels = 0:9)) %>% 
  ggplot(aes(x = pred_label, y = n)) +
  geom_col() +
  scale_x_discrete(drop = FALSE) +
  labs(title = glue::glue("Wrong predictions count for digit {digit}"),
       y = NULL,
       x = "Predicted Label") +
  theme_minimal()
p
ggsave(plot = p, filename = "../paper/img/wrong_predictions.jpeg")
