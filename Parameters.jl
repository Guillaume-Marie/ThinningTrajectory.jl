HighRdi_S = Dict(
    "name" => "HighRdi",
    "n_poly" => fill(3,7), 
    "rdistart" => fill(0.6,7), 
    "densstart" => fill(200000.0,7),
    "yearstart" => fill(5,7),
    "DOM_ratio" => fill(0.5,7),    
    "rotation_length" => fill(80,7), 
    "selfthinning" =>  fill([1348.0, -0.57],7)
)

HighRdi_O = Dict(
    "name" => "HighRdi",
    "n_poly" => fill(3,7), 
    "rdistart" => fill(0.6,7), 
    "densstart" => fill(200000.0,7),
    "yearstart" => fill(5,7),
    "DOM_ratio" => fill(0.5,7),
    "rotation_length" => fill(140,7),  
    "selfthinning" =>  fill([2000.0, -0.67],7)
)

Syl_spruce = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

Syl_oak = Dict(
    "NBph" => [5.0, 6.0, missing, 3.0], 
    "RITph" => [missing, missing, 0.275, 0.4], 
    "Dph" => [1200.0, 500.0, 80.0, missing],
    "Lph" => [15.0, 45.0, 115.0, 124.0],
    "Diaph" => [missing, missing, missing, 60.0]
)

