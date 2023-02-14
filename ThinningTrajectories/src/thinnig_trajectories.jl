
include("constant.jl")
include("generic_function.jl")
include("forest_def.jl")
"""
# when_to_thin
This function updates the stem density of a forest.

It updates the `stem_density` field of the `Forest` 
struct based on the current value of `fcounter`. 
The function sets the current phase of the forest by 
finding the last phase that has an ending age 
lower than `fcounter`. It also checks if the current 
counter is divisible by the thinning frequency of the 
current phase. If it is, it subtracts the corresponding 
thinning intensity and makes sure that the stem density 
is not negative.

## Parameters
- `f::Forest`: The forest to update.
- `fcounter`: The current counter.
- `Pcounter`: The counter for the phases.
- `year`: The current year.

## Returns
- `fcounter`: The updated counter.
- `Pcounter`: The updated counter for the phases.
"""
function when_to_thin(f::Forest, fcounter::Int64, 
    Pcounter::Int64, year::Int64)
    
    f.stem_density[year] = max(f.stem_density[year-1], 0.0)

    LTph = (f.Sphase == 1) ? 
        fld(f.Lph[f.Sphase],f.NBph[f.Sphase]) :
        fld((f.Lph[f.Sphase]-f.Lph[f.Sphase-1]),
            f.NBph[f.Sphase])
     
    cut = f.stem_density[year] * f.RITph[f.Sphase]
    f.stem_density[year] -= 
        (fcounter >= LTph) * round(cut,digits=1)

    fcounter = (fcounter >= LTph) ?  fcounter = 1 :
    fcounter += 1

    if (Pcounter >= f.NBph[f.Sphase]*LTph)
        Pcounter = 1 
        f.Sphase += (f.Sphase == length(f.Lph)) ? 0 : 1

    else
        Pcounter += 1
    end

    return fcounter, Pcounter
end

"""
# when_to_thin_model
Calculate the RDI and new density for a forest, given a 
year and diameter, using the forest and model parameters.

## Parameters:
- f : Forest
    A forest object that contains the necessary 
    information such as `Qdiameter`.
- θ : Any
    Model parameters.
- year : Int64
    The year for which the RDI and new density 
        is calculated.
- dens_m : Float64
    The density used in the calculation.

## Returns:
- Tuple of the RDI and the new density.
"""
function when_to_thin_model(f::Forest, θ, year::Int64, dens_m)
    rdi = RDI([f.Qdiameter[year], dens_m], θ) 
    rdi_up = f.rdi_up(f.Qdiameter[year])
    rdi_lo = f.rdi_lo(f.Qdiameter[year])
    if rdi > rdi_up
        rdi = rdi_lo
        dens_m = DENS([f.Qdiameter[year], rdi], θ)
    end
    return rdi, dens_m
end

"""
 # thin_intensity
  A function that calculates the thinning intensity for a given sylviculture phase.
  It calculates the thinning intensity by dividing the difference between 
  the minimum and maximum quadratic diameter at the end of a phase 
  by the number of thinning events between the start and end of the phase.

 ## Parameters
  - `LTph`: The thinning frequency for each phase.
  - `Dph`: The target density at the phase ends.
  - `Lph`: The age at which each phase ends.
  - `phase`: The sylviculture phase for which the thinning intensity is calculated.

 ## Returns
  - `ITph`: The calculated thinning intensity.
"""
function thin_intensity(Dph, NBph, phase, Dst)
    ITph = (phase == 1) ? 
        (Dst - Dph[phase]) / NBph[phase] :
        (Dph[phase-1] - Dph[phase]) / NBph[phase]
    return ITph
end

function thin_param(Dph::Float64, Dst::Float64, 
    RITph::Float64, NBph::Float64)
    return RITph, NBph, Dph
end

function thin_param(Dph::Float64, Dst::Float64, 
    RITph::Missing, NBph::Float64)
    RITph_new = 1-INT([Dst, Dph], NBph)
    return RITph_new, NBph, Dph
end

function thin_param(Dph::Float64, Dst::Float64, 
    RITph::Float64, NBph::Missing)
    NBph_new = NBC([Dph, Dst],(1.0-RITph))
    return RITph, NBph_new, Dph
end

function thin_param(Dph::Missing, Dst::Float64, 
    RITph::Float64, NBph::Float64)
    Dph_new = DS(Dst, (1.0-RITph), NBph) 
    return RITph, NBph, Dph_new
end

function replace_negatives_with_zeros(x)
    @. x = x * (x > 0)
    return x
end
"""
 # create_forest
 A function that creates a Forest struct with the given parameters.

 It calculates the thinning intensity for each phase using the 
`thin_intensity` function. It also initializes 
 the `stem_density`, `Sphase`, and `Qdiameter` fields of the 
 `Forest` struct. It also applies a function to 
 the `Qdiameter` array to make sure the values are greater than 20.
 ## Parameters
 - `LTph::NTuple{4,T}`: The thinning frequency for each phase.
 - `Dph::NTuple{5,T}`: The target density at the phase ends. 
 - `Lph::NTuple{5,T}`: The age at which each phase ends. 
 - `θ::Vector{Float64}`: A Vector of parameters used to calculate 
    the quadratic diameter.
 - `nbyears::Int64`: The number of years for which the forest is 
 simulated.

 ## Returns
 - `f`: The created forest.
 - `nbyears`: The number of years for which the forest is simulated.
"""
function create_forest(PFT, syl_par::Dict, θ, ny, 
    densstart, start; mod=dia_lin)

    for (key, value) in syl_par
		asi_param(syl_par, key, value) 
	end 
    Qdiameter = collect(mod(start:ny+(start-1), θ))
    Qdiameter = replace_negatives_with_zeros(Qdiameter)
    for i in eachindex(Dph)
        RITph[i], NBph[i], Dph[i] = (i == 1) ?
        thin_param(Dph[i],densstart,RITph[i],NBph[i]) :
        thin_param(Dph[i],Dph[i-1],RITph[i],NBph[i])
    end
    return Forest(PFT=PFT, NBph=NBph, Dph=Dph, Lph=Lph, RITph=RITph, 
    stem_density=fill(densstart, ny), Sphase=1, Qdiameter=Qdiameter)
end

"""
# Function max_rdi
Computes the maximum RDI and the corresponding basal 
area density given a diameter at breast height (d), 
a vector of parameters (θ), 
the maximum number of trees per hectare (nbtree_max), 
and a target RDI (target_rdi).

## Args:
d: Diameter at breast height (d), a float
θ: Vector of parameters (θ), a vector of floats
nbtree_max: Maximum number of trees per hectare 
(nbtree_max), a float
target_rdi: Target RDI (target_rdi), a float

## Returns:
rdi: maximum RDI, a float
dens: the corresponding basal area density, a float
"""
function max_rdi(d, θ, nbtree_max, target_rdi)
    rdi = DENS([d, target_rdi], θ) > nbtree_max ?
    RDI([d,nbtree_max], θ) :
    target_rdi
    dens =DENS([d, rdi], θ)
    return rdi, dens
end 

function get_decrease_values(f::Forest)
    for i in 2:length(f.rdi)
        # Si la valeur actuelle est inférieure 
        #ou égale à 90% de la valeur précédente
        if f.rdi[i] <= f.rdi[i-1] * 0.9 
            # Ajoute la valeur actuelle au 
            #tableau des valeurs en baisse
            push!(f.upper_rdi[2], f.rdi[i-1]) 
            push!(f.lower_rdi[2], f.rdi[i])
            push!(f.upper_rdi[1], f.Qdiameter[i-1])
            push!(f.lower_rdi[1], f.Qdiameter[i])   
        end
    end
end

function fit_dia(mod, data::DataFrame, harvest_year)
    data = dropmissing(data)
    return fit_dia_int(mod, data[:,2], data[:,1], harvest_year)
end

function fit_dia_int(mod, xdata, ydata, harvest_year)
    if !isa(mod, Function)
        error("mod must be a function")
    end
    if !isa(xdata, AbstractArray) || !isa(ydata, AbstractArray)
        error("xdata and ydata must be arrays")
    end
    if !isa(harvest_year, Number)
        error("harvest_year must be a number")
    end
    return coef(LsqFit.curve_fit(mod, xdata, ydata, zeros(4)))
end

""" 
# Function  estimate_θrdi
 Given sylvicultural parameters, observational data, 
 and thinning model,
the function calculates the RDI variable, fits upper 
    and lower bounds of the RDI, 
predicts the sylvicultural evolution of a forest, and 
generates plots.

## Parameters:
- sylvicutural_param (DataFrame): A data frame containing 
sylvicultural parameters
- orc (DataFrame): A data frame containing observational data
- mod (function): A model for diameter at a given year
- data (Array{Float64}): Data used to fit the diameter model
- start (Int64): Starting year for the calculation
- selthin_est (Float64): An estimated thinning parameter
- max_dens (Float64): Maximum stem density
- target_rdi (Float64): Target RDI
- n_poly (Int64): Polynomial degree for fitting the 
upper and lower bounds

## Returns:
- f1 (Forest): A `Forest` object with calculated 
variables and plotted results
"""
function estimate_θrdi(PFT, syl_par::Dict, ORC_par::Dict; mod=dia_lin)

    nbyears = trunc(Int, syl_par["Lph"][end])
    # Find the best-fit parameters for the sigmoid function
    θ_est = fit_dia(mod, DataFrame(d=syl_par["Diaph"], 
        l= syl_par["Lph"]), nbyears)
    diastart = mod(ORC_par["yearstart"], θ_est)
    ORC_par["rdistart"], ORC_par["densstart"] = 
        max_rdi(diastart, ORC_par["selfthinning"], 
        ORC_par["densstart"], ORC_par["rdistart"])
    f1 = create_forest(PFT, syl_par, θ_est, nbyears, 
        ORC_par["densstart"], ORC_par["yearstart"]; mod=mod)
    fcounter = 2
    Pcounter = 2
    for year in 2:nbyears
        fcounter, Pcounter = when_to_thin(f1, fcounter, Pcounter, year)
    end
    # Calculate the RDI variable
    f1.rdi = RDI([f1.Qdiameter, f1.stem_density], ORC_par["selfthinning"])
    get_decrease_values(f1)
    f1.rdi_up = fit(f1.upper_rdi[1],f1.upper_rdi[2], ORC_par["n_poly"])
    f1.rdi_lo = fit(f1.lower_rdi[1],f1.lower_rdi[2], ORC_par["n_poly"])
    f1.pre = predict_sylviculture(f1, nbyears, ORC_par["selfthinning"], 
    ORC_par["densstart"], ORC_par["rdistart"])
    return f1
end

"""
# predict_sylviculture
Predict the results of a sylviculture operation.

## Parameters:
f (Forest): A forest object with the input parameters.
nbyears (Int64): Total number of years of sylviculture operation.
selthin_est (Array): Array of estimated parameters for the sigmoid function.
dens_start (Float64): Initial stem density of the forest.
rdi_start (Float64): Initial RDI of the forest.

## Returns:
Array: A 2D array with the results of RDI and stem density after each year of the sylviculture operation.

"""
function predict_sylviculture(f::Forest, nbyears::Int64, 
    selthin_est, dens_start::Float64, rdi_start::Float64) 

    rdi_m = fill(rdi_start, nbyears)
    dens_m = fill(dens_start, nbyears)
    for j in 2:nbyears
        rdi_m[j],dens_m[j] = 
        when_to_thin_model(f, selthin_est, 
        j, dens_m[j-1])
    end
    return [rdi_m,dens_m]
end