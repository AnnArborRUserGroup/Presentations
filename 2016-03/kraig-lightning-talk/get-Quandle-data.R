

# accessing the Quandl API from R

#devtools::install_github('quandl/R-package')

library(Quandl)
library(magrittr)
library(ggplot2)
library(lubridate)
library(AnomalyDetection)
library(BreakoutDetection)

#sessionInfo()

#Quandl.api_key("yourauthenticationtoken") 

msft_data <- Quandl("GOOG/NASDAQ_MSFT", collapse = "daily")[, c(1,5)] # closing price
msft_data$Date <- ymd(msft_data$Date)
colnames(msft_data) <- c("timestamp", "count")

# specific date range
#start_date = "yyyy-mm-dd", end_date = "yyyy-mm-dd"

# frequency change
#collapse = "daily"|weekly"|"monthly"|"quarterly"|"annual"

#transform = "diff"|"rdiff"|"normalize"|"cumul"|"rdiff_from"

#ploting example

msft_data %>% 
  ggplot(aes(x = timestamp, y = count)) +
  geom_line(color = "#FAB521") +
  theme(panel.background = element_rect(fill = "#393939"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "white", size = 0.1),
        panel.grid.minor = element_line(colour = "white", size = 0.1)
  ) +
  xlab("Date") + 
  ylab("Closing Price") + 
  ggtitle("MSFT")

msft_vec <- msft_data$count[order(msft_data$timestamp)]

outliers <- AnomalyDetectionVec(msft_vec, direction = 'both', plot = T, period = 7, longterm_period = 56)
outliers$plot

changes <- breakout(msft_vec, method = 'multi', plot = T, min.size = 7)
changes$plot
changes$loc


