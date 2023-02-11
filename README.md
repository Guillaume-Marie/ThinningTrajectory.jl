# thinning-trajectory
A tool that help translating forest management rules into Relative density curve usable into land surface model such as ORCHIDEE

## Contents

- `ORCHIDEE_res.csv`: A CSV file containing the results of ORCHIDEE simulations.
- `app.jl`: The main application file that connects all the other files and executes the program.
- `forest_def.jl`: A file defining the `Forest` struct, which represents a forest with various fields.
- `generic_function.jl`: A file containing generic functions used throughout the program.
- `main.jl`: The main file that is executed when the program is run.
- `plots_and_layout.jl`: A file containing functions for plotting and layout of the results.
- `process_ORCHIDEE_results.jl`: A file for processing the ORCHIDEE results.
- `sylviculture_Epicea_I1EC_V.csv`: A CSV file containing data on the thinning trajectory of a specific forest of spruce trees.
- `sylviculture_chene_reg.csv`: A CSV file containing data on the thinning trajectory of a specific forest of oak trees.
- `thinning_trajectories.jl`: A file containing functions for calculating and analyzing the thinning trajectories.

## File Descriptions

### forest_def.jl
This file contains the definition of the `Forest` struct, which represents a forest and its properties. The fields of the struct include the number of sylviculture phases, target stem density for each phase, age at which each phase ends, thinning intensity for each phase, stem density of the forest, current sylviculture phase, quadratic mean diameter, relative density index, upper and lower limits of the relative density index, predictions based on polynomial models, and polynomials representing the upper and lower limits of the relative density index.

### plots_and_layout.jl
This file contains functions for plotting and layout of the results, such as plotting the relative density index and stem density over time, and setting the layout of the plots.
#### Functions
- `plot_ORCres`: plots the results of the ORCHIDEE model, filtered based on input parameters (pfts, recruit, param, and time_limit). It also plots the forest data using the input "f" forest object.

- `visualize_sylviculture`: plots the stem density, quadratic diameter, crown area, and the relationship between the quadratic diameter and relative diameter increment (rdi) using the input "f" forest object. 

#### Packages Used
- Plots
- StatsPlots

### thinning_trajectories.jl
This file contains functions for calculating and analyzing the thinning trajectories. It includes functions for calculating the relative density index, the stem density, and the quadratic mean diameter, as well as functions for analyzing the thinning trajectory and determining the optimal thinning intensity for each phase.
