

# accessing the Quandl API from R

#devtools::install_github('quandl/R-package')

library(Quandl)
library(ggplot2)
library(magrittr)
library(dplyr)

#Quandl.api_key("yourauthenticationtoken") 
Quandl.api_key("5nUk_6XSenkDnvK2N2-w")

msft_data <- Quandl("GOOG/NASDAQ_MSFT", collapse = "daily")[, c(1,5)]

# specific date range
#start_date = "yyyy-mm-dd", end_date = "yyyy-mm-dd"

# frequency change
#collapse = "daily"|weekly"|"monthly"|"quarterly"|"annual"

#transform = "diff"|"rdiff"|"normalize"|"cumul"|"rdiff_from"

#ploting example

msft_data %>% 
  ggplot(aes(x = Date, y = Close)) +
  geom_line(color = "#FAB521") +
  theme(panel.background = element_rect(fill = "#393939"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "white", size = 0.1),
        panel.grid.minor = element_line(colour = "white", size = 0.1)) +
  xlab("Date") + 
  ylab("Closing Price") + 
  ggtitle("MSFT") 




