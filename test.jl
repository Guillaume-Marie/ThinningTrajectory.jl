
push!(LOAD_PATH, "ThinningTrajectories/")
using ThinningTrajectories
using DataFrames
using StatsPlots
include("Experiment_setup.jl")
version = "v0.11"
ORCres_folder = "/home/guigeek/Julia_script/orc/Output_$(version)/YE/"
ORCres_4dim = "/home/guigeek/Julia_script/orc/Output_$(version)/MO/"

# evergreen temperate conifer : PFT 2,3,4
spruce = ThinningTrajectories.estimate_θrdi(2, Sexp)
pp_s = [
    [0.45842631077055873, -0.008054207847051202, 0.0015052315685268529, -3.177845420230941e-5],
    [0.08983397818342638, 0.02849620880030135, -0.0002007047693042513, -8.974292980417947e-6]
]
ThinningTrajectories.merge_previous_plots(spruce, ORCres_folder, version, Sexp, poly_param=pp_s)

ThinningTrajectories.visualize_RDIextraction(spruce)

# deciduous temperate broadleaved : PFT 5,6,7
oak = ThinningTrajectories.estimate_θrdi(5, Sexp)
pp_o = [
    [0.7373714729598279,-0.015416856258914405,0.0009959200016314317,-1.536439822186209e-5],
    [0.4721525464343815,0.0003699592758440316,0.0003666212967303307,-8.120450529662615e-6]
]
ThinningTrajectories.merge_previous_plots(oak, ORCres_folder, version, Sexp, poly_param=pp_o)

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

orcr_dia_o = filter(:pft => (==("deciduous temperate broadleaved")), orcr_dia)
orcr_dia_s = filter(:pft => (==("evergreen temperate conifer")), orcr_dia)

orcr_diadom_o = filter(:pft => (==("deciduous temperate broadleaved")), orcr_diadom)
orcr_diadom_s = filter(:pft => (==("evergreen temperate conifer")), orcr_diadom)


@df orcr_diadom_s plot(
    :time,
    :value,
    group=(:ver, :inc),
    ylim=(0.0, 0.5),
    legend = false,
)

@df orcr_dia_s plot(
    :time,
    :value*1000,
    group=(:ver, :inc),
    ylim=(0.0, 50),
    legend_position = :topleft,
)

# DBAND
version = "DBAND"
ORCres_folder = "/home/guigeek/Julia_script/orc/Output_$(version)/YE/"
ORCres_4dim = "/home/guigeek/Julia_script/orc/Output_$(version)/MO/"

## BIA
include("Experiment_setup.jl")
uma_BIA = ThinningTrajectories.estimate_θrdi(7, DBAND)
ThinningTrajectories.visualize_sylviculture(uma_BIA)
ThinningTrajectories.visualize_RDIextraction(uma_BIA)

man_BIA = ThinningTrajectories.estimate_θrdi(6, DBAND)
ThinningTrajectories.visualize_sylviculture(man_BIA)
ThinningTrajectories.visualize_RDIextraction(man_BIA)

## BIC
include("Experiment_setup.jl")
uma_BIC = ThinningTrajectories.estimate_θrdi(3, DBAND)
ThinningTrajectories.visualize_sylviculture(uma_BIC)
uma_BIA.rdi_lo
uma_BIA.rdi_up


man_BIC = ThinningTrajectories.estimate_θrdi(2, DBAND)

ThinningTrajectories.merge_previous_plots(uma_BIC, ORCres_folder, version, DBAND)
ThinningTrajectories.merge_previous_plots(man_BIC, ORCres_folder, version, DBAND)

## FIN
include("Experiment_setup.jl")
Uma_FIN = ThinningTrajectories.estimate_θrdi(13, DBAND)
ThinningTrajectories.visualize_RDIextraction(Uma_FIN)
ThinningTrajectories.visualize_sylviculture(Uma_FIN)




man_FIN = ThinningTrajectories.estimate_θrdi(12, DBAND)

ThinningTrajectories.merge_previous_plots(uma_FIN, ORCres_folder, version, DBAND)
ThinningTrajectories.merge_previous_plots(man_FIN, ORCres_folder, version, DBAND)


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


dia_poly(1:250, pp_s[1])
dia_poly(8.229, pp[2])


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

cc= -0.08
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
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 45.0, dia_exp(45.0, cc)), 
legend=false, 
ylim=(0.0, 0.4), 
xlim=(0.0, 50.0), 
xlabel="Mean quadratic diameter (cm)", 
ylabel="Probability", 
title="Weibull PDF under thin and fell"
)
  
function Wiebull_circ_class_prop(λ, k, res, n_circ, dia_max)
    dd= WEIBULL_CDF(res:res:dia_max, λ, k)  
    dia_inc = fill(0.0, n_circ)
    for i in 1:n_circ
        dia_inc[i] = (findmax(dd.*(dd.<=(i-res)/n_circ))[2]+
            findmax(dd.*(dd.<=(i-1+res)/n_circ))[2])*res/2
    end
    return WEIBULL_PDF(dia_inc, λ, k)/sum(WEIBULL_PDF(dia_inc, λ, k))
end

cir_class_dist = Wiebull_circ_class_prop(30.0, 3.0, 1.0, 3, 100)

plot(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 3.0, 1.2))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 7.5, 1.2))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 10.0, 1.2))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 15.0, 1.2))
plot!(0.01:0.5:50, WEIBULL_PDF(0.01:0.5:50, 20.0, 1.2),
legend=false, 
ylim=(0.0, 0.3), 
xlim=(0.0, 50.0), 
xlabel="Mean quadratic diameter (cm)", 
ylabel="Probability", 
title="Weibull PDF under continuous cover forestry"
)



#### DBAND data #####

DBAND_SPRUCE_TEMPERATE = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100,150,200,250],
    [0,0,0,132.051282051282,80.4487179487179,84.2391304347826,52.1739130434783,35.3260869565217,17.6630434782609,7.06521739130435,4.80769230769231,2.35507246376812,1.81159420289855,1.26811594202899,0,0],
    [0,0,0,176.666666666667,129.166666666667,97.5,69.7916666666667,37.5,26.6025641025641,9.78260869565217,10.8333333333333,4.16666666666667,3.33333333333333,4.16666666666667,0,0],
    [0,0,0,105.70652173913,72.9166666666667,81.7307692307692,36.6666666666667,14.1666666666667,11.4583333333333,4.16666666666667,3.80434782608696,2.08333333333333,0.961538461538461,0.641025641025641,0,0]
]

mead_dia = sum(DBAND_SPRUCE_TEMPERATE[1].*(DBAND_SPRUCE_TEMPERATE[2]/sum(DBAND_SPRUCE_TEMPERATE[2])))
nb_trees = sum(DBAND_SPRUCE_TEMPERATE[2])

dist_st = WEIBULL_PDF(DBAND_SPRUCE_TEMPERATE[1], 30.0, 3.0)
rel_dist_st = dist_st/sum(dist_st)
plot(DBAND_SPRUCE_TEMPERATE[1],DBAND_SPRUCE_TEMPERATE[2]/sum(DBAND_SPRUCE_TEMPERATE[2]))
plot!(DBAND_SPRUCE_TEMPERATE[1],DBAND_SPRUCE_TEMPERATE[3]/sum(DBAND_SPRUCE_TEMPERATE[3]))
plot!(DBAND_SPRUCE_TEMPERATE[1],DBAND_SPRUCE_TEMPERATE[4]/sum(DBAND_SPRUCE_TEMPERATE[4]))
plot!(DBAND_SPRUCE_TEMPERATE[1], rel_dist_st)

cir_class_dist = Wiebull_circ_class_prop(30.0, 3.0, 1.0, 3, 100)


DBAND_SPRUCE_BOREAL = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100,150,200,250],
    [0,0,0,132.051282051282,80.4487179487179,84.2391304347826,52.1739130434783,35.3260869565217,17.6630434782609,7.06521739130435,4.80769230769231,2.35507246376812,1.81159420289855,1.26811594202899,0,0],
    [0,0,0,176.666666666667,129.166666666667,97.5,69.7916666666667,37.5,26.6025641025641,9.78260869565217,10.8333333333333,4.16666666666667,3.33333333333333,4.16666666666667,0,0],
    [0,0,0,105.70652173913,72.9166666666667,81.7307692307692,36.6666666666667,14.1666666666667,11.4583333333333,4.16666666666667,3.80434782608696,2.08333333333333,0.961538461538461,0.641025641025641,0,0]
]

DBAND_RAINFOREST_TROPICAL = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100,150,200,250],
    [0,0,0,132.051282051282,80.4487179487179,84.2391304347826,52.1739130434783,35.3260869565217,17.6630434782609,7.06521739130435,4.80769230769231,2.35507246376812,1.81159420289855,1.26811594202899,0,0],
    [0,0,0,176.666666666667,129.166666666667,97.5,69.7916666666667,37.5,26.6025641025641,9.78260869565217,10.8333333333333,4.16666666666667,3.33333333333333,4.16666666666667,0,0],
    [0,0,0,105.70652173913,72.9166666666667,81.7307692307692,36.6666666666667,14.1666666666667,11.4583333333333,4.16666666666667,3.80434782608696,2.08333333333333,0.961538461538461,0.641025641025641,0,0]
]

DBAND_SPRUCE_TEMPERATE_upper = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100],
    [0.4,0.45,0.5,0.55,0.70,0.81,0.92,0.92,0.90,0.85,0.80,0.75,0.7],
    [0.4,0.45,0.5,0.55,0.70,0.75,0.8,0.82,0.80,0.75,0.70,0.65,0.6],
    [0.4,0.45,0.5,0.55,0.70,0.71,0.72,0.72,0.70,0.65,0.60,0.55,0.5],
    [0.4,0.45,0.48,0.50,0.50,0.51,0.52,0.52,0.50,0.45,0.40,0.40,0.35],
    [0.4,0.4,0.4,0.41,0.42,0.42,0.41,0.41,0.40,0.40,0.35,0.35,0.3],
    [0.4,0.35,0.32,0.31,0.32,0.32,0.31,0.31,0.30,0.30,0.25,0.25,0.2],
    [0.4,0.35,0.25,0.21,0.22,0.22,0.21,0.21,0.20,0.20,0.15,0.15,0.1],
    ]


DBAND_SPRUCE_TEMPERATE_lower = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100],
    DBAND_SPRUCE_TEMPERATE_upper[2]*0.8,
    DBAND_SPRUCE_TEMPERATE_upper[3]*0.8,
    DBAND_SPRUCE_TEMPERATE_upper[4]*0.8,
    DBAND_SPRUCE_TEMPERATE_upper[5]*0.8,
    DBAND_SPRUCE_TEMPERATE_upper[6]*0.8,
    DBAND_SPRUCE_TEMPERATE_upper[7]*0.8,
    DBAND_SPRUCE_TEMPERATE_upper[8]*0.8
    ]



plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[2])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[2])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[2], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[2], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))

plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[3])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[3])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[3], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[3], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))


plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[4])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[4])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[4], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[4], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))

plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[5])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[5])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[5], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[5], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))

plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[6])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[6])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[6], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[6], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))

plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[7])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[7])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[7], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[7], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))
-7.143009930001306e-7
plot(DBAND_SPRUCE_TEMPERATE_upper[1],DBAND_SPRUCE_TEMPERATE_upper[8])
plot!(DBAND_SPRUCE_TEMPERATE_lower[1],DBAND_SPRUCE_TEMPERATE_lower[8])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_upper[1], DBAND_SPRUCE_TEMPERATE_upper[8], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DBAND_SPRUCE_TEMPERATE_lower[1], DBAND_SPRUCE_TEMPERATE_lower[8], zeros(4)))
plot!(DBAND_SPRUCE_TEMPERATE_upper[1], dia_poly( DBAND_SPRUCE_TEMPERATE_upper[1], cc_upper))
plot!(DBAND_SPRUCE_TEMPERATE_lower[1], dia_poly( DBAND_SPRUCE_TEMPERATE_lower[1], cc_lower))


DIPROG_OAK_TEMPERATE_upper = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100],
    [0.1,0.15,0.2,0.25,0.30,0.4,0.5,0.52,0.52,0.52,0.50,0.45,0.45]
]

DIPROG_OAK_TEMPERATE_lower = [
    [1,5,10,15,20,30,40,50,60,70,80,90,100],
    [0.08,0.10,0.15,0.2,0.23,0.27,0.4,0.4,0.4,0.4,0.4,0.35,0.35]
]

plot(DIPROG_OAK_TEMPERATE_upper[1],DIPROG_OAK_TEMPERATE_upper[2])
plot!(DIPROG_OAK_TEMPERATE_lower[1],DIPROG_OAK_TEMPERATE_lower[2])
cc_upper = coef(LsqFit.curve_fit(dia_poly, DIPROG_OAK_TEMPERATE_upper[1], DIPROG_OAK_TEMPERATE_upper[2], zeros(4)))
cc_lower = coef(LsqFit.curve_fit(dia_poly, DIPROG_OAK_TEMPERATE_lower[1], DIPROG_OAK_TEMPERATE_lower[2], zeros(4)))
plot!(DIPROG_OAK_TEMPERATE_upper[1], dia_poly( DIPROG_OAK_TEMPERATE_upper[1], cc_upper))
plot!(DIPROG_OAK_TEMPERATE_lower[1], dia_poly( DIPROG_OAK_TEMPERATE_lower[1], cc_lower))


@. SelfBA(x,θ) = ((θ[1]*x^θ[2])/2)^2*pi/10000*x
plot(100:10:10000,SelfBA(100:10:10000, [1148.0, -0.59]))

