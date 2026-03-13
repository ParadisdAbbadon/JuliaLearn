# linear regression machine learning model
using Pkg
# Pkg.add("CSV")
# Pkg.add("DataFrames")
using CSV
using DataFrames

# import the csv file into a dataframe and print the first 5 lines
df = DataFrame(CSV.File("../Traffic_Crashes.csv"))
println(first(df, 5))

