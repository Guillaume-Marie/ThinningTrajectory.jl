

include("thinnig_trajectories.jl")
include("process_ORCHIDEE_results.jl")

using FileIO

function update_table(table, 
    param::Array{Float64})

    n, m = size(table)
    @inbounds for i in 1:n, j in 1:m
        idx = (i - 1) * m + j
        if param[idx] > 0.0
            table[i, j] = param[idx]
        end
    end
    return table
end

