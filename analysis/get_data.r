meta = importMeta("kcl")
london = importKCL(site = c('LB4','LB6', 'LB5'), year = 2011)
annual <- timeAverage(london, avg.time = "year")
annual <- merge(annual, meta, by="site")
