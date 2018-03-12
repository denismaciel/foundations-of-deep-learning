library(DescTools)
library(shiny)
library(httr)
library(jsonlite)
library(tidyverse)

test <- read_csv("./data/mnist_test.csv", col_names = FALSE)

# rename the first column to name and add id
colnames(test)[1] <- "labels"
test$ids <- 1:nrow(test)
test <- test %>% select(ids, labels, everything())
