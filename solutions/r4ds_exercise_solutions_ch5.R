# solutions to the r4ds exercises in chapter 5, data
# transformation

library(tidyverse)
library(nycflights13)
data(flights)

#################
# Section 5.2.4 #
#################

# 1. Find all flights that
# 
# 1. Had an arrival delay of two or more hours
tmp <- filter(flights,arr_delay>119)

# 2. Flew to Houston (IAH or HOU)
tmp <- filter(flights,dest=="IAH"|dest=="HOU")

# 3. Were operated by United, American, or Delta
tmp <- filter(flights,carrier %in% c("UA","AA","DL"))

# 4. Departed in summer (July, August, and September)
tmp <- filter(flights,month %in% 7:9)

# 5. Arrived more than two hours late, but didn’t leave late
tmp <- filter(flights,arr_delay>120,dep_delay<1)

# 6. Were delayed by at least an hour, but made up over 30 minutes in flight
tmp <- filter(flights,dep_delay>59,arr_delay<31)

# 7. Departed between midnight and 6am (inclusive)
tmp <- filter(flights,dep_time>=0,dep_time<601)

# 2. Another useful dplyr filtering helper is between(). What does it do? 
# Can you use it to simplify the code needed to answer the previous challenges?
tmp <- filter(flights,between(dep_time,0,600))

# 3. How many flights have a missing dep_time? What other 
# variables are missing? What might these rows represent?

tmp <- filter(flights,is.na(dep_time))
# 8255. All other non-scheduled times are missing as well. Cancelled?

#################
# Section 5.4.1 #
#################

# 1. Brainstorm as many ways as possible to select 
# dep_time, dep_delay, arr_time, and arr_delay from flights.

tmp <- select(flights,starts_with("dep"),starts_with("arr"))
tmp <- select(flights,c(4,6,7,9))

# 2. What happens if you include the name of a variable 
# multiple times in a select() call?

tmp <- select(flights, year,year,starts_with("y"))

# you get it only once

# 3. What does the one_of() function do? 
# Why might it be helpful in conjunction with this vector?

?one_of
vars <- c("year", "month", "day", "dep_delay", "arr_delay")

tmp <- select(flights,"month")

# Picks all those named in a character vector. You can 
# use it in multiple calls without typing out /copy pasting
# and sometimes you just create the vector as a code.

# 4. Does the result of running the following code surprise 
# you? How do the select helpers deal with case 
# by default? How can you change that default?

tmp <- select(flights, contains("TIME"))
tmp <- select(flights, contains("TIME",ignore.case=FALSE))

#################
# Section 5.5.2 #
#################

# 1. Currently dep_time and sched_dep_time are convenient 
# to look at, but hard to compute with because they’re not 
# really continuous numbers. Convert them to a more convenient 
# representation of number of minutes since midnight.

tmp <- mutate(flights,
              dep_hour=dep_time %/% 100,
              dep_min=dep_time %% 100,
              dep_time_m=dep_hour*60+dep_min,
              sched_dep_hour=sched_dep_time %/% 100,
              sched_dep_min=sched_dep_time %% 100,
              sched_dep_time_m=sched_dep_hour*60+sched_dep_min)

# 3. Compare air_time with arr_time - dep_time. What do you 
# expect to see? What do you see? What do you need to do to fix it?

tmp <- mutate(flights,air_time_calc=arr_time-dep_time)
tmp <- select(tmp,starts_with("air"))

# Not even close to the same number?? Oh right, arr_time and dep_time
# are not actually numbers with which you can calculate. Do the same
# thing as in Ex. 1 again, and to the arr_time as well

# 3. Compare dep_time, sched_dep_time, and dep_delay. 
# How would you expect those three numbers to be related?

# rerun the solution to 1 again, then:
tmp <- mutate(tmp,dep_delay_calc=dep_time_m-sched_dep_time_m)
tmp <- select(tmp,dep_delay_calc,dep_delay) 
#those two should be the same (they are, mostly, but not all)

# 4. Find the 10 most delayed flights using a ranking function. 
# How do you want to handle ties? Carefully read the 
# documentation for min_rank().

?min_rank
tmp <- mutate(flights,most_delayed=min_rank(desc(arr_delay)))
tmp <- filter(tmp,most_delayed<11)

#Handling the ties doesn't actually affect the result at all.

#################
# Section 5.6.7 #
#################

# 1. Brainstorm at least 5 different ways to assess the 
# typical delay characteristics of a group of flights. 

# Note that this exercise is asking you to think and discuss,
# not write code! Here are some ideas:

# - means and medians obviously, but maybe only of actual
# delays, rounding early departures/arrivals to 0?
# - only count how often the flight is considerably late
# - find the average/median of only considerable delays
# - average of the weekly worst delay (of a daily recurring flight)
# - the upper quartile etc. instead of middle point measures

# 2. Come up with another approach that will give you the 
# same output as not_cancelled %>% count(dest) and 
# not_cancelled %>% count(tailnum, wt = distance) 
# (without using count()).

not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

# count() is actually a shorthand for this common operation:

tmp <- not_cancelled %>% 
  group_by(dest) %>% 
  summarise(n=n())

tmp <- not_cancelled %>% 
  group_by(tailnum) %>%
  summarise(n=sum(distance))

# 3. Our definition of cancelled flights 
# (is.na(dep_delay) | is.na(arr_delay) ) is slightly suboptimal. 
# Why? Which is the most important column?

tmp <- flights %>% filter(is.na(dep_delay),!is.na(arr_delay))
# 0 cases of missing dep_delay but not missing arr_delay
tmp <- flights %>% filter(!is.na(dep_delay),is.na(arr_delay))
# some cases with the opposite (departed, then returned, and got
# cancelled?)
# So, it would be enough to check the missing arr_delay

# 4. Look at the number of cancelled flights per day. Is 
# there a pattern? Is the proportion of cancelled flights 
# related to the average delay?

tmp <- flights %>% 
  group_by(year,month,day) %>% 
  summarise(ncancelled=sum(is.na(arr_delay)))

tmp %>% ggplot() + geom_histogram(aes(ncancelled),binwidth = 10)

# A small number of flights gets cancelled every day, but 
# sometimes the number goes really high, with a very long tail
# in the distribution

tmp <- flights %>% 
  group_by(year,month,day) %>% 
  summarise(ncancelled=sum(is.na(arr_delay)),
            avgdelay=mean(arr_delay,na.rm=TRUE))

tmp %>% ggplot(aes(ncancelled,avgdelay)) + geom_point() +
  geom_smooth(se=FALSE)

# Understandable: some days are just bad for flying. Delays and
# cancels are correlated.

# 5. Which carrier has the worst delays? 

tmp <- flights %>% group_by(carrier) %>% 
  summarise(nflights=n(),
            avgdelay=mean(arr_delay,na.rm=TRUE))

ggplot(flights,aes(carrier,arr_delay)) +
  geom_boxplot()

tmp <- flights %>% group_by(carrier) %>% 
  summarise(nflights=n(),
            avg_delay=mean(arr_delay,na.rm=TRUE),
            delay_dist=weighted.mean(arr_delay,distance,na.rm=TRUE))
            
