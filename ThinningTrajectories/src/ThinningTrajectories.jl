module ThinningTrajectories
    using Polynomials
    using DataFrames
    using CSV
    using LsqFit
    using NCDatasets
    using Plots
    using StatsPlots    
    include("thinnig_trajectories.jl")
    include("plots_and_layout.jl")
    include("process_ORCHIDEE_results.jl")
    precompile(estimate_θrdi, (DataFrame, DataFrame, Float64, 
        Int64, Vector{Float64}, Float64, Float64, Int64))
    precompile(merge_netcdf, (String, Vector{String}, String))
    precompile(merge_previous_plots, (Forest, DataFrame, Int64))     
end
