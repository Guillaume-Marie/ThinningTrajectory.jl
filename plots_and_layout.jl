

using DataFrames
using Plots
using StatsPlots

function plot_ORCres(f::Forest, orc::DataFrame)
    ORC_Resf = filter([:pft,:ver, :param, :time] => eqpft,orc)
    ORC_RDI = filter(:var=>(==("RDI")), ORC_Resf)
    ORC_BA = filter(:var=>(==("BA")), ORC_Resf)
    ORC_DIA = filter(:var=>(==("DIAMETER")), ORC_Resf)
    ORC_DEN = filter(:var=>(==("IND")), ORC_Resf)

    subplots = repeat([plot()], 4)
    p1 = plot(title="Rdi") 
    @df ORC_RDI plot!(:time, :value, 
        group= (:param), ylim=(0.0,0.7), legend=false)
    plot!(f.pre[1], ylim=(0.0,0.7), legend=false)
    subplots[1] = p1

    p2 = plot(title="Basal area")
    @df ORC_BA plot!(:time, :value, 
        group= (:param), ylim=(0.0,40.0), legend=false)
    plot!(BA([f.Qdiameter,f.pre[2]]), ylim=(0.0,40.0), legend=false)
    subplots[2] = p2

    p3 = plot(title="Quadratic diameter")
    @df ORC_DIA plot!(:time, :value, 
        group= (:param), ylim=(0.0,0.4), legend=false)
    plot!(f.Qdiameter/100, ylim=(0.0,0.4), legend=false)
    subplots[3] = p3

    p4 = plot(title="Stem density", legend_position=:topright)
    @df ORC_DEN plot!(:time, :value, 
        group= (:param), ylim=(0.0,1.6), label="ORC")
    plot!(f.pre[2]/10000, ylim=(0.0,1.6), label="THE")
    subplots[4] = p4

    display(plot(subplots..., layout=(2,2), size=(750, 750)))
end

function visualize_sylviculture(f::Forest) 
    
    subplots = repeat([plot()], 2)
    pl = plot()        
    dia_max = maximum(f.Qdiameter.+5.0)
    rdi_max = maximum(f.upper_rdi[2].+0.1)
    # Plot the stem density and quadratic diameter of the forest
    plot!(f.stem_density, color="black",legend = false)
    plot!(f.pre[2])
    plot!(twinx(),BA([f.Qdiameter,f.pre[2]]),
        ylim=(0,dia_max), color="orange")  
    plot!(twinx(),f.Qdiameter,legend = false, ylim=(0,dia_max))
    subplots[1] = pl

    plll = plot()
    plot!(f.Qdiameter,f.rdi, xlim=(0,dia_max), 
        ylim=(0,rdi_max))
    plot!(twinx(),f.Qdiameter,f.pre[1], xlim=(0,dia_max), 
        ylim=(0,rdi_max), color="green")  
    plot!(twinx(),f.rdi_up, color="red", xlim=(0,dia_max), 
        ylim=(0,rdi_max), legend=false)
    plot!(twinx(),f.rdi_lo, color="blue", xlim=(0,dia_max), 
        ylim=(0,rdi_max), legend=false)
    subplots[2] = plll
   
    display(plot(subplots..., layout=(2,1), size=(500, 500)))
end


eqpft(name::AbstractString, name2::AbstractString, 
    name3::AbstractString, names4::Int64) = 
    name == "evergreen temperate conifer" && 
    name2 == "No recruitement" &&
    name3 == "high RDI" &&
    names4 < 80
