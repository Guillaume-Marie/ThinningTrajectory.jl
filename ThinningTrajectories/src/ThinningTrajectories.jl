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
    precompile(estimate_θrdi, (Int64, Dict))
    precompile(merge_previous_plots, (Forest, String, String, Int64, Dict))     
end
