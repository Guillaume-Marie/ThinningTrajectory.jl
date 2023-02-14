
Syl = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

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
    "Recruit" => [
        "None", 
        "No recruitment", 
        "No recruitment", 
        "Recruitment", 
        "No recruitment", 
        "No recruitment", 
        "Recruitment"], 
    "Experiment" => [
        "None",
        "Low Rdi",
        "High Rdi",
        "Low Rdi",
        "Low Rdi",
        "High Rdi",
        "Low Rdi"]
)

ORC_par = Dict(
    "n_poly" => 3, 
    "rdistart" => 0.6, 
    "densstart" => 100000.0,
    "yearstart" => 5,
    "selfthinning" => [1348.0, -0.57]
)
