# Python
import pandas as pd

sales = pd.read_csv("sales.csv") ## approx 46 seconds
# in R I piped everything together. But in python there are seperate steps.


# this is not ideal, there must be a nicer way than this.
# sales["pos_sales"] = 0
# sales["pos_sales"][sales["sales_units"] > 0] = sales["sales_units"][sales["sales_units"] > 0]
# there was a better way! Thanks Andrea Dalseno! @adalseno 

sales['pos_sales'] = sales['sales_units'].where(sales['sales_units'] > 0, 0)
# summarise(
#     total_revenue = sum(sales_units * item_price_eur),
#     max_order_price = max(pos_sales * item_price_eur),
#     avg_price_SKU = mean(item_price_eur),
#     items_sold = n()
#   )

sales["euros"] = sales["sales_units"] * sales["item_price_eur"]
sales.groupby(["month", "year", "SKU"]).agg({
"item_price_eur":["mean"],
"euros":["sum", "max"]
}).reset_index()

### alternative approach
sales = pd.read_csv("sales.csv")
(sales.assign(
    pos_sales= lambda x: x['sales_units'].where(x['sales_units'] > 0, 0),
    euros = lambda x : x["sales_units"] * x["item_price_eur"],
    euros_sku = lambda x : x["pos_sales"] * x["item_price_eur"] )
    .groupby(["month", "year", "SKU"], as_index=False)
    .agg({
        "item_price_eur":[("avg_price_SKU","mean")],
        "euros":[("total_revenue","sum")],
        "euros_sku":[("max_price_SKU","max"), ("items_sold","count")]
     }))



## takes aprrox 1 minute and 18 seconds.

import polars as pl

sales = pl.read_csv("sales.csv")
# 44 sec read time.
sales["euros"] = sales["sales_units"] * sales["item_price_eur"]
sales.groupby(["month", "year", "SKU"]).agg({
"item_price_eur":["mean"],
"euros":["sum", "max"]
})
# a few seconds.
