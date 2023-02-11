
using NCDatasets

# Define a constant array of vegetation cover types
const PFT = [
    "bare_soil",
    "evergreen temperate conifer",
    "evergreen temperate conifer",
    "evergreen temperate conifer",
    "deciduous temperate broadleaved",
    "deciduous temperate broadleaved",
    "deciduous temperate broadleaved"
]

# Define a constant array of treatment types
const traitement = [
    "None",
    "No recruitement",
    "No recruitement",
    "Recruitement",
    "No recruitement",
    "No recruitement",
    "Recruitement"
]

# Define a constant array of parameter values
const parameters = [
    "None",
    "Low RDI",
    "high RDI",
    "Low RDI",
    "Low RDI",
    "high RDI",
    "Low RDI"
]

# Define a constant string with a path to a directory on the file system
const ORC_folder= "/home/guigeek/Julia_script/orc/YE"

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
