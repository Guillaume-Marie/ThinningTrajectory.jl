
include("thinnig_trajectories.jl")
using Plots
using StatsPlots

function eqpf2(name1, name2, name3, limit)
    fun = String("eqpft(name::AbstractString, 
                    name2::AbstractString, 
                    name3::AbstractString, 
                    names4::Int64) = 
                        name == \"$name1\" && 
                        name2 == \"$name2\" && 
                        name3 == \"$name3\" && 
                        names4 < $limit")
    return @eval $(Meta.parse(fun))
end

function plot_ORCres(f::Forest, orc::DataFrame, 
    pfts::AbstractString, recruit::AbstractString, 
    param::AbstractString, time_limit::Int64, v::Vector{String})
    
    dd = [
        f.pre[1],
        BA([f.Qdiameter,f.pre[2]]),
        f.Qdiameter/100,
        f.pre[2]/10000
    ]
    eqpf2(pfts, recruit, param, time_limit)
    ORC_Resf = filter([:pft,:ver, :param, :time] => eqpft, orc)
    nrows = ceil(Int,0.5*length(v))
    subplots = repeat([plot()], length(v))
    show_legend = false
    for i in eachindex(v)
        show_legend = (i==length(v)) ? true : false
        ORC_r = filter(:var=>(==(v[i])), ORC_Resf)
        println(ORC_Resf)
        maxval = maximum(ORC_r[:,"value"]) + 
            0.25 * maximum(ORC_r[:,"value"])
        subplots[i] = begin
            @df ORC_r plot(:time, :value, 
            group= (:param), 
            ylim=(0.0,maxval), 
            legend=show_legend, label="ORC")
            plot!(dd[i], ylim=(0.0,maxval), 
                legend=show_legend, 
                label = "THE")
        end
    end
    display(plot(subplots..., layout=(nrows,2), size=(375*nrows, 750)))
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

