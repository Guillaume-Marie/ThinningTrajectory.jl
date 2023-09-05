HighRdi_S = Dict(
    "name" => "HighRdi_S",
    "n_poly" => fill(3,7), 
    "rdistart" => fill(0.1,7), 
    "densstart" => fill(200000.0,7),
    "yearstart" => fill(5,7),
    "DOM_ratio" => fill(0.5,7),    
    "rotation_length" => fill(80,7), 
    "selfthinning" =>  fill([1348.0, -0.57],7)
)

HighRdi_O = Dict(
    "name" => "HighRdi_O",
    "n_poly" => fill(3,7), 
    "rdistart" => fill(0.1,7), 
    "densstart" => fill(200000.0,7),
    "yearstart" => fill(5,7),
    "DOM_ratio" => fill(0.5,7),
    "rotation_length" => fill(140,7),  
    "selfthinning" =>  fill([2000.0, -0.67],7)
)

DBAND_Needleleaf_temperate = Dict(
    "name" => "DBAND_Needleleaf_temperate",
    "n_poly" => fill(2,17), 
    "rdistart" => fill(0.1,17), 
    "densstart" => fill(200000.0,17),
    "yearstart" => fill(5,17),
    "DOM_ratio" => fill(0.5,17),    
    "rotation_length" => fill(200,17), 
    "selfthinning" =>  fill([1348.0, -0.57],17)
)

DBAND_Needleleaf_boreal = Dict(
    "name" => "DBAND_Needleleaf_boreal",
    "n_poly" => fill(2,17), 
    "rdistart" => fill(0.1,17), 
    "densstart" => fill(200000.0,17),
    "yearstart" => fill(5,17),
    "DOM_ratio" => fill(0.5,17),    
    "rotation_length" => fill(200,17), 
    "selfthinning" =>  fill([2827.0, -0.73],17)
)

DBAND_Evergreen_Tropical = Dict(
    "name" => "DBAND_Evergreen_Tropical",
    "n_poly" => fill(2,17), 
    "rdistart" => fill(0.1,17), 
    "densstart" => fill(200000.0,17),
    "yearstart" => fill(5,17),
    "DOM_ratio" => fill(0.5,17),    
    "rotation_length" => fill(200,17), 
    "selfthinning" =>  fill([2827.0, -0.73],17)
)

Semi_S = Dict(
    "name" => "Semi_S",
    "n_poly" => fill(3,7), 
    "rdistart" => fill(0.1,7), 
    "densstart" => fill(2000.0,7),
    "yearstart" => fill(5,7),
    "DOM_ratio" => fill(0.5,7),    
    "rotation_length" => fill(250,7), 
    "selfthinning" =>  fill([1348.0, -0.57],7)
)
# BIA
Unmanaged_Spruce_Temperate = Dict(
    "NBph" => [4, 10,10, 10],
    "RITph" => [missing, missing, missing, missing], 
    "Dph" => [2550.0, 616.0, 316.0, 90.0],
    "Lph" => [10.0, 75.0, 125.0, 200.0],
    "Diaph" => [missing, missing, missing, 80.0]
)

Unmanaged_Oak_Temperate = Dict(
    "NBph" => [missing, missing, missing, missing],
    "RITph" => [0.1, 0.1, 0.1, 0.1], 
    "Dph" => [1800.0, 1000.0, 416.0, 100.0],
    "Lph" => [20.0, 75.0, 125.0, 200.0],
    "Diaph" => [7.0, 35.0, 50.0, 80.0]
)

# FIN
Unmanaged_Spruce_Boreal =  Dict(
    "NBph" => [4, 10, 10, 10],
    "RITph" => [missing, missing, missing, missing], 
    "Dph" => [2550.0, 616.0, 316.0, 90.0],
    "Lph" => [10.0, 75.0, 125.0, 200.0],
    "Diaph" => [missing, missing, missing, 60.0]
)

Unmanaged_Oak_Boreal = Dict(
    "NBph" => [missing, missing, missing, missing], 
    "RITph" => [0.1, 0.1, 0.1, 0.1], 
    "Dph" => [1500.0, 700.0, 300.0, 50.0],
    "Lph" => [20.0, 75.0, 125.0, 200.0],
    "Diaph" => [5.0, 30.0, 40.0, 70.0]
)

Unmanaged_Larix_Boreal = Dict(
    "NBph" => [missing, missing, missing, missing], 
    "RITph" => [0.1, 0.1, 0.1, 0.1], 
    "Dph" => [1500.0, 700.0, 300.0, 50.0],
    "Lph" => [20.0, 75.0, 125.0, 200.0],
    "Diaph" => [5.0, 30.0, 40.0, 70.0]
)

# BIC
Unmanaged_Evergreen_Tropical = Dict(
    "NBph" => [4, 11, 8, 4],
    "RITph" => [missing, missing, missing, missing], 
    "Dph" => [1550.0, 300.0, 150.0, 50.0],
    "Lph" => [10.0, 70.0, 125.0, 200.0],
    "Diaph" => [missing, missing, missing, 100.0]
)

Futaie_Reg_Evergreen_Tropical = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

Futaie_Reg_Larix_Boreal = Dict(
    "NBph" => [5.0, 6.0, missing, 3.0], 
    "RITph" => [missing, missing, 0.275, 0.4], 
    "Dph" => [1200.0, 500.0, 80.0, missing],
    "Lph" => [15.0, 45.0, 115.0, 124.0],
    "Diaph" => [missing, missing, missing, 60.0]
)


# Norway Spruce (Picea Abies)

## Futaie Regular

Futaie_Reg_Spruce_Temperate = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

Futaie_Reg_Spruce_Boreal = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

## Futaie irreguliere

Futaie_Irr_Spruce_Temperate = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

Futaie_Irr_Spruce_Boreal = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

# Oak (Quercus petraea, robur et pubescens)

## Futaie Regular

Futaie_Reg_Oak_Temperate = Dict(
    "NBph" => [5.0, 6.0, missing, 3.0], 
    "RITph" => [missing, missing, 0.275, 0.4], 
    "Dph" => [1200.0, 500.0, 80.0, missing],
    "Lph" => [15.0, 45.0, 115.0, 124.0],
    "Diaph" => [missing, missing, missing, 60.0]
)

Futaie_Reg_Oak_Boreal = Dict(
    "NBph" => [5.0, 6.0, missing, 3.0], 
    "RITph" => [missing, missing, 0.275, 0.4], 
    "Dph" => [1200.0, 500.0, 80.0, missing],
    "Lph" => [15.0, 45.0, 115.0, 124.0],
    "Diaph" => [missing, missing, missing, 60.0]
)

## Futaie irreguliere

Futaie_Irr_Oak_Temperate = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)

Futaie_Irr_Oak_Boreal = Dict(
    "NBph" => [2.0, 2.0, missing, 2.0], 
    "RITph" => [missing, missing, 0.3, 0.55], 
    "Dph" => [2500.0, 1500.0, 200.0, missing],
    "Lph" => [6.0, 18.0, 68.0, 78.0],
    "Diaph" => [missing, missing, missing, 45.0]
)