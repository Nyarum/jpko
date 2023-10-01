using CSV, DataFrames, Dates
using Base

# Reading CSV file into DataFrame
df = DataFrame(CSV.File("database/test.csv"))
dfLock = ReentrantLock()

function generateDFValues(id)
    push!(df, (id = id, name = "test", created = now()))
end

@time @sync begin
    @async begin
        for i in 1:1000000
            lock(dfLock) do
                generateDFValues(1)
            end
        end
    end

    @async begin
        for i in 1:2000000
            lock(dfLock) do
                generateDFValues(2)
            end
        end
    end
end

println("test")

# Writing DataFrame to a new CSV file
CSV.write("database/test.csv", df)
