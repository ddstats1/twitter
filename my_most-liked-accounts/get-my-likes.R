
library(tidyverse)
library(here)
library(rjson)
library(rtweet)

# read from my downloaded archive (instructions: https://ivelasq.rbind.io/blog/get-tweet-likes/)
js <- read_file(here("00_archive-2021-11-17", "data", "like.js"))
json <- sub("window.YTD.like.part0 = ", "", js)

likes_raw <- fromJSON(json)

likes_ids_df <-
  likes_raw %>% 
  flatten_df()

likes_df <- lookup_statuses(likes_ids_df$tweetId)

# write out
write_csv(likes_df, here("my_most-liked-accounts", "data", "likes_df.csv"))
