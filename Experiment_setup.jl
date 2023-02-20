include("Parameters.jl")

Sexp = Dict(
    "PFT" => [1, 2, 3, 4, 5, 6, 7],
    "Description" => [
        "bare_soil", 
        "evergreen temperate conifer",
        "evergreen temperate conifer", 
        "evergreen temperate conifer",
        "deciduous temperate broadleaved",
        "deciduous temperate broadleaved",
        "deciduous temperate broadleaved"],
    "Sylviculture" => (
            Syl_spruce, 
            Syl_spruce,
            Syl_spruce, 
            Syl_spruce,
            Syl_oak,
            Syl_oak,
            Syl_oak),   
    "Recruit" => [
        "None", 
        "Low Taumax", 
        "Medium Taumax", 
        "High Taumax", 
        "Low Taumax", 
        "Medium Taumax", 
        "Low Taumax"], 
    "Experiment" => (
        None,
        HighRdi_S,
        HighRdi_S,
        HighRdi_S,
        HighRdi_O,
        HighRdi_O,
        HighRdi_O)
    )
)