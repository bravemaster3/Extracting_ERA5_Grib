library(rgdal)
library(data.table)
library(stringr)
library(dplyr)

blh <- readGDAL("boundary_layer_height.grib")

str(blh)
blh_df <- as.data.frame(t(blh@data))
blh_df <- setDT(blh_df, keep.rownames = TRUE)[]

colnames(blh_df) <- c("band","blh")
blh_df$index <- as.numeric(str_sub(blh_df$band, 5, -1))

blh_df$hour <- rep(0:23, ceiling(nrow(blh_df)/24))[1:nrow(blh_df)]

blh_df$date <- rep(seq.Date(as.Date("2020-01-01"), as.Date("2021-06-30"), by=1),each=24)[1:nrow(blh_df)]

blh_df_half <- blh_df[rep(seq_len(nrow(blh_df)), each = 2), ]

blh_df_half$min <- rep(c(0,30), nrow(blh_df_half)/2)


blh_df_half$datetime <- as.POSIXct(paste(blh_df_half$date, paste(sprintf("%02d", blh_df_half$hour),sprintf("%02d",blh_df_half$min),sep=":")), format= "%Y-%m-%d %H:%M", tz="UTC")
blh_final <- blh_df_half[,c("datetime","blh")]

#example of aggregation per day
blh_final$date = as.Date(blh_final$datetime)
blh_final_day <- blh_final %>% 
  group_by(date) %>%
  summarise(blh_day = mean(blh))
