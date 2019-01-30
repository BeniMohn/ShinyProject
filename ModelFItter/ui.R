###########################################################
# Author: Benjamin Mohn 
# Date: 25th of January 2019
# Porpuse: 3rd Assignement of Developing Data Products
###########################################################
library(caret)
library(shiny)
library(shinyjs)
require(xgboost)
require(plyr)
require(e1071)
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
        tabsetPanel(type = "tabs", 
                    tabPanel("Application",
                             h1("Here is the output for your model!"),
                             h2("Result"),
                             tableOutput("result"),
                             h2("The model"),
                             textOutput("final"),
                             h2("The Plot"),
                             plotOutput("model_plot")),
                    tabPanel("Description", 
                             h2("Description"),
                             br(), 
                             "Welcome to the Modelfitter Application.",
                             "This documentation is further divided into input and output.",
                             "Within Input I am going to explain the input whereas on the output I am going to focus on the otput, that will be created.",
                             br(),br(), 
                             "The idea of the Modelfitter is to fit any model that you want on one of the build in datasets of the R package.",
                             "Unfortunatly not all possible models are possible and changing hyperparameters is not possible either.",
                             "To fit the different model the caret package is used. This has couple of advantages.",
                             "First of all the syntax amoung the models stays the same and nothing to be woried in training or predicting.",
                             "Secondly selecting a model is as easy as setting one parameter in the funtion call to caret.",
                             br(),br(),
                             "In the input tab you will find which models are possible and which of the build in datasets you can choose from.",
                             "The output tab will explain what you can expect as an output.",
                             tabsetPanel(type="tabs",
                                         tabPanel("Input",
                                                  h3("Overview"),
                                                  "All in all there are 5 Ui elements the user (you) can interact with.",
                                                  "I will explain each of the element allone. The structure for this description will be only be the same.",
                                                  "At the beginning I will put the General description, afterwards the values and last but not least the side effects that occour when interacting with the element.",
                                                  br(),
                                                  tabsetPanel(type="tabs",
                                                              tabPanel("Dataset",
                                                                       h4("General"),
                                                                       "The input type to choose a data set is a dropdown menu, in there you can select 1 out of 7 build in datasets.",
                                                                       "This dataset will then be used in order to fit a model that you desire.",
                                                                       "Be aware that the model will be fit on the entire dataset. There is no option to set a test-train-split.",
                                                                       h4("Options"),
                                                                       "Following are the possible choices you have: ",
                                                                       br(),br(),
                                                                       "1. mtcars ",
                                                                       br(),br(),
                                                                       "2. faithful",
                                                                       br(),br(),
                                                                       "3. chickWeight",
                                                                       br(),br(),
                                                                       "4. insectSpray",
                                                                       br(),br(),
                                                                       "5. iris",
                                                                       br(),br(),
                                                                       "6. toothGrowth",
                                                                       br(),br(),
                                                                       "7. orange",
                                                                       h4("Side effects"),
                                                                       "Depending on the choice of the dataset the choices for the features and regressor will change.",
                                                                       "What are the options for thoose fields you will find in the respecive tabs.",
                                                                       "In case any feature has been selected already, then this selection will be removed, if a new dataset was seletced."
                                                                       ),
                                                              tabPanel("Features",
                                                                       h4("General"),
                                                                       "Here you are able to select up to two columns of the dataset you want to use in order to predict a other column of the dataset.",
                                                                       "The choice is made with the help of checkboxes.",
                                                                       "The app does not work as long as not at least one feature is beeing selected.",
                                                                       "As stated in the description of the dataset, the choices here will be invalidated, once a new dataset is selected.",
                                                                       h4("Options"),
                                                                       "The options here are all column names the choosen dataset has.",
                                                                       h4("Side effects"),
                                                                       "Here a couple of sideeffects are to be observed.",
                                                                       "Each of the other choices this one has an influence on will be described seperatly.",
                                                                       h5("Features"),
                                                                       "This field has an influence on itself in the following way.",
                                                                       "With each selection done, the header will change, telling you how many features you are free to choose.",
                                                                       "On the other hand, once to features are being choosen, all other choices will disappear.",
                                                                       "By this the user only can unselect a option and there for not chose more than two colomns.",
                                                                       h5("Regressor"),
                                                                       "A field that is selected as feature can not be selected as regressor.",
                                                                       "Once a feature variable is gone, it will be removed from the possiblilities in the regressor.",
                                                                       "This code mean as well, that the current choosen regressor gets removed, in this case the first element will be selected as default.",
                                                                       h5("Start Calulation"),
                                                                       "Lastly this field has influence on the Start Calculation button. As long as not feature is selected, the button is hidden.",
                                                                       "By this approach the user is forced to select at least one feature, otherwise no model can be calculated."
                                                                       ),
                                                              tabPanel("Regressor",
                                                                       h4("General"),
                                                                       "This is radio button input, therefore the user can only select one field here. This field will be the target variable in the prediction model.",
                                                                       "The default option is allways the column listed at the top of this selection.",
                                                                       h4("Options"),
                                                                       "Basically the options here are as well the columns of the chosen data set, excluding the ones selected as features.",
                                                                       h4("Side effects"),
                                                                       "The selection here is having impact on the available models. If the selected regressor is a continuos variable models for regression will be shown.",
                                                                       "In case that the regressor is a factor, than classification algorithms are shown to the user.",
                                                                       "Forther details will be shown on the Model tab.",
                                                                       "Similar as for the Features, it code happen, that due to changing the regressor, the current choice of model is not suitable anymore, in this case the default value is again the first model in the list."
                                                                       ),
                                                              tabPanel("Model",
                                                                       h4("General"),
                                                                       "Here the user is able to select a model, that (s)he would like to fit on the data.",
                                                                       "The available models are taken from the caret package. The choice is as well done via a radio button.",
                                                                       "Again the idea here is, that just one selection should be possible.",
                                                                       h4("Options"),
                                                                       "Based on the regressor, the models can differ. Nevertheless for each variant there are 5 models to choose from.",
                                                                       "Out of these 5 models two are valid both classes, therefore the number of supplied models is 8.",
                                                                       "In the following list the choices are to be listed. I will distinguish three sections, first common (where the two model valid for both cases are shown and then the other two cases.",
                                                                       h5("Common Models"),
                                                                       "1. xgbTree ",
                                                                       br(),br(),
                                                                       "2. knn",
                                                                       h5("Regression Models"),
                                                                       "1. lm",
                                                                       br(),br(),
                                                                       "2. ridge",
                                                                       br(),br(),
                                                                       "3. glm",
                                                                       h5("Classification Models"),
                                                                       "1. lda",
                                                                       br(),br(),
                                                                       "2. Mlda",
                                                                       br(),br(),
                                                                       "3. C5.0Tree",
                                                                       h4("Side effects"),
                                                                       "This is the only input that does not have any side effect on the other input fields."
                                                                       ),
                                                              tabPanel("Start Calculation",
                                                                       h4("General"),
                                                                       "This input is simply button, which starting the model fit process.",
                                                                       "Porpuse of this button is that the user can choose any setup that (s)he wants, without having to wait for the reload of the model.",
                                                                       "Once a model is created, the user cann still use the App and start fitting the next model.",
                                                                       h4("Options"),
                                                                       "The option here is to click or not click the button. Of course this is only possible, while the button is shown",
                                                                       "In other word you need to select a feature in order to be able clicking the button.",
                                                                       h4("Side effects"),
                                                                       "Side effect here is nothing on the input.",
                                                                       "But the output will be calculated and shown to the user."
                                                                       )
                                                              )
                                                  ),
                                         tabPanel("Output",
                                                  h3("Overview"),
                                                  "On this page the output generated is going to be described.",
                                                  "Of course the output differs among the models slightly thats way I will explain how to get this output.",
                                                  "Overall three different output are genrated. First the result, then model information and lastly plots.",
                                                  "Similar as for the input I am going to use one tab per output.",
                                                  "At first I am going to describe the output and then explain how it can be recreated.",
                                                  "For the plot this strucure will be slightly modified.",
                                                  "Each of the sections contains as well an example, which could be reproduced using the app.",
                                                  "Have fun finding out how it is being created. ;-)",
                                                  tabsetPanel(type="tabs",
                                                              tabPanel("Result",
                                                                       h4("General"),
                                                                       "This is the first output generated by the server.R function.",
                                                                       "Basically this is the table showing different precision values that were received during training.",
                                                                       "This is a auto generated output.",
                                                                       h4("Creation"),
                                                                       "Supposed you have a variale called model, which is holding a model that was trained using caret.",
                                                                       "In order to get the table that is shown only thing you have to do is: model$results.",
                                                                       h4("Example"),
                                                                       tableOutput("exmapleTable")),
                                                              tabPanel("Model Info",
                                                                       h4("General"),
                                                                       "This output is holding some genreal information about the model that was fitted.",
                                                                       "As the outher output this can differ quiete a lot from model to model.",
                                                                       "In this case the output is not a table but plain text.",
                                                                       h4("Creation"),
                                                                       "Supposed you have a variale called model, which is holding a model that was trained using caret.",
                                                                       "Then this output could be reproduced doing: model$finalModel",
                                                                       h4("Example"),
                                                                       textOutput("exmapleText")
                                                                       ),
                                                              tabPanel("Plot",
                                                                       h4("General"),
                                                                       "The idea behind the plot shown is to give a feeling of how well the model did or not.",
                                                                       "In order to display the model the render plot was used.",
                                                                       "There are basically three different plot types to be distinguished according to the given input.",
                                                                       "Thoose three types will explained in the plot types section and a axample for each of them will be given in the example section.",
                                                                       h4("Plot types"),
                                                                       "As mentioned before there are three different types to be distinguished.",
                                                                       "Thoose are the types, how I call them, I will explain them afterwards:",
                                                                       br(), br(),
                                                                       "1. Residual Plot",
                                                                       br(), br(),
                                                                       "2. Bar Plot",
                                                                       br(), br(),
                                                                       "3. Scatter Plot",
                                                                       br(), br(),
                                                                       "For each of the plots I am going to explain the input setting it is used for and how it is calcuated.",
                                                                       h5("Residual Plot"),
                                                                       "This plot is supposed to be similar to the one that we used to have in one of the earlier corses in the data science course group.",
                                                                       "In order to get this plot a regression variable is to be used.",
                                                                       br(), br(),
                                                                       "To create this plot, the difference between the prediction and the real value are taken.",
                                                                       "Please keep in mind at this point, that trainingset and testset are allways the same in this app.",
                                                                       "This means, that the prediction is performed on the same data, that was used for training the model.",
                                                                       "In the plot it self, the y-axis shows the difference and the x-axis shows the real value.",
                                                                       "By this setup a perfectly trained model would have a horizontal line at 0.",
                                                                       "In oder to show this, there is a horizontal line in red at the value cero added.",
                                                                       h5("Bar Plot"),
                                                                       "This plot is used, when the regressor variable is a factor. In otherwords a classification model was trained.",
                                                                       "In addition for this plot to be shown, there should only one feature be selected.",
                                                                       br(), br(),
                                                                       "In order to creat the plot at first it was checked, where the model did a predict the correct class and where not.",
                                                                       "At the second time, the feature variable is made a factor of size: n/10 gorups.",
                                                                       "n in this case refers to the samples in the dataset. In case the quotient evaluetes to 1, the default value 2 is used.",
                                                                       "For each of the groups it is counted how often the model predicted the right class and how often a wrong class.",
                                                                       "This data is then shown in a stacked bar plot, where the x-axis shows the feature as factor and the y variable is the counts.",
                                                                       h5("Scatter Plot"),
                                                                       "In order to get the last possible plot, again a classification needs to be oerformed, but this time with two feature variables.",
                                                                       br(), br(),
                                                                       "All that this plot is shown is the dataset as a scatter plot, where the x-axis is one of the features and the y-axis shows the other.",
                                                                       "The color of the dot, representing a observation, while tell you, whether or not the model predicted correctly the class of this observation.",
                                                                       h4("Examples"),
                                                                       h5("Residual Plot"),
                                                                       plotOutput("examplePlot1"),
                                                                       h5("Bar Plot"),
                                                                       plotOutput("examplePlot1"),
                                                                       h5("Scatter Plot"),
                                                                       plotOutput("examplePlot1")
                                                                       )
                                                              
                                                              )
                                                  )
                                         )
                             )
       )
    )
  )
 )
)
