shinyServer(function(input, output) {
  
  n_samples <- 300
  
  real_label <- reactive({
    input$digit
  })
  
  test_filtered <- reactive({
    test %>% 
      filter(labels == real_label()) %>% 
      sample_n(n_samples) %>% 
      as.matrix()
  })
  
  df <- reactive({
    # reactive vars
    real_label <- real_label()
    test_filtered <- test_filtered()
    # ++++++++++++
    
    ids <- test_filtered[, 1]
    labels <- test_filtered[, 2]
    features <- test_filtered[,3:ncol(test_filtered)] 
    
    body <- list(input = features)
    r <- POST("https://flask-digit-classifier.herokuapp.com/predict", body = body, encode = "json", verbose())
    # r <- POST("http://localhost:5000/predict", body = body, encode = "json", verbose())
    resp <- content(r)
    
    resp_ <- map(resp, ~ unlist(.x)) %>%
      unlist()
    
    df <- data_frame(prediction_prob = resp_, 
                     real_label = real_label,
                     ids = map(ids, ~ rep(.x, 10)) %>% unlist()) %>% 
      group_by(ids) %>% 
      dplyr::mutate(max_prob = prediction_prob == max(prediction_prob),
                    pred_label = as.integer(row_number() - 1)) %>% 
      ungroup()
    df
  })
  
  wrong_prediction_id <- reactive({
    # reactive vars
    real_label <- real_label()
    test_filtered <- test_filtered()
    df <- df()
    # ++++++++++++
    
    df %>% 
      group_by(ids) %>% 
      filter(max_prob == TRUE) %>% 
      filter(pred_label != real_label) %>% 
      .$ids
  })
  
  output$distPlot <- renderPlot({
    # reactive vars
    real_label <- real_label()
    test_filtered <- test_filtered()
    df <- df()
    wrong_prediction_id <- wrong_prediction_id()
    # ++++++++++++
    
    df %>% 
      filter(ids %in% wrong_prediction_id) %>% 
      mutate(pred_label = as.factor(pred_label),
             ids = as.factor(ids)) %>% 
      ggplot(aes(x = pred_label, y = prediction_prob, fill = ids)) +
      geom_col(position = "dodge", alpha = 0.5) +
      labs(y = "Predicted Probability", 
           x = "Possible Digits", 
           color = "Sample ID",
           title = "Incorrectly Classified",
           fill = "IDs")
  })
  
  output$correctlyClassifiedPlot <- renderPlot({
    # reactive vars
    real_label <- real_label()
    test_filtered <- test_filtered()
    df <- df()
    wrong_prediction_id <- wrong_prediction_id()
    # ++++++++++++
    
    df %>% 
      filter(!ids %in% wrong_prediction_id) %>% 
      mutate(pred_label = as.factor(pred_label),
             ids = as.factor(ids)) %>% 
      ggplot(aes(x = pred_label, y = prediction_prob)) +
      geom_jitter(alpha = 1/4) +
      labs(y = "Predicted Probability", 
           x = "Possible Digits", 
           fill = "Sample ID",
           title = "Correctly Classified")
  })
  
  output$digitPlot <- renderPlot({
    # reactive vars
    real_label <- real_label()
    test_filtered <- test_filtered()
    df <- df()
    wrong_prediction_id <- wrong_prediction_id()
    # ++++++++++++
    
    
    df %>% 
      filter(ids == input$wrongPredicitonsSelector) %>% 
      mutate(pred_label = as.factor(pred_label),
             ids = as.factor(ids)) %>% 
      ggplot(aes(x = pred_label, y = prediction_prob)) +
      geom_col(position = "identity") +
      labs(y = "Predicted Probability", x = "Possible Digits")
    
  })
  
  output$digitPlot2 <- renderPlot({
    # reactive vars
    real_label <- real_label()
    test_filtered <- test_filtered()
    df <- df()
    wrong_prediction_id <- wrong_prediction_id()
    # ++++++++++++
    
    test %>% 
      filter(ids == input$wrongPredicitonsSelector) %>%
      select(-labels, -ids) %>% 
      as.integer() %>% 
      matrix(nrow = 28, ncol = 28, byrow = F) %>% 
      DescTools::Rev(margin = 2) %>%
      image(axes = T, col = grey(seq(1, 0, length = 256)))
  })
  
  output$wrongPredicitonsSelector <- renderUI({
    # reactive vars
    wrong_prediction_id <- wrong_prediction_id()
    #+++++++++
    selectInput("wrongPredicitonsSelector", "Visualize misclassified digit (by ID):", wrong_prediction_id)
  })
})