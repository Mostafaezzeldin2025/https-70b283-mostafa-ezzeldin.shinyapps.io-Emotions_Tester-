library(shiny)
library(wordcloud2)

fluidPage(
  titlePanel("Text Mining & Sentiment Analysis Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Analyze sentiment and word frequencies from text input."),
      
      # خيار إدخال النص مباشرة أو رفع ملف
      radioButtons("inputType", "Choose Input Method:",
                   choices = c("Direct Text Input" = "text", 
                               "Upload Text File (.txt)" = "file")),
      
      conditionalPanel(
        condition = "input.inputType == 'text'",
        textAreaInput("userText", "Enter Text Here:", 
                      value = "Data science is amazing and R Shiny makes building dashboards easy and enjoyable! However, debugging can sometimes be challenging and frustrating.",
                      rows = 6)
      ),
      
      conditionalPanel(
        condition = "input.inputType == 'file'",
        fileInput("file1", "Choose .txt File", accept = c("text/plain", ".txt"))
      ),
      
      actionButton("analyzeBtn", "Analyze Text", class = "btn-primary")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Sentiment Summary", 
                 br(),
                 plotOutput("sentimentPlot")),
        tabPanel("Word Cloud", 
                 br(),
                 wordcloud2Output("wordcloudPlot", height = "400px")),
        tabPanel("Top Keywords", 
                 br(),
                 plotOutput("topWordsPlot"))
      )
    )
  )
)