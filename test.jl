
push!(LOAD_PATH, "ThinningTrajectories/")
using ThinningTrajectories
using DataFrames
using StatsPlots
include("Experiment_setup.jl")
version = "v0.7"
ORCres_folder = "/home/guigeek/Julia_script/orc/Output_$(version)/YE/"
ORCres_4dim = "/home/guigeek/Julia_script/orc/Output_$(version)/MO/"

# evergreen temperate conifer : PFT 2,3,4
spruce = ThinningTrajectories.estimate_θrdi(3, Sexp)
ThinningTrajectories.merge_previous_plots(spruce, ORCres_folder, version, Sexp)

# deciduous temperate broadleaved : PFT 5,6,7
oak = ThinningTrajectories.estimate_θrdi(6, Sexp)
ThinningTrajectories.merge_previous_plots(oak, ORCres_folder, version, Sexp)

orcr = ThinningTrajectories.merge_netcdf_4dim(
    ORCres_4dim, ["CCIND", "CCDIAMETER"], "stomate", Sexp)
orcr_diadom = filter(:var => (==("CCDIAMETER")), orcr)
orcr_dia = DataFrame(
    :value =>
        filter(:var => (==("CCDIAMETER")), orcr)[:, "value"] .*
        filter(:var => (==("CCIND")), orcr)[:, "value"],
    :var => "ratio_dia",
    :inc => orcr_diadom[:, "inc"],
    :ver => orcr_diadom[:, "ver"],
    :pft => orcr_diadom[:, "pft"],
    :param => orcr_diadom[:, "param"],
    :time => orcr_diadom[:, "time"])

orcr_dia = filter(:pft => (==("deciduous temperate broadleaved")), orcr_dia)
#orcr_dia = filter(:ver => (==("Low Taumax")), orcr_dia)

orcr_diadom = filter(:pft => (==("deciduous temperate broadleaved")), orcr_diadom)

@df orcr_diadom plot(
    :time,
    :value,
    group=(:ver, :inc),
    ylim=(0.0, 0.5),
    legend = false,
)

@df orcr_dia plot(
    :time,
    :value*1000,
    group=(:ver, :inc),
    ylim=(0.0, 50),
    legend_position = :topleft,
)

using Statistics
using Plots
using LsqFit
using Polynomials

@. WEIBULL_PDF(d,λ,k) = (k/λ) * (d/λ)^(k-1) * exp(-(d/λ)^k)
@. WEIBULL_CDF(d,λ,k) = 1 - exp(-(d/λ)^k)
@. dia_sig(x, θ) = θ[1] / (1 + exp(-θ[2] * x)) + θ[3]
@. dia_log(x, θ) = θ[1] * log(x)
@. dia_exp(x, θ) = exp(-θ[1] * x)
@. dia_pow(x, θ) = x^θ[1] + θ[2]
@. dia_lin(x, θ) = θ[1] * x 
@. dia_poly(x, θ) = θ[1] + θ[2]* x + θ[3]* x^2 +  θ[4]* x^3

WEIBULL_PARAM = [
    [3.0,7.5,10.0,20.0,30.0,40.0,45.0],
    [1.2,1.2,1.5,4.0,8.0,16.0,25.0]] # λ, k

cc=coef(LsqFit.curve_fit(dia_exp, WEIBULL_PARAM[1], WEIBULL_PARAM[1], ones(2)))

plot(WEIBULL_PARAM[1],WEIBULL_PARAM[2],
    label="Weibull parameters",
    ylab="k", xlab="λ")
plot!(WEIBULL_PARAM[1], dia_exp(WEIBULL_PARAM[1], cc))


plot(WEIBULL_PARAM[1],WEIBULL_PARAM[2],
    label="Weibull parameters",
    ylab="k", xlab="λ")

plot(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 3.0, dia_exp(3.0, cc)))
plot!(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 7.5, dia_exp(7.5, cc)))
plot!(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 10.0, dia_exp(10.0, cc)))
plot!(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 20.0, dia_exp(20.0, cc)))
plot!(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 30.0, dia_exp(30.0, cc)))
plot!(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 40.0, dia_exp(40.0, cc)))
plot!(0.01:0.5:50, WEIBULL_CDF(0.01:0.5:50, 45.0, dia_exp(45.0, cc)))
hline!([0.01,0.33,0.66,0.99], legend=false, 
    ylim=(0.0, 1.0), 
    xlim=(0.0, 50.0), 
    xlabel="diameter (cm)", 
    ylabel="probability", 
    title="Weibull CDF"
    )

plot(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 3.0, dia_exp(3.0, cc)))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 7.5, dia_exp(7.5, cc)))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 10.0, dia_exp(10.0, cc)))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 20.0, dia_exp(20.0, cc)))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 30.0, dia_exp(30.0, cc)))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 40.0, dia_exp(40.0, cc)))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 45.0, dia_exp(45.0, cc)))
  
function Wiebull_circ_class_prop(λ, k, res, n_circ, dia_max)
    dd= WEIBULL_CDF(res:res:dia_max, λ, k)  
    dia_inc = fill(0.0, n_circ)
    for i in 1:n_circ
        dia_inc[i] = (findmax(dd.*(dd.<=(i-res)/n_circ))[2]+
            findmax(dd.*(dd.<=(i-1+res)/n_circ))[2])*res/2
    end
    return WEIBULL2(dia_inc, λ, k)/sum(WEIBULL2(dia_inc, λ, k))
end

Wiebull_circ_class_prop(3.0, 1.2, 0.01, 3, 50)

plot(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 3.0, 1.1))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 7.5, 1.4))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 10.0, 1.3))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 15.0, 1.2))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 20.0, 1.0))



