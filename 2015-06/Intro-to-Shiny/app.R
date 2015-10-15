ui <- fluidPage(
  h1("Hello, World!"),
  sliderInput("slider", "choose a length for the dataset:", 1, 26, 10),
  tableOutput("data")
)

server <- function(input, output) {
  df <- data.frame(a = runif(10000000), b = rnorm(10000000))
  output$data <- renderTable({
    rows <- sample(nrow(df), input$slider)
    df[rows, ]
  })
}

shinyApp(ui=ui, server=server)
