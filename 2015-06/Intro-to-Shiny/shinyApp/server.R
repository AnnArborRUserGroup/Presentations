function(input, output) {
  output$data <- renderTable({makeTable(input$slider)})
}
