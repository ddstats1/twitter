
library(tidyverse)
library(rtweet)
library(here)
library(lubridate)
library(RSelenium)
library(rvest)

# using example from https://github.com/ropensci/rtweet/issues/200

# want a specific user's favorite tweets (all of them)
# batch request sequentially, eg sliding interval

user <- "daniel_dulaney"

n_fav <- lookup_users(users = user)$favourites_count

n_batches <- round(n_fav / 2000)

n_last_batch <- n_fav %% 2000

overall_last_like_id <- get_favorites(user = user, n = 1) %>% 
  select(status_id) %>% 
  pull()

# cycle through my 43,000+ favorites, tracking each one's date created (when i liked it) and account created by
# (who i liked)

# note that get_favorites cab only grab 3000 at a time. i'll try 2,000 at a time here. that means there's 
# gonna be 13 batches of 2000, 1 batch of 799

# set up empty df formatted like the get_favorites() outcome
all_likes <- 
  get_favorites(user = user, n = 1) %>% 
  filter(user_id == 12345)

for (i in 1:n_batches) {
  
  if (i == 1) { # FIRST BATCH: needs max_id = overall_max ID (not from a batch like 2 through n-1 needs)
    
    batch_likes <- get_favorites(user = user, n = 2000, max_id = overall_last_like_id)
    
    # TEST
    batch_1 <- get_favorites(user = user, n = 2000, max_id = overall_last_like_id)
    batch_1 %>% count(date = lubridate::as_date(created_at)) %>% arrange(date) %>% View()
  
    } else if (i == n_batches) { # LAST BATCH: should just be n = n_batches 
      
      latest_id <- get_favorites(user = user, n = 1)
  
      } else { # BATCHES 2 THROUGH N: should be n = 2000 & max_id = (the oldest (i.e. earliest in time) status_id from the previous batch)
    
    batch_likes <- get_favorites(user = user, n = 2000, max_id = earliest_batch_like)
    
    # TEST
    batch_2 <- get_favorites(user = user, n = 2000, max_id = batch_last_like_id)
    batch_2 %>% count(date = lubridate::as_date(created_at)) %>% arrange(date) %>% View()
    
    batch_3 <- get_favorites(user = user, n = 2000, max_id = batch_last_like_id)
    batch_3 %>% count(date = lubridate::as_date(created_at)) %>% arrange(date) %>% View()
    
  }
  
  # save earliest tweet ID from each batch so can set that as the max ID for the next batch
  batch_last_like_id <- batch_1$status_id %>% min()
  batch_last_like_id <- batch_2$status_id %>% min()
  
  # rbind onto all_likes df
  
  # TEST
  all_likes <- rbind(all_likes, batch_1)
  all_likes <- rbind(all_likes, batch_2)
  
}


# get id of single most recent tweet (as baseline to work backwards)

batch_0 <- get_favorites(user = user, n = 1)

batch_0$status_id %>% min()
batch_0$status_id %>% max()
id_0 <- batch_0$status_id

# tried diff combos of since_id/max_id = min/max, none get desired behavior
# from r package doc and twitter api doc, 
# 'max_id' should be what we want to use as interval slider

# from baseline, get older 1000 tweets
batch_1 <- rtweet::get_favorites(user=user,
                                n = 1000,
                                max_id=id_0)

# what exactly do we want from batch_1?
# - Account liked
# - Date liked

batch_1 %>% 
  select(screen_name, created_at) %>% 
  View()

min_1 <- batch_1$status_id %>% min()
max_1 <- batch_1$status_id %>% max()
min_1
max_1

# start from 'most recent'
# batch iterate backwards 
# to full set ending at 'oldest'

# expect previous 'min' to be current 'max', then look backwards
# want next 1000 favorited tweets

# max_id	
# Returns results with status_id less (older) than or equal to (if hit limit) the specified status_id

batch_2 <- rtweet::get_favorites(user = user,
                                 n = 1000,
                                 max_id = min_1)

# check count of likes by date for batches 1 and 2 
batch_1 %>% 
  mutate(created_clean = str_sub(created_at, 1, 10)) %>% 
  count(created_clean) %>% View()

batch_2 %>% 
  mutate(created_clean = str_sub(created_at, 1, 10)) %>% 
  count(created_clean) %>% View()

# looks good! batch 1 is latest 1000, batch 2 is the 1000 before that

min_2 = batch_2$status_id %>% min()
max_2 = batch_2$status_id %>% max()

id_0

min_1
max_1

min_2
max_2

# not expected behavior

# is this because 'status_id' is not for the target user's favorite list
# is it referencing the 'original'source' tweet's status_id that the target user has favorited?

library(dplyr)

fave_user = bind_rows(batch_0,
                      batch_1,
                      batch_2) %>%
  distinct(status_id, user_id, .keep_all = TRUE)

dim(fave_user)

# should expect close to 2000 distinct rows






# RSelenium scraping approach ---------------------------------------------

chrome_conn <- RSelenium::rsDriver(port = as.integer(paste(sample(1:9, 4, replace = TRUE), collapse = "")),
                                   chromever = "94.0.4606.113")

chrome_conn[["client"]]



rD <- rsDriver(browser="firefox", port=4545L, verbose=F)
remDr <- rD[["client"]]

remDr$navigate("https://www.fcc.gov/media/engineering/dtvmaps")




remDr <- rsDriver(
  port = 4445L,
  browser = "firefox"
)






remDr <- remoteDriver(port=4445L)
remDr$open()
remDr$getStatus()
remDr$navigate("https://www.google.com/")

"https://twitter.com/daniel_dulaney/likes"
               
               
               





remDr <- remoteDriver(port=4445L, browserName = "firefox")
remDr$open()
remDr$getStatus()
remDr$navigate("https://www.google.com/")
remDr$getCurrentUrl()








system("sudo docker pull selenium/standalone-firefox",wait=T)
Sys.sleep(5)
system("sudo docker run -d -p 4446:4444 selenium/standalone-firefox",wait=T)
Sys.sleep(5)
remDr <- remoteDriver(port=4446L, browserName="firefox")
Sys.sleep(15)
remDr$open()

remDr$getStatus()
remDr$navigate("https://www.google.com/")
remDr$getCurrentUrl()

remDr$navigate("https://twitter.com/daniel_dulaney/likes")
remDr$getCurrentUrl()

likes_html <- xml2::read_html(remDr$getPageSource()[[1]])

likes_html %>% 
  html_nodes(".r-1wtj0ep") %>% 
  html_text2()








