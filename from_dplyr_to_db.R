source('datasetgeneration.R')
## I'm using a MACBOOK PRO early 2015 with
## 3,1 GHz Dual-Core Intel Core i7
## 16 GB 1867 MHz DDR3
## I have open several tabs in firefox, and another Rstudio session. 

# I know, you should specify the packages at the top of the file, 
# but for completeness I put them here, so all the relevant
# lines are close together. Making it easier for you to copy examples 
# with all relavant packages.


# dplyr example ---
library(dplyr)
sales <- 
  as_tibble(create_dataset(1E8))

dplyr_monthly_8 <- 
  system.time(
  (sales %>% 
    group_by(month, year, SKU) %>% 
    mutate(pos_sales = case_when(
      sales_units > 0 ~ sales_units,
      TRUE ~ 0
    )) %>% 
    summarise(
      total_revenue = sum(sales_units * item_price_eur),
      max_price_SKU = max(pos_sales * item_price_eur),
      avg_price_SKU = mean(item_price_eur),
      items_sold = n()
    ))
) 
# 1E8 rows, aggregation by month. Above my annoyance level, because I get no
# feedback whatsoever on how long it will take.
# This aggragation takes approx 20 seconds system time, but 31 seconds usertime
system.time(
  sales %>% 
    group_by(year, SKU) %>% 
    mutate(pos_sales = case_when(
      sales_units > 0 ~ sales_units,
      TRUE ~ 0
    )) %>% 
    summarise(
      total_revenue = sum(sales_units * item_price_eur),
      max_price_SKU = max(pos_sales * item_price_eur),
      avg_price_SKU = mean(item_price_eur),
      items_sold = n()
    )
) 
### yearly aggregate should be faster. 19 seconds system time and 24 usertime.


# --- data table is always the fastest
library(data.table) # even thought it runs on 1 thread only on mac.
library(dtplyr)
sales_dt <- as.data.table(sales) #~ 13 seconds to convert
sales_dt %>%  # dtplyr allows you to work with a data.table with dplyr.
    group_by(year, SKU) %>% 
    mutate(pos_sales = case_when(
      sales_units > 0 ~ sales_units,
      TRUE ~ 0
    )) %>% 
    summarise(
      total_revenue = sum(sales_units * item_price_eur),
      max_price_SKU = max(pos_sales * item_price_eur),
      avg_price_SKU = mean(item_price_eur),
      items_sold = n()
    ) # can't time it properly because of the C backend?
# approx 42 seconds.

# sqlite example ----
# (I know, you should specify the packages at the top of the file, 
#  but for completeness I put them here, so all the relevant
#  lines are close together). Making it easier for you to copy examples 
#  with all relavant packages.
library(RSQLite)
library(DBI)
library(dplyr)
#library(dbplyr) #(you dont need to explicitly load this one)
con <- DBI::dbConnect(RSQLite::SQLite(), "sales.db")
system.time(
  DBI::dbWriteTable(con, name = "sales",value = sales, overwrite=TRUE)
)
## 24 seconds system time, 103 user time. (so yeah, annoyingly slow!)
## dumping 1E8 rows like this to SQLite takes a while, there is an open issue on RSQLite on faster methods

head(DBI::dbGetQuery(con, "SELECT SKU, year, sales_units * item_price_eur AS total_revenue FROM sales GROUP BY year, SKU"))
DBI::dbDisconnect(con)


#### executing queries on a database
library(dplyr)
library(dbplyr) # ag
con <- DBI::dbConnect(RSQLite::SQLite(), "sales.db")
sales_tbl <- tbl(con, "sales") # a database object that can be used in dplyr.
#system.time(
  (sales_tbl %>% 
    group_by(year, SKU) %>% 
    mutate(pos_sales = case_when(
      sales_units > 0 ~ sales_units,
      TRUE ~ 0
    )) %>% 
    summarise(
      total_revenue = sum(sales_units * item_price_eur),
      max_order_price = max(pos_sales * item_price_eur),
      avg_price_SKU = mean(item_price_eur),
      items_sold = n()
    ))
#) 
# at least 2.25 minutes. 
# not realy faster but easier to manage.
# 
# If we use indexes on year it is way faster.
DBI::dbExecute(con,'create index if not exists year_sku on sales (year, SKU) ;')
# takes a while to execute.

(sales_tbl %>% 
    group_by(year, SKU) %>% 
    mutate(pos_sales = case_when(
      sales_units > 0 ~ sales_units,
      TRUE ~ 0
    )) %>% 
    summarise(
      total_revenue = sum(sales_units * item_price_eur),
      max_order_price = max(pos_sales * item_price_eur),
      avg_price_SKU = mean(item_price_eur),
      items_sold = n()
    )) # still takes about 1 minute. 

DBI::dbDisconnect(con)

## duckdb example ----
library(dbplyr)
library(dplyr)
duck = DBI::dbConnect(duckdb::duckdb(), dbdir="data", read_only=FALSE)
system.time(
  DBI::dbWriteTable(duck, name = "sales",value = sales, overwrite=TRUE)
)
## thanks to @sfd99 comment, I noticed I had to rewrite this query a bit for duckdb.(see history for old version)
head(DBI::dbGetQuery(duck, "SELECT SKU, year, sum(sales_units * item_price_eur) AS total_revenue FROM sales GROUP BY year, SKU"))


sales_dtbl <- tbl(duck, "sales")
# loading takes. 24 system, 49 user time.
sales_dtbl %>% 
     group_by(month, year, SKU) %>% 
     mutate(pos_sales = case_when(
       sales_units > 0 ~ sales_units,
       TRUE ~ 0
     )) %>% 
     summarise(
       total_revenue = sum(sales_units * item_price_eur),
       max_order_price = max(pos_sales * item_price_eur),
       avg_price_SKU = mean(item_price_eur),
       items_sold = n()
     )
# loads in a few seconds!
# duckdb is insanely fast!
readr::write_csv(sales, "sales.csv") # writes 2.3 GB to disk.
DBI::dbDisconnect(duck)