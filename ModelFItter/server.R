###########################################################
# Author: Benjamin Mohn 
# Date: 25th of January 2019
# Porpuse: 3rd Assignement of Developing Data Products
###########################################################

library(shiny)
library(shinyjs)

regression_models <- c(
        lm="lm",
        ridge="ridge",
        glm = "glm",
        xgbTree = "xgbTree",
        knn="knn"
)
class_models <- c(
        lda="lda",
        Mlda = "Mlda",
        C5.0Tree="C5.0Tree",
        xgbTree = "xgbTree",
        knn="knn"
)



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
        observe({
                data_frame <- 
                        switch(input$dataset,
                               "mtcars" = datasets::mtcars,
                               "faithful" = datasets::faithful,
                               "chickWeight" = datasets::ChickWeight,
                               "insectSpray" = datasets::InsectSprays,
                               "iris" = datasets::iris,
                               "toothGrowth" = datasets::ToothGrowth,
                               "orange" = datasets::Orange
                                )
                yVar <- input$yVar
                xVars <- c(input$xVars)
                model <- input$algo
                choices <- names(data_frame)
                if (all(is.element(xVars,choices))){
                        left_overs <- setdiff(names(data_frame), xVars)
                } else {
                        xVars <- c()
                        left_overs <- choices
                }
                nr_left <- length(left_overs)
                nr_choosen <- length(xVars)
                
                if ((nr_choosen == 2) || ( nr_left == 1)) {
                        updateCheckboxGroupInput(
                                session, "xVars",
                                choices = xVars, selected = xVars,
                                label="You can not select any other feature."
                        )
                }
                else {
                        if (nr_choosen == 1) {
                                label <- "You can choose one additional variable if you want."
                        } 
                        else {
                                label <- "Something went wrong, you should not be able to select more then 2 variables."
                        }
                        updateCheckboxGroupInput(
                                session, "xVars",
                                choices = names(data_frame),
                                selected = xVars,
                                label=label
                        )
                }
                if (!is.element(yVar, left_overs)){
                        yVar <- left_overs[1]
                }
                updateRadioButtons(
                        session, "yVar",
                        choices = left_overs,
                        selected = yVar
                        )
                if (is.factor(data_frame[[yVar]])){
                        models <- class_models
                }
                else {
                        models <- regression_models
                }
                if (!is.element(model, models)){
                        model <- models[1]
                        }
                updateRadioButtons(
                        session, "algo",
                        choices = models,
                        selected = model
                        )
                toggle(id = "calculate", condition= (length(xVars)>0 & length(xVars)<3))
                freezeReactiveValue(input, "dataset")
                freezeReactiveValue(input, "xVars")
                freezeReactiveValue(input, "yVar")
                freezeReactiveValue(input, "model")
        })
        data_set <- eventReactive(input$calculate,{
                data_set <- 
                        switch(input$dataset,
                               "mtcars" = datasets::mtcars,
                               "faithful" = datasets::faithful,
                               "chickenWeight" = datasets::ChickWeight,
                               "insectSpray" = datasets::InsectSprays,
                               "iris" = datasets::iris,
                               "toothGrowth" = datasets::ToothGrowth,
                               "orange" = datasets::Orange
                        )
                
                return(data_set)
        })
        model_fit <- reactive({
                predictors <- data_set()[input$xVars]
                regressor <- data_set()[[input$yVar]]
                model <- train(predictors, regressor, 
                               method = input$algo)
                return(model)
        })
        output$result <- renderTable({
                return(model_fit()$results)
        })
        output$final <- renderPrint({
                return(model_fit()$finalModel)
        })
        output$model_plot <- renderPlot({
                predictions <- predict.train(model_fit())
                predictors <- input$xVars
                regressor <- data_set()[[input$yVar]]
                if (is.factor(regressor)){
                        col_code <- predictions == regressor
                        if (length(predictors) == 2){
                                final_plot <- plot(data_set()[predictors],
                                                   col=as.factor(col_code),
                                                   main= "Plot of predictions") 
                                              legend("topright",
                                                         legend = c("Correct", "Wrong"),
                                                         col=c(2,1), cex=1, pch=1)
                        } else {
                                groups <- max(length(predictions)/10,2)
                                plot_data <- cut(data_set()[[predictors]], breaks = groups)
                                matrix <- table(col_code, plot_data)
                                final_plot <- barplot(matrix,
                                                      col=c("red", "black"), 
                                                      main="Plot of predictions",
                                                      legend.text = c("Wrong", "Correct"), 
                                                      xlab = "Predictor Variable",
                                                      ylab = "Count of predictions"
                                                   )
                        }
                        
                }
                else{
                        difference <- (predictions - regressor)
                        final_plot <- plot(x=regressor, y=difference, 
                                           main = "Residual Plot",
                                           xlab = "Regressor",
                                           ylab = "Residual"
                                           ) + abline(h=0, col="red")
                }
                return(final_plot)
        })

})
