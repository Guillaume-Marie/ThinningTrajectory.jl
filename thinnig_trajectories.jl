
using LsqFit
using Polynomials
using FileIO

"""
# Forest struct
A struct that represents a forest with generic type `T` for the fields.

## Fields
- `NBph::T`: The number of sylviculture phases.
- `Dph::T`: The target stem density for each phase.
- `Lph::T`: The age at which each phase ends.
- `RITph::T`: The thinning intensity for each phase.
- `stem_density::T`: The stem density of the forest.
- `Sphase::Int16`: The current sylviculture phase of the forest.
- `Qdiameter::T`: The quadratic mean diameter of the forest.
- `rdi::T`: The relative density index of the forest.
- `upper_rdi::Vector{T}`: The upper limit of the relative density 
index for each phase.
- `lower_rdi::Vector{T}`: The lower limit of the relative density 
index for each phase.
- `pre::Vector{T}`: The predictions for rdi and density base on the 
polynomial models.
- `rdi_up::Polynomial`: A polynomial representing the upper limit 
of the relative density index.
- `rdi_lo::Polynomial`: A polynomial representing the lower limit 
of the relative density index.
"""
mutable struct Forest{T}
    NBph::T
    Dph::T
    Lph::T
    RITph::T
    stem_density::T
    Sphase::Int16
    Qdiameter::T
    rdi::T
    upper_rdi::Vector{T}
    lower_rdi::Vector{T}
    pre::Vector{T}
    rdi_up::Polynomial
    rdi_lo::Polynomial
end

include("plots_and_layout.jl")

"""
# when_to_thin(f, fcounter) 
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
function when_to_thin(f::Forest, fcounter::Int32, 
    Pcounter::Int32, year::Int64)
    
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

function when_to_thin_model(f::Forest, θ, year::Int64, dens_m)
    rdi = RDI([f.Qdiameter[year], dens_m], θ) 
    if rdi > f.rdi_up(f.Qdiameter[year])
        rdi = f.rdi_lo(f.Qdiameter[year])
        dens_m = DENS([f.Qdiameter[year], rdi], θ)
    end
    dens_m = DENS([f.Qdiameter[year], rdi], θ)
    return rdi, dens_m
end

"""
 # thin_intensity(LTph, Dph, Lph, phase)
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
 # create_forest(LTph, Dph, Lph, θ, nbyears)
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
 - `nbyears::Int64`: The number of years for which the forest is simulated.

 ## Returns
 - `f`: The created forest.
 - `nbyears`: The number of years for which the forest is simulated.
"""
function create_forest(data, θ, mod, ny, dens_start, start)

    data = Array(data)
    RITph = fill(0.0, length(data[1,:])) 
    NBph = fill(0.0, length(data[1,:]))
    Dph = fill(0.0, length(data[1,:])) 
    Lph::Vector{Float64} = data[4,:]
    stem_density = fill(dens_start, ny) 
    Sphase::Int16 = 1
    Qdiameter = collect(mod(start:ny+(start-1), θ))
    Qdiameter = replace_negatives_with_zeros(Qdiameter)
    for i in eachindex(data[1,:])
        RITph[i], NBph[i], Dph[i] = (i == 1) ?
        thin_param(data[3,i],dens_start,data[2,i],data[1,i]) :
        thin_param(data[3,i],data[3,i-1],data[2,i],data[1,i])
    end
    println(typeof(Qdiameter))
    f = Forest(NBph, Dph, Lph , RITph, 
        stem_density, Sphase, Qdiameter, 
        Float64[], [Float64[],Float64[]], 
        [Float64[],Float64[]],[Float64[],Float64[]],
        Polynomial(),Polynomial())
    return f
end

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

function fit_dia(mod, data::Vector{Vector{Float64}}, harvest_year)
    σ_fit = LsqFit.curve_fit(mod, data[2], data[1], zeros(4))
    θ_est = coef(σ_fit)
    return θ_est
end

function fit_dia(mod, data::Float64, harvest_year)
    σ_fit = LsqFit.curve_fit(mod, [0.0, harvest_year],
        [0.00001,data], zeros(4))
    θ_est = coef(σ_fit)
    return θ_est
end

function fit_dia(mod, data::Vector{Float64}, harvest_year)
    σ_fit = LsqFit.curve_fit(mod, [0.0,data[2]],[0.00001,data[1]], zeros(4)) 
    θ_est = coef(σ_fit)
    return θ_est
end

function estimate_θrdi(sylvicutural_param::DataFrame, orc::DataFrame, 
    mod, data, start, selthin_est, max_dens, target_rdi, n_poly)

    nbyears = trunc(Int, sylvicutural_param[4,4])
    # Find the best-fit parameters for the sigmoid function
    θ_est = fit_dia(mod, data, nbyears)
    dia_start = mod(start, θ_est)
    rdi_start, dens_start = 
        max_rdi(dia_start, selthin_est, max_dens, target_rdi)
    f1 = create_forest(sylvicutural_param, 
        θ_est, mod, nbyears, dens_start, start)
    fcounter::Int32 = 2
    Pcounter::Int32 = 2
    for year in 2:nbyears
        fcounter, Pcounter = when_to_thin(f1, fcounter, Pcounter, year)
    end
    # Calculate the RDI variable
    f1.rdi = RDI([f1.Qdiameter, f1.stem_density], selthin_est)
    get_decrease_values(f1)
    f1.rdi_up = fit(f1.upper_rdi[1],f1.upper_rdi[2], n_poly)
    f1.rdi_lo = fit(f1.lower_rdi[1],f1.lower_rdi[2], n_poly)
    f1.pre = predict_sylviculture(f1, nbyears, selthin_est, 
        dens_start, rdi_start)
    visualize_sylviculture(f1)
    plot_ORCres(f1, orc)
    return f1
end

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

function update_table(table, 
    param::Array{Float64})

    n, m = size(table)
    @inbounds for i in 1:n, j in 1:m
        idx = (i - 1) * m + j
        if param[idx] > 0.0
            table[i, j] = param[idx]
        end
    end
    return table
end

# Define functions to model diameter growth
@. dia_sig(x, θ) = θ[1] / (1 + exp(-θ[2] * x)) + θ[3]
@. dia_log(x, θ) = θ[1] * log(x)
@. dia_exp(x, θ) = exp(-θ[1] * x)
@. dia_pow(x, θ) = x^θ[1] + θ[2]
@. dia_lin(x, θ) = θ[1] * x 
@. dia_poly(x, θ) = θ[1] + θ[2]* x + θ[3]* x^2 +  θ[4]* x^3
@. RDI(d, θ) = d[2] / ((d[1] / θ[1])^(1.0 / θ[2]))
@. DENS(d, θ) = d[2] * ((d[1] / θ[1])^(1.0 / θ[2]))
@. BA(d) = pi*(d[1]/2)^2/10000*d[2]
@. INT(d,n) = (d[1]/d[2])^(-1/n)
@. NBC(d,x) = cld(log(d[1]/d[2]),log(x))
@. DS(d,x,n) = d*x^(n)
