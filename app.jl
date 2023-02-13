
include("constant.jl")
include("thinnig_trajectories.jl")
include("process_ORCHIDEE_results.jl")

using Dash
using PlotlyJS

ORC_Res = CSV.read("ORCHIDEE_res2.csv", DataFrame, missingstring="NaN" )
I1EC = CSV.read("sylviculture_Epicea_I1EC_V.csv", 
    DataFrame, missingstring="NaN" )
dd1 = estimate_θrdi(I1EC, ORC_Res, dia_lin, 45.0, 5, [1348.0, -0.57], 100000.0, 0.6, 3)

n_poly = [2,3,4,5]
rdistart = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
fertility = [30.1,35.1,40.1,45.1,50.1,55.1,60.1,65.1]

app = dash()
# Layout of the app which plot stem-density against quadratic diameter 
# and the results of an ORC model. THe user can select the n_poly parameter from 2 to 5. 
app.layout = html_div() do
    dcc_graph(id = "graph"),
    dcc_slider(
        id = "npoly-slider",
        min = minimum(n_poly),
        max = maximum(n_poly),
        marks = Dict([Symbol(v) => Symbol(v) for v in n_poly]),
        value = 3,
        step = nothing,
    ),
    dcc_slider(
        id = "rdistart-slider",
        min = minimum(rdistart),
        max = maximum(rdistart),
        marks = Dict([Symbol(v) => Symbol(v) for v in rdistart]),
        value = 0.6,
        step = nothing,
    ),
    dcc_slider(
        id = "fertility-slider",
        min = minimum(fertility),
        max = maximum(fertility),
        marks = Dict([Symbol(v) => Symbol(v) for v in fertility]),
        value = 45.1,
        step = nothing,
    )    
end

callback!(
    app,
    Output("graph", "figure"),
    Input("npoly-slider", "value"),
    Input("rdistart-slider", "value"),
    Input("fertility-slider", "value")
) do npoly, rdistart, fertility
    dd1 = estimate_θrdi(I1EC, ORC_Res, dia_lin, fertility, 5, [1348.0, -0.57], 100000.0, rdistart, npoly)
    ddp = stack(DataFrame(Qdiameter=dd1.Qdiameter, density_the=dd1.stem_density, density_pred=dd1.pre[2]), 2:3)
    println(ddp)
    return plot(
        ddp,
        Layout(
        xaxis_title = "Quadratic diameter (cm)",
        yaxis_type = "log",
        yaxis_title = "Stem density t/ha",
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
end

run_server(app, "0.0.0.0", debug = true)

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



