# solutions to the r4ds exercises in chapter 3, visualisation

library(ggplot2)
data(mpg)

#################
# Section 3.2.4 #
#################

# 1. Run ggplot(data = mpg). What do you see?

ggplot(data=mpg)

# Nothing! This is the correct answer. In the text it said
# "So ggplot(data = mpg) creates an empty graph, but it’s 
# not very interesting so I’m not going to show it here."

# 2. How many rows are in mpg? How many columns?

dim(mpg)
nrow(mpg)
ncol(mpg)

# 234 rows, 11 columns
# One could also just look at the environment tab

# 3. What does the drv variable describe? Read 
# the help for ?mpg to find out.

?mpg

# f = front-wheel drive, r = rear wheel drive, 4 = 4wd

# 4. Make a scatterplot of hwy vs cyl.

ggplot(mpg) + geom_point(aes(cyl,hwy))

# 5. What happens if you make a scatterplot of 
# class vs drv? Why is the plot not useful?

ggplot(mpg) + geom_point(aes(drv,class))

# You get what you ask for, but you see the 234 cars
# as just 12 points because of overlapping.
# Scatterplot is not a wise choice with two categorical
# variables!

#################
# Section 3.3.1 #
#################

# 1. What’s gone wrong with this code? Why are the points 
# not blue?

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))

# color="blue" is inside the aesthetic mapping. A nameless 
# variable with the constant value, the word "blue", was 
# mapped to the color aesthetic. All have the same value, 
# so all are marked with the same default color, which is
# what ever it is, and not blue.

# 2. Which variables in mpg are categorical? Which variables 
# are continuous? (Hint: type ?mpg to read the documentation 
# for the dataset). How can you see this information when you 
# run mpg?

# categorical: manufacturer, model, trans, drv, fl, class
# continuous: displ, cyl, cty, hwy
# slightly debatable which: year

# 3. Map a continuous variable to color, size, and shape. 
# How do these aesthetics behave differently for categorical 
# vs. continuous variables? 

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = cty))
# this creates a color slider, where the hue/intensity shows
# the actual value (supposedly) whereas with a categorical
# the colors are distinct (and meaningless)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = cty))
# big point means big value; this makes sense. for categorical
# if the categories aren't ordered at least, it doesn't make
# sense

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = cty))
# this one gives an error because it makes no sense at all

# 4.What happens if you map the same variable to multiple 
# aesthetics?

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = hwy))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = hwy, y = hwy, 
                           color = hwy, size = hwy))

# Nothing special happens, you get what you ask for:
# a very confusing plot

# 5. What does the stroke aesthetic do? What shapes 
# does it work with? (Hint: use ?geom_point)

# For shapes that have a border (like 21), you can colour the inside and
# outside separately. Use the stroke aesthetic to modify the width of the
# border
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 5)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 1)

# 6. What happens if you map an aesthetic to something 
# other than a variable name, like aes(colour = displ < 5) ?

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, colour = displ < 5))

# The expression sort of becomes a new, nameless variable 
# and is treated accordingly

#################
# Section 3.5.1 #
#################

# 1. What happens if you facet on a continuous variable?

ggplot(data = mpg) + 
geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ cty, nrow = 2)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = cty, y = hwy)) + 
  facet_wrap(~ displ, nrow = 2)

# Horrible things: every distinct value gets its own
# facet. Not good.

# 2. What do the empty cells in plot with 
# facet_grid(drv ~ cyl) mean? How do they relate to this plot?

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl))

# It means that there are no cars with those drv-cyl
# combinations. The empty ones appear at the same places
# as where there are no points in the (silly) scatterplot.

# 3. What plots does the following code make? 
# What does . do?

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# The same plots as the facet_grid(drv ~ cyl), but 
# combined or summed or marginalized over the other.
# The . means something like "nothing" (although 
# sometimes it means "everything")

#################
# Section 3.6.1 #
#################

# 1. What geom would you use to draw a line chart? 
# A boxplot? A histogram? An area chart?

# These all have a geom with the same name!

# 2. Run this code in your head and predict what 
# the output will look like. Then, run the code 
# in R and check your predictions.

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# 3. What does show.legend = FALSE do? What happens 
# if you remove it? Why do you think I used it earlier 
# in the chapter? 

ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv) #,
    #show.legend = FALSE
  )

# It suppresses the legend from showing. If you remove it, 
# it shows again (by default). It was used (possibly)
# to match the other two plots which didn't have a legend 
# at all.

# 4. What does the se argument to geom_smooth() do?

# display confidence interval around smooth? 
# (TRUE by default, see level to control

# level: level of confidence interval to use 
# (0.95 by default)

# 5. Will these two graphs look different? Why/why not?

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))

# They will look the same: the data and mappings given inside
# ggplot are used in all the geoms, unless otherwise stated

# 6. Recreate the R code necessary to generate 
# the following graphs.

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth(se=FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth(aes(group=drv),se=FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy,col=drv)) + 
  geom_point() + 
  geom_smooth(se=FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(col=drv)) + 
  geom_smooth(se=FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(col=drv)) + 
  geom_smooth(aes(lty=drv),se=FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(fill=drv), size=3,shape=21, col="white", stroke=2)

