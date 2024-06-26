# Analysis of nationally representative data - Venn Diagrams
# January 2024
# Jolyon Miles-Wilson

# Questions of interest are
# - Question 1s: these are the indicator questions (Q3 previously)
# - Question 2s: this is the long-term/short-term question (Q5 previously)
# - Question 3s: this is the blanket statement "I am outsourced/agency" (Q7/8 previously)


# This script creates groupings and plots venn diagrams to visusalise the overlap
# between certain groupings

rm(list = ls())

library(haven)
library(poLCA)
library(dplyr)
library(ggplot2)
library(ggVennDiagram)
library(tidyr)
library(ggvenn)
library(VennDiagram)

###############
### Data ######
###############

rm(list = ls())
data <- read_sav("./Data/uncleaned_full_data.sav")

# invert response function for summing
invert_response <- function(x){
  x <- 2 + (-1*x)
}

# Now for just indicators
indicator_data <- data %>% 
  select(ID, starts_with("Q1")) %>%
  reframe(across(starts_with("Q1"), ~invert_response(.x)), .by = ID) %>%
  rowwise() %>%
  mutate(
    sum_true = sum(Q1_1, Q1_2, Q1_3, Q1_4, Q1_5, Q1_6)
  ) %>% 
  select(-starts_with("Q1"))

# Check ID the same
sum(data$ID == indicator_data$ID) == nrow(data)

# Merge 
data <- left_join(data, indicator_data, by = "ID")

###########################
#### Assign to  groups ####
###########################

# This deliberately non-exclusive to check overlap 
v1_2_data <- data %>%
  mutate(
    # SURE outsourced or MIGHT BE outsourced + LONGTERM
    outsourced = ifelse(Q3v3a == 1 | (Q3v3a == 2 & Q2 == 1), 1, 0),
    # MIGHT BE agency + LONG TERM
    likely_agency = ifelse(Q2 == 1 & (Q3v3b == 1 | Q3v3c == 1 | Q3v3d == 1), 1, 0),
    likely_agency = ifelse(is.na(likely_agency), 0, likely_agency),
    # 5 or more indicators
    high_indicators = ifelse(sum_true >= 5, 1, 0),
    # 5 or more indicators + LONG TERM
    high_indicators_LT = ifelse(Q2 == 1 & sum_true >= 5, 1, 0)
  )

#dev.off(dev.list()["RStudioGD"])
venn.plot <- venn.diagram(x = list(
  which(v1_2_data$outsourced == 1),
  which(v1_2_data$likely_agency == 1),
  which(v1_2_data$high_indicators == 1)),
  category.names = c("Outsourced","Likely agency","High indicators"),
  filename = NULL,
  output = TRUE
)

grid.draw(venn.plot)

# Define colors for each set
colors <- c("dodgerblue", "darkorange", "forestgreen")

venn.diagram(x = list(
  which(v1_2_data$outsourced == 1),
  which(v1_2_data$likely_agency == 1),
  which(v1_2_data$high_indicators == 1)),
  category.names = c("Outsourced","Likely agency","High indicators"),
  filename = "./outputs/venn.png",
  fill = colors,
  print.mode = c("raw","percent")
  )


#lapply(groups, sum)

venn.diagram(x = list(
  which(v1_2_data$outsourced == 1),
  which(v1_2_data$likely_agency == 1),
  which(v1_2_data$high_indicators_LT == 1)),
  category.names = c("Outsourced","Likely agency", "High indicators LT"),
  filename = "./outputs/venn_2.png",
  fill = colors,
  print.mode = c("raw","percent")
)


################################################################
### Feb 2 - Changing groupings to explore different overlaps ###
################################################################

# 1. 
# group 1: SURE outsourced + LONG TERM or MIGHT BE OUTSROUCED + LONGTERM
# group 2: ANGECY + LONG TERM
# group 3: 5 indicators + LOGN TERM

# This deliberately non-exclusive to check overlap 
v3_data <- data %>%
  mutate(
    # SURE outsourced _+ LONG TERM or MIGHT BE outsourced + LONGTERM
    outsourced_LT = ifelse((Q3v3a == 1 & Q2 == 1) | (Q3v3a == 2 & Q2 == 1), 1, 0),
    # MIGHT BE agency + LONG TERM
    likely_agency = ifelse(Q2 == 1 & (Q3v3b == 1 | Q3v3c == 1 | Q3v3d == 1), 1, 0),
    likely_agency = ifelse(is.na(likely_agency), 0, likely_agency),
    # 5 or more indicators
    high_indicators = ifelse(sum_true >= 5, 1, 0),
    # 5 or more indicators + LONG TERM
    high_indicators_LT = ifelse(Q2 == 1 & sum_true >= 5, 1, 0)
  )

venn.diagram(x = list(
  which(v3_data$outsourced_LT == 1),
  which(v3_data$likely_agency == 1),
  which(v3_data$high_indicators_LT == 1)),
  category.names = c("Outsourced LT","Likely agency","High indicators LT"),
  filename = "./outputs/venn_3.png",
  fill = colors,
  print.mode = c("raw","percent"),
)

# 2. 
# group 1: SURE outsourced or MIGHT BE OUTSROUCED + LONGTERM
# group 2: ANGECY + LONG TERM
# group 3: 6 indicators + LOGN TERM

# This deliberately non-exclusive to check overlap 
v4_data <- data %>%
  mutate(
    # SURE outsourced _+ LONG TERM or MIGHT BE outsourced + LONGTERM
    outsourced = ifelse(Q3v3a == 1 | (Q3v3a == 2 & Q2 == 1), 1, 0),
    # MIGHT BE agency + LONG TERM
    likely_agency = ifelse(Q2 == 1 & (Q3v3b == 1 | Q3v3c == 1 | Q3v3d == 1), 1, 0),
    likely_agency = ifelse(is.na(likely_agency), 0, likely_agency),
    # 5 or more indicators
    high_indicators = ifelse(sum_true >= 5, 1, 0),
    # 5 or more indicators + LONG TERM
    high_indicators_LT = ifelse(Q2 == 1 & sum_true == 6, 1, 0)
  )

venn.diagram(x = list(
  which(v4_data$outsourced == 1),
  which(v4_data$likely_agency == 1),
  which(v4_data$high_indicators_LT == 1)),
  category.names = c("Outsourced","Likely agency","High indicators LT"),
  filename = "./outputs/venn_4.png",
  fill = colors,
  print.mode = c("raw","percent"),
)


# This deliberately non-exclusive to check overlap 
v5_data <- data %>%
  mutate(
    # SURE outsourced _+ LONG TERM or MIGHT BE outsourced + LONGTERM
    outsourced_LT = ifelse((Q3v3a == 1 & Q2 == 1) | (Q3v3a == 2 & Q2 == 1), 1, 0),
    # MIGHT BE agency + LONG TERM
    likely_agency = ifelse(Q2 == 1 & (Q3v3b == 1 | Q3v3c == 1 | Q3v3d == 1), 1, 0),
    likely_agency = ifelse(is.na(likely_agency), 0, likely_agency),
    # 5 or more indicators
    high_indicators = ifelse(sum_true >= 5, 1, 0),
    # 5 or more indicators + LONG TERM
    high_indicators_LT = ifelse(Q2 == 1 & sum_true == 6, 1, 0)
  )

venn.diagram(x = list(
  which(v5_data$outsourced_LT == 1),
  which(v5_data$likely_agency == 1),
  which(v5_data$high_indicators_LT == 1)),
  category.names = c("Outsourced LT","Likely agency","High indicators LT"),
  filename = "./outputs/venn_5.png",
  fill = colors,
  print.mode = c("raw","percent"),
)

