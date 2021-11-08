#' Create a sales dataset
#' 
#' Contains month, year time variables
#' and a sales unit price and stock keeping unit (SKU).
#' Sometimes we sell one, sometimes 2 and sometimes we have to return an item (-1).
#' This is ugly but realistic.
create_dataset <- function(rows = 10000L, seed = 123145){
  vec = 1:rows
  set.seed(seed)
  data.frame(
    month = month.abb[(vec %% 12) +1],
    year = sample(c(2001:2004),size = rows, replace = TRUE),
    sales_units = sample(c(1,-1,2),size = rows, replace=TRUE,prob = c(80,5,15)),
    SKU = sample(
      c("112354", "123194", "123154", "112348","123145", "153246", "1003456", "1923456", '109234'),
      size = rows, replace = TRUE, 
      prob = c(1,.5,1,3,1,1,10,1,2) ),
    item_price_eur = round(runif(rows, min= 5, max = 50), 2)
  )
}