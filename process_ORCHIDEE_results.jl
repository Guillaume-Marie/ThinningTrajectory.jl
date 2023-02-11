
include("constant.jl")
using NCDatasets

"""
# merge_netcdf
The function `merge_netcdf` reads netcdf files from 
    a specified folder and concatenates data from 
    specified variables into a single DataFrame.

## Parameters:
folder (String): The path to the folder containing 
the netcdf files.
var (Vector{String}): The names of the variables to 
extract from each netcdf file.
Out (String): The identifier in the filename to look for.

## Returns:
data (DataFrame): A DataFrame containing the extracted 
variables, version, PFT, parameters and time information.

## Example:
folder = "/path/to/folder"
var = ["RDI", "BA", "GPP"]
Out = "stomate"
data = merge_netcdf(folder, var, Out)
"""
function merge_netcdf(folder::String, 
    var::Vector{String}, Out::String)

    files = readdir(folder)
    data = DataFrame(value=Float32[],var=String[],
    ver=String[], pft=String[], param=String[], 
    time=Int64[])
    i=1
    for file in files
        if occursin(Out, file)
            ds = Dataset(joinpath(folder, file))
            for v in eachindex(var)
                dsv = ds[var[v]].var[:,:][2:end]
                ldsv = length(dsv)
                vi = reshape(dsv, ldsv)
                dd = DataFrame(value=vi, var=fill(var[v],ldsv), 
                    ver=traitement[2:end], pft=PFT[2:end], 
                    param=parameters[2:end], time= fill(i,ldsv))
                data = vcat(data, dd)
            end
        end
        i += 1
    end
    return data
end

ORC_RES = merge_netcdf(ORC_folder, ["RDI","BA","DIAMETER","IND"], "stomate")
CSV.write("ORCHIDEE_res2.csv", ORC_RES)
