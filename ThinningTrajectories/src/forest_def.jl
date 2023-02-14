
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
Base.@kwdef mutable struct Forest{T}
    PFT::Int64
    NBph::T
    Dph::T
    Lph::T
    RITph::T
    stem_density::Vector{Float64}
    Sphase::Int64
    Qdiameter::Vector{Float64}
    rdi = Float64[]
    upper_rdi = [Float64[], Float64[]]
    lower_rdi = [Float64[], Float64[]]
    pre = [Float64[], Float64[]]
    rdi_up = Polynomial()
    rdi_lo = Polynomial()
end