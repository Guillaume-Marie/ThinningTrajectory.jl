
using Dash
using PlotlyJS
using DataFrames

include("ThinningTrajectories/src/ThinningTrajectories.jl")
include("Experiment_setup.jl")


n_poly = [2,3,4,5]
rdistart = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
iter = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

function zero_to_missing(x)
    if x == 0.0
        return missing
    else
        return x
    end
end

function update_experiment_setup(
    Sexp::Dict, v::Dict, PFT::Int64)
    for i in keys(v) 
        Sexp["Experiment"][PFT][i][PFT] = values(v[i])
    end
end

function update_sylviculture(
    Sexp::Dict, Syl::Dict, PFT::Int64)
    for i in keys(Syl) 
        x = @. zero_to_missing(values(Syl[i]))
        Sexp["Sylviculture"][PFT][i] = x
    end
end

const TYPES = [
    "NBsh","RITsh","Dsh","Lsh","DIAsh",
    "NBed","RITed","Ded","Led","DIAed",
    "NBma","RITma","Dma","Lma","DIAma",
    "NBha","RITha","Dha","Lha","DIAha",]

const VALS = 
    [2.0, 0.0, 2500.0, 6.0, 0.0,
    5.0, 0.0, 1200.0, 15.0, 0.0,
    2.0, 0.3, 200.0, 68.0, 0.0,
    3.0, 0.55, 0.0, 78.0, 45.0
]

const TYPES_all = [
        "NBsh","NBed","NBma","NBha",
        "RITsh","RITed","RITma","RITha",
        "Dsh","Ded","Dma","Dha",
        "Lsh","Led","Lma","Lha",
        "DIAsh","DIAed","DIAma","DIAha",
        "npoly","rdistart","yearstart","pft"]

const Description = [
    "Number of thinning :   ",
    "Thinning intensity :   ",
    "Density target:        ",
    "Phase length :         ",
    "Target Diameter :      "
]   

labels= [html_div(Description[i]) 
    for i in eachindex(Description)]
        
inputs =[dcc_input(
id="input_$(TYPES[i])",
type="number",
value=VALS[i])
    for i in eachindex(TYPES)]

app = dash()
# Layout of the app which plot stem-density against quadratic diameter 
# and the results of an ORC model. THe user can select the n_poly parameter from 2 to 5. 
app.layout = html_div() do    
    html_div(style = Dict("columnCount" => 5, "rowCount" => 5)) do
        vcat(labels, inputs)
    end,
    dcc_graph(id = "graph1"),
    html_div(style = Dict("columnCount" => 2, "rowCount" => 2)) do
        dcc_slider(
            id = "input_npoly",
            min = minimum(n_poly),
            max = maximum(n_poly),
            marks = Dict([Symbol(v) => Symbol(v) for v in n_poly]),
            value = 3,
            step = nothing,
        ),
        dcc_slider(
            id = "input_rdistart",
            min = minimum(rdistart),
            max = maximum(rdistart),
            marks = Dict([Symbol(v) => Symbol(v) for v in rdistart]),
            value = 0.6,
            step = nothing,
        ),
        dcc_slider(
            id = "input_yearstart",
            min = 1,
            max = 15,
            marks = Dict([Symbol(v) => Symbol(v) for v in 1:15]),
            value = 3,
            step = nothing,
        ),   
        dcc_slider(
            id = "input_pft",
            min = 1,
            max = 7,
            marks = Dict([Symbol(v) => Symbol(v) for v in 1:7]),
            value = 3,
            step = nothing,
        )
    end 
end

callback!(
    app,
    Output("graph1", "figure"), 
    [Input("input_$i", "value") for i in TYPES_all]
) do NBsh,NBed,NBma,NBha,RITsh,RITed,RITma,RITha,Dsh,
    Ded,Dma,Dha,Lsh,Led,Lma,Lha,DIAsh,DIAed,DIAma,DIAha,
    npoly, rdistart, yearstart, pft

    Syl = Dict(
        "NBph" => [NBsh[1],NBed[1],NBma[1],NBha[1]],
        "RITph" => [RITsh[1],RITed[1],RITma[1],RITha[1]],
        "Dph" => [Dsh[1],Ded[1],Dma[1],Dha[1]],
        "Lph" => [Lsh[1],Led[1],Lma[1],Lha[1]],
        "Diaph" => [DIAsh[1],DIAed[1],DIAma[1],DIAha[1]]
    )

    Intup_par = Dict(
        "n_poly" => npoly, 
        "rdistart" => rdistart, 
        "yearstart" => yearstart
    )

    update_sylviculture(Sexp, Syl, pft)
    update_experiment_setup(Sexp, Intup_par, pft)

    display(Sexp["Sylviculture"][3])

    dd1 = ThinningTrajectories.estimate_θrdi(pft, Sexp)

    ddp1 = stack(DataFrame(Qdiameter=dd1.Qdiameter, 
        density_the=dd1.stem_density, 
        density_pred=dd1.pre[2]), 2:3)

    ddp2 = stack(DataFrame(Qdiameter=dd1.Qdiameter, 
        rdi_the=dd1.rdi, 
        rdi_pred=dd1.pre[1]), 2:3)   

    pp1 = plot(
        ddp1,
        Layout(
        xaxis_title = "Quadratic diameter (cm)",
        yaxis_type = "log",
        yaxis_title = "Stem density (t/ha)",
        legend_x = 0,
        legend_y = 1,
        hovermode = "closest",
        transition_duration = 500
        ),
        x = :Qdiameter,
        y = :value,
        group= :variable,
        mode = "line"
    )
    pp2 = plot(
        ddp2,
        Layout(
        xaxis_title = "Quadratic diameter (cm)",
        yaxis_title = "Relative density index (~)",
        legend_x = 0,
        legend_y = 1,
        hovermode = "closest",
        transition_duration = 500
        ),
        x = :Qdiameter,
        y = :value,
        group= :variable,
        mode = "line"
    )
    return [pp1 pp2]
end

port = parse(Int64, ENV["PORT"])
run_server(app, "0.0.0.0", port)

