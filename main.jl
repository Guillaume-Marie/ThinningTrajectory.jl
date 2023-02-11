include("constant.jl")
include("thinnig_trajectories.jl")
include("plots_and_layout.jl")
include("process_ORCHIDEE_results.jl")

ORC_RES = merge_netcdf(ORC_folder, ["RDI","BA","DIAMETER","IND"], "stomate")
CSV.write("ORCHIDEE_res2.csv", ORC_RES)

# Define an array of average diameter of a tree at various ages
ORC_Res = CSV.read("ORCHIDEE_res2.csv", DataFrame, missingstring="NaN" )
I1EC = CSV.read("sylviculture_Epicea_I1EC_V.csv", 
    DataFrame, missingstring="NaN" )
dd1 = estimate_θrdi(I1EC, ORC_Res, dia_lin, 45.0, 5, [1348.0, -0.57], 100000.0, 0.6, 3)


ORC_Res = CSV.read("ORCHIDEE_res2.csv", DataFrame, missingstring="NaN" )
I1EC = CSV.read("sylviculture_chene_reg.csv", 
    DataFrame, missingstring="NaN" )
dd2=estimate_θrdi(I1EC, ORC_Rdi, dia_lin, 70.0, 3,[2000.0, -0.67], 45000.0, 0.4, 3)
