## Large size datasets

Sometimes you get big datasets that barely or not at all fit into memory.
What should you do then? You shouldn't have to be an expert about CPUs or memory
to make better use of your computer.

Here are some practical things for you to consider:

# Option 1: Don't load all the data

## Do you need to use all the data?
Seriously, often your work is good enough with just a random sample from the data.

## Do you need to use all the data at the same time?
Using linux commandline tools you can split the data into smaller parts and load and process the parts one by one.

## Do you need all the columns in your data? Load only the columns you need
A huge and wide dataset that contains only 2 columns of interest ca
[the R package {vroom} can load only the columns you need](https://vroom.r-lib.org/articles/vroom.html#column-selection)
[the R package {data.table} can load only the columns you need](https://rdatatable.gitlab.io/data.table/reference/fread.html)

[The python package polars (a pandas replacement) can read in select columns too](https://pola-rs.github.io/polars/py-polars/html/reference/api/polars.read_csv.html)

# Option 2: When you can load it into memory

## Use an optimized library
In the R world the worldclass [{data.table}](https://rdatatable.gitlab.io/data.table/) package
is designed for speed, it consistently outperforms other packages.
If you don't want to leave the tidyverse use the dtplyr package to use data.table
with dplyr commands.

# Use a simple local database
The goto local database without any bells and whistles was always sqlite, and
you could still use it, but it is not optimized for analytical queries so you
might also want to look at duckdb.


```r
# sqlite
library(dplyr)
con <- DBI::dbConnect(RSQLite::SQLite(), "sales.db")
sales <- tbl(con, "sales")
sales %>%
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
  )
```

```
# duckdb
library(dplyr)
# queries work the same as SQLite, so I'm not going to show it.
duck = DBI::dbConnect(duckdb::duckdb(), dbdir="duck.db", read_only=FALSE)
sales <- tbl(duck, "sales")
sales %>%
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
  )
```

For these group_by & summarize queries duckdb is usually way faster.


Running a process on your computer is almost always faster and cheaper than going into multicomputer systems such as spark.


https://www.reddit.com/r/datascience/comments/fgusho/what_is_the_closest_python_equivalent_of_rs_dbplyr/


```
pyenv virtualenv 3.7.4 bigrmem
pyenv activate bigrmem



```
