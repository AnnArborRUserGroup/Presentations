

# accessing the Quandl API from R

#devtools::install_github('quandl/R-package')

library(Quandl)
library(magrittr)
library(ggplot2)
library(lubridate)
library(zoo)
library(AnomalyDetection)
library(BreakoutDetection)

#sessionInfo()

#Quandl.api_key("yourauthenticationtoken") 

msft_data <- Quandl("GOOG/NASDAQ_MSFT", collapse = "monthly")[, c(1,5)] # closing price
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

# traditional time-series decomposition

msft_zoo <- zoo(msft_data$count, order.by = msft_data$timestamp)
msft_ts <- ts(msft_zoo, frequency = 12)
msft_stl <- stl(msft_ts, s.window = "periodic")
plot(msft_stl)

# use Twitter algorithms to find anomalies and breakouts 

msft_vec <- msft_data$count[order(msft_data$timestamp)]

outliers <- AnomalyDetectionVec(msft_vec,
                                plot = T,
                                direction = 'both',   # detect positive and negative spikes
                                only_last = F,        # report anomalies only in last period
                                period = 12,          # number obs. in single period
                                longterm_period = 48) # number obs. for which trend is "flat"

outliers$plot
outliers$anoms

changes <- breakout(msft_vec,
                    plot = T,
                    method = 'multi', # detect multiple change points
                    min.size = 12)    # min(# obs.) between change points

changes$plot
changes$loc


