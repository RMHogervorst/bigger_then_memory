## Large size datasets
(this is a companion to blogposts <https://blog.rmhogervorst.nl/blog/2021/11/08/should-i-move-to-a-database/>)
Sometimes you get big datasets that barely or not at all fit into memory.
What should you do then? You shouldn't have to be an expert about CPUs or memory
to make better use of your computer.

Here are some practical things for you to consider:

* only load the data you need
* keep data as much as possible in the place of storage
* (make use of existing data warehouse)
* keep to one computer (you can use a large cloud computer)



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

see [from_dplyr_to_db.R](from_dplyr_to_db.R) for code examples and timing.

in the Python world step away from pandas and move to polars for most of your work.

see [datamanipulation.py](datamanipulation.py) for code examples.


# Use a simple local database
The goto local database without any bells and whistles was always sqlite, and
you could still use it, but it is not optimized for analytical queries so you
might also want to look at duckdb.
see [from_dplyr_to_db.R](from_dplyr_to_db.R) for code examples and timing. 


# Make use of the analytical databases of your datawarehouse
Many of us get their data from analytical databases for example: Google Bigquery, Amazon Redshift, Azure Synapse Analytics or Snowflake in the cloud. Or clickhouse and monetdb on prem. Most of the queries you do can be executed efficiently and fast on that data warehouse. If you use R you can write the queries as you would in dplyr with a dbplyr connection. 
If you exclusively use python there is no real [similar  equivalent as dbplyr](https://www.reddit.com/r/datascience/comments/fgusho/what_is_the_closest_python_equivalent_of_rs_dbplyr/). So you have to do write the SQL queries yourself. 
Doing your dataprep in the database itself is great because the computation happens close to where the data lives, and you have to move way less data to your computer.

# move to a larger machine
It is relatively easy to spin up a big linux computer in the cloud. 
If your data doesn't fit in memory on your computer, it could still fit on a bigger machine, so you can spin up a larger computer with massive ram for a short while. Your time is often more valuable than the added cost of a cloud machine vs the speedup in time.


# Go to multicomputer solutions
Running a process on your computer is almost always faster and cheaper than going into multicomputer systems such as spark. But if you go to a certain scale of data 
there is no other option as using spark, it works great at that level!


