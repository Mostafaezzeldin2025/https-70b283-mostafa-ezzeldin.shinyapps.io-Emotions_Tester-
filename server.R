library(shiny)
library(tidyverse)
library(tidytext)
library(wordcloud2)
library(syuzhet)

server <- function(input, output, session) {
  
  # استخراج النص بناءً على اختيار المستخدم
  getText <- eventReactive(input$analyzeBtn, {
    if (input$inputType == "text") {
      req(input$userText)
      return(input$userText)
    } else {
      req(input$file1)
      text <- readLines(input$file1$datapath, warn = FALSE)
      return(paste(text, collapse = " "))
    }
  }, ignoreNULL = FALSE)
  
  # معالجة النص وتنظيفه (Clean Data Frame)
  getCleanData <- reactive({
    raw_text <- getText()
    
    text_df <- tibble(text = raw_text) %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words, by = "word") %>%
      filter(!str_detect(word, "^[0-9]+$")) # استبعاد الأرقام
    
    return(text_df)
  })
  
  # 1. رسم بياني لتحليل المشاعر
  output$sentimentPlot <- renderPlot({
    raw_text <- getText()
    
    # حساب المشاعر باستخدام خوارزمية syuzhet
    sentiments <- get_nrc_sentiment(raw_text)
    sentiment_scores <- data.frame(Sentiment = colnames(sentiments), Score = colSums(sentiments))
    
    ggplot(sentiment_scores, aes(x = reorder(Sentiment, Score), y = Score, fill = Sentiment)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      labs(title = "Emotional & Sentiment Score Breakdown",
           x = "Emotion / Sentiment", y = "Score") +
      theme_minimal(base_size = 14)
  })
  
  # 2. عرض سحابة الكلمات (Word Cloud)
  output$wordcloudPlot <- renderWordcloud2({
    df <- getCleanData() %>%
      count(word, sort = TRUE)
    
    req(nrow(df) > 0)
    wordcloud2(df, size = 0.7, color = "random-dark")
  })
  
  # 3. رسم بياني لأعلى الكلمات تكراراً
  output$topWordsPlot <- renderPlot({
    df <- getCleanData() %>%
      count(word, sort = TRUE) %>%
      top_n(10, n)
    
    req(nrow(df) > 0)
    
    ggplot(df, aes(x = reorder(word, n), y = n)) +
      geom_col(fill = "#2c3e50") +
      coord_flip() +
      labs(title = "Top 10 Most Frequent Words", x = "Word", y = "Frequency") +
      theme_minimal(base_size = 14)
  })
}