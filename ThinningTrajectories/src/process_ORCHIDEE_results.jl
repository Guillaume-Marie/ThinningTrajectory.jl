
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
    var::Vector{String}, Out::String, Sexp::Dict)

    par_dict=Sexp["Experiment"]
    params = String[]
    for i in eachindex(par_dict)
        push!(params, par_dict[i]["name"])
    end

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
                dd = DataFrame(
                    value=vi, 
                    var=fill(var[v],ldsv), 
                    ver=Sexp["Recruit"][2:end], 
                    pft=Sexp["Description"][2:end], 
                    param=params[2:end], 
                    time= fill(i,ldsv))
                data = vcat(data, dd)
            end
        end
        i += 1
    end
    return data
end

