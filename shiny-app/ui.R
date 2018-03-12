library(shiny)
library(glue)
shinyUI(fluidPage(
  
  titlePanel("Digit Recognition Neural Network"),
  
  sidebarLayout(
    sidebarPanel(
      glue("This Shiny App queries a Flask API that delivers predictions of ",
           "a neural network on handwritten digits. The neural net was trained on the MNSIT dataset with Keras. ",
           "We hope that by playing aroung with the app, you can develop ",
           "a better intuition about how the neural network makes its prediction, ",
           "and identify the areas ",
           "at which it excels and specially those areas where it falls short.",
           "\n"),
      h4("How the application works: "),
      "\n",
      glue("Using the slider below, you can choose one out of ten digits. ",
           "The Shiny App will then send a batch of 300 observations with the chosen digit of the MNIST test ",
           "set to the Flask API ",
           "which in turn will return the prediciton for each one of them.",
           "Correctly and incorrectly classified digits are visualized in different ways, ",
           "because the amount of correctly classified digits is much bigger (98% is the accuracy of this model)."),
      br(),
      br(),
      sliderInput("digit",
                  "Get prediciton for:",
                  min = 0,
                  max = 9,
                  value = 5)
    ),
    mainPanel(
      splitLayout(cellWidths = c("50%", "50%"), 
                  plotOutput("distPlot"), 
                  plotOutput("correctlyClassifiedPlot"))
      
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      glue("In the dropdown menu below, you pick each misclassidied digit ", 
           "individually to see what it looks like and what probabilities ",
           "the algorithm has assigned to it."),
      br(), 
      br(), 
      uiOutput("wrongPredicitonsSelector")),
    mainPanel(
      fluidRow(
        splitLayout(cellWidths = c("50%", "50%"), plotOutput("digitPlot"), plotOutput("digitPlot2"))
      )
    )
  )
))


