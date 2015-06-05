fluidPage(
  h1("Hello, World!"),
  sliderInput("slider", "Select a number of letters", 1, 26, 1),
  tableOutput("data")
)
