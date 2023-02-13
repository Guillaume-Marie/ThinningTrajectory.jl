

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

"""
# plot_ORCres
Visualizes forest stem density and quadratic 
diameter, as well as results from an ORC model.

## Parameters
----------
f : Forest
    Instance of type Forest. 
orc: DataFrame
    DataFrame containing model runs.
pfts : AbstractString
    ID of the planted forest type used in the model.
recruit : AbstractString
    ID of the recruited forest type used in the model.
param : AbstractString
    ID of the response parameter used in the model.
time_limit : Int64 
    The ending time for the model.
v : Vector{String}
    Vector containing labels for the model parameters.

## Returns
-------
Subplots : tuple
    A tuple of subplots.
"""
function plot_ORCres(f::Forest, orc::DataFrame,
            pfts::AbstractString, recruit::AbstractString, 
            param::AbstractString, time_limit::Int64, 
            v::Vector{String})
    # Get the data for plotting
    dd = [
        f.pre[1],
        BA([f.Qdiameter,f.pre[2]]),
        f.Qdiameter/100,
        f.pre[2]/10000
    ]
    eqpf = eqpf2(pfts, recruit, param, time_limit)
    ORC_Resf = filter([:pft,:ver, :param, :time] => eqpf, orc)
    
    # Calculate the number of rows to use in the subplot grid
    nrows = ceil(Int,0.5*length(v))
    
    # Create an array of Plots
    subplots = repeat([plot()], length(v))
    
    # Show the legend for the last plot in the series only
    show_legend = false
    
    # Iterate over the ORC data to create a subplot for each variable
    for i in eachindex(v)
        ORC_r = filter(:var=>(==(v[i])), ORC_Resf)
        
        # Calculate the max value for the y-axis of each subplot
        maxval = maximum(ORC_r[:,"value"]) + 
            0.25 * maximum(ORC_r[:,"value"])
        
        # Set show_legend to true for the last subplot
        show_legend = (i==length(v)) ? true : false
        
        # Construct and store the subplot in the subplots array
        subplots[i] = begin
            @df ORC_r plot(:time, :value,
                           group= (:param), 
                           ylim=(0.0,maxval), 
                           legend=show_legend, 
                           label="ORC",
                           title=v[i])
            plot!(dd[i], ylim=(0.0,maxval), 
                  legend=show_legend, 
                  label = "THE")
        end
    end
    
    # Display the subplots in a grid layout 
    #with dimensions specified by nrows
    return plot(subplots..., layout=(nrows,2), size=(375*nrows, 750))
end

"""
# visualize_sylviculture
Visualizes foresr data. RDI and BDI are shown 
on separate plots, each overlayed with stem density data.

## Parameters
----------
f: Forest 
    The forest to be visualized. 
"""
function visualize_sylviculture(f::Forest) 
    
    # Calculate the maximums of forest data
    dia_max = maximum(f.Qdiameter.+5.0)
    dens_max = maximum(f.stem_density.+500.0)
    rdi_max = maximum(f.upper_rdi[2].+0.1)

    # Create subplots for a dual-axis plot
    subplots = repeat([plot()], 2)
    pl = plot()
    
    # Plot the stem density and quadratic diameter 
    #of the forest, then store each in its own subplot
    plot!(f.stem_density, color="black",label="Density",
    ylim=(0,dens_max))
    plot!(f.pre[2], label="predicted Density", combine=true,
    ylim=(0,dens_max))
    plot!(twinx(),f.Qdiameter,label="Quadratic diameter", 
    ylim=(0,dia_max), combine=true)
    plot!(twinx(),BA([f.Qdiameter,f.pre[2]]), 
    ylim=(0,dia_max), color="orange", 
    label="predicted BA", legend=:topleft)  
    subplots[1] = pl
    
    plll = plot()
    
    # Plot the quadratic diameter against rdi, 
    #along with upper & lower bounds of rdi, 
    #then store it in the other subplot
    # merge legend from both plots into one legend 
    plot!(f.Qdiameter,f.rdi, xlim=(0,dia_max), 
    ylim=(0,rdi_max), label="RDI",legend=:topright)
    plot!(f.Qdiameter,f.pre[1], xlim=(0,dia_max), 
    ylim=(0,rdi_max), color="green", 
    label="predicted RDI")  
    plot!(f.rdi_up, color="red", xlim=(0,dia_max), 
    ylim=(0,rdi_max), label="Upper bound")
    plot!(f.rdi_lo, color="blue", xlim=(0,dia_max), 
    ylim=(0,rdi_max), label="Lower bound")
    subplots[2] = plll

    # Create and display the final dual-axis plot
    return plot(subplots..., layout=(2,1), size=(500, 750))
end

# Merge the the plots of the previous function
# into one plot with multiple subplots
function merge_previous_plots(f::Forest, orc::DataFrame, nbyears::Int64)
    # Get the plots from the previous function
    p1 = plot_ORCres(f, orc, "evergreen temperate conifer", "No recruitement", 
        "Low RDI", nbyears,["RDI","BA","DIAMETER","IND"])
    p2 = visualize_sylviculture(f)
    # Create a new plot with the plots from the previous function
    display(plot(p2, p1, layout=(2,1), size=(750, 1500)))
end

