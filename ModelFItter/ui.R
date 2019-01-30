###########################################################
# Author: Benjamin Mohn 
# Date: 25th of January 2019
# Porpuse: 3rd Assignement of Developing Data Products
###########################################################
library(caret)
library(shiny)
library(shinyjs)
require(xgboost)
require(elasticnet)
require(MASS)
require(HiDimDA)
require(C50)

# Setting default values
possible_data <- c(mtcars = "mtcars", 
                   faithful = "faithful",
                   chickWeight = "chickWeight",
                   insectSpray = "insectSpray",
                   iris = "iris",
                   toothGrowth = "toothGrowth",
                   orange = "orange"
)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Modelfitter"),
 
  # For this application the user is ask to do several inputs.
  # Since the inputs needs to be in an order, the panel and optinons 
  # Are hidden till the required inputs are done. 
  sidebarLayout(
    sidebarPanel(
        useShinyjs(),
        selectInput(
                "dataset", "Select a data set:", possible_data
                ),
        checkboxGroupInput(
                "xVars",
                "Please choose at least one variable you want to use as feature.",
                character(0)
                ),
        radioButtons(
                "yVar", "Select the y Variable", c(1,2)
                ),
        radioButtons(
                "algo", "Select a model", c(1,2)
                ),
        actionButton(
                "calculate", "Start calculation"
                )
       ),
    
    # Show a plot of the generated distribution
    mainPanel(
       
       h1("Here is the output for your model!"),
       
       h2("Result"),
       tableOutput("result"),
       
       h2("The model"),
       textOutput("final"),
       
       h2("The Plot"),
       plotOutput("model_plot")
    )
  )
 )
)
