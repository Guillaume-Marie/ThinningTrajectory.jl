
push!(LOAD_PATH, "ThinningTrajectories/")
using ThinningTrajectories

include("Experiment_setup.jl")
ORCres_folder="/home/guigeek/Julia_script/orc/YE/"

# evergreen temperate conifer : PFT 2,3,4
spruce = ThinningTrajectories.estimate_θrdi(3, Sexp)
ThinningTrajectories.merge_previous_plots(spruce, ORCres_folder, "v0.1", 80, Sexp)

# deciduous temperate broadleaved : PFT 5,6,7
oak = ThinningTrajectories.estimate_θrdi(6, Sexp)
ThinningTrajectories.merge_previous_plots(oak, ORCres_folder, "v0.1", 140, Sexp)
