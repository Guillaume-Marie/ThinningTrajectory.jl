
push!(LOAD_PATH, "ThinningTrajectories/")
using ThinningTrajectories
using DataFrames
using StatsPlots
include("Experiment_setup.jl")
ORCres_folder="/home/guigeek/Julia_script/orc/YE_v0.3/"

# evergreen temperate conifer : PFT 2,3,4
spruce = ThinningTrajectories.estimate_θrdi(3, Sexp)
ThinningTrajectories.merge_previous_plots(spruce, ORCres_folder, "v0.3", 80, Sexp)

# deciduous temperate broadleaved : PFT 5,6,7
oak = ThinningTrajectories.estimate_θrdi(6, Sexp)
ThinningTrajectories.merge_previous_plots(oak, ORCres_folder, "v0.3", 140, Sexp)


orcr = ThinningTrajectories.merge_netcdf(
    ORCres_folder, ["DIAMETER","DIA_DOM"], "stomate", Sexp)

orcr_diadom = filter(:var=>(==("DIA_DOM")), orcr)
orcr_dia = DataFrame(
    :value => 
        filter(:var=>(==("DIAMETER")), orcr)[:,"value"]./
        filter(:var=>(==("DIA_DOM")), orcr)[:,"value"],
    :var => "ratio_dia",
    :ver => orcr_diadom[:,"ver"],
    :pft => orcr_diadom[:,"pft"],
    :param => orcr_diadom[:,"param"],  
    :time => orcr_diadom[:,"time"])
orcr = append!(orcr, orcr_dia)



@df orcr_dia plot(:time, :value, 
    group= (:param, :pft, :ver), 
    ylim=(0.0,1.2), lengend = :bottomleft)
