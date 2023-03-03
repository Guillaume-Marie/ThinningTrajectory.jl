
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
        Sexp::Dict, time_limit::Int64, v::Vector{String}; poly_param)
    # Get the data for plotting
    
    if poly_param === nothing
        poly_param_lo = f.rdi_lo
        poly_param_up = f.rdi_up
    else
        poly_param_up = Polynomial(poly_param[1])
        poly_param_lo = Polynomial(poly_param[2])
    end

    rdilo= fill(0.0, length(f.Qdiameter))
    for i in 1:length(f.Qdiameter)
        rdilo[i] = poly_param_lo(f.Qdiameter[i])
    end

    rdiup= fill(0.0, length(f.Qdiameter))
    for i in 1:length(f.Qdiameter)
        rdiup[i] = poly_param_up(f.Qdiameter[i])
    end   

    recruit = Sexp["Recruit"][f.PFT]
    pfts = Sexp["Description"][f.PFT]
    param = Sexp["Experiment"][f.PFT]
    ORC_Resf = filter([:pft, :ver, :param, :time] => 
        (n1,n2, n3, n4)-> 
            n1 == pfts && 
            n2 == recruit && 
            n3 == param["name"] && 
            n4 < time_limit, orc)

    ORC_dia = filter(:var=>(==("DIAMETER_MAN")), ORC_Resf)

    rdilo2= fill(0.0, length(ORC_dia[:,"value"]))
    for i in 1:length(ORC_dia[:,"value"])
        rdilo2[i] = poly_param_lo(ORC_dia[i,"value"]*100)
    end

    rdiup2= fill(0.0, length(ORC_dia[:,"value"]))
    for i in 1:length(ORC_dia[:,"value"])
        rdiup2[i] = poly_param_up(ORC_dia[i,"value"]*100)
    end   

    dd = Dict(
        "RDI" => [f.pre[1],:identity],
        "RDI_TARGET_UPPER" => [[rdiup,rdiup2],:identity],
        "RDI_TARGET_LOWER" => [[rdilo,rdilo2],:identity],
        "BA" => [BA([f.Qdiameter,f.pre[2]]),:identity],
        "DIAMETER_MAN" => [f.Qdiameter/100,:identity],
        "IND" => [f.pre[2]/10000,:indentity]
    )   

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
        mm = dd[v[i]][1]
 
        if mm isa Vector{Vector{Float64}}
            mm = mm[2]
            println(mm)
        end
        maxval = maximum(mm) + 0.3 * maximum(mm)
        
        # Set show_legend to true for the last subplot
        show_legend = (i==length(v)) ? true : false
        
        # Construct and store the subplot in the subplots array
        subplots[i] = begin
            @df ORC_r plot(:time, :value,
                           group= (:param), 
                           ylim=(0.0,maxval),
                           yaxis= dd[v[i]][2], 
                           legend=show_legend, 
                           label="ORC",
                           title=v[i])
            plot!(dd[v[i]][1], ylim=(0.0,maxval), 
                  legend=show_legend,
                  yaxis= dd[v[i]][2],
                  label = "THE")
        end
    end
    
    # Display the subplots in a grid layout 
    #with dimensions specified by nrows
    return plot(subplots..., layout=(nrows,2), size=(375*nrows, 700))
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
function merge_previous_plots(f::Forest, orc::String, 
    version::String, Sexp::Dict; 
    var=["RDI","RDI_TARGET_UPPER","RDI_TARGET_LOWER","DIAMETER_MAN","BA","IND"]::Vector{String}, 
    Out="stomate",
    poly_param= nothing)::Nothing

    nbyears = Sexp["Experiment"][f.PFT]["rotation_length"][f.PFT]
    # Get the plots from the previous function
    if "OCHIDEE_"*version in readdir(orc)
        orcr = CSV.read(orc*"OCHIDEE_"*version*".csv", DataFrame)
        var = unique(orcr[:,"var"])
    else
        orcr = merge_netcdf(orc, var, Out, Sexp)
        CSV.write(orc*"OCHIDEE_"*version*".csv", orcr)
    end
    
    p1 = plot_ORCres(f, orcr, Sexp, nbyears, var; poly_param=poly_param)
    p2 = visualize_sylviculture(f)
    # Create a new plot with the plots from the previous function
    display(plot(p2, p1, layout=(2,1), size=(1000, 1700)))
end