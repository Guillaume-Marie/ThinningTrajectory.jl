
# Define functions to model diameter growth
@. dia_sig(x, θ) = θ[1] / (1 + exp(-θ[2] * x)) + θ[3]
@. dia_log(x, θ) = θ[1] * log(x)
@. dia_exp(x, θ) = exp(-θ[1] * x)
@. dia_pow(x, θ) = x^θ[1] + θ[2]
@. dia_lin(x, θ) = θ[1] * x 
@. dia_poly(x, θ) = θ[1] + θ[2]* x + θ[3]* x^2 +  θ[4]* x^3
@. RDI(d, θ) = d[2] / ((d[1] / θ[1])^(1.0 / θ[2]))
@. DENS(d, θ) = d[2] * ((d[1] / θ[1])^(1.0 / θ[2]))
@. BA(d) = pi*(d[1]/2)^2/10000*d[2]
@. INT(d,n) = (d[1]/d[2])^(-1/n)
@. NBC(d,x) = cld(log(d[1]/d[2]),log(x))
@. DS(d,x,n) = d*x^(n)
@. DIADOM(d,θ) = (θ[1]*(d/θ[2]) + 1)*d
@. DIAREF(d,θ) = (θ[1]*(d/θ[2]))*d

function asi_param(param, key, value)
	np=length(param[key])
	z = Vector{Union{Missing,Float64}}() # empty array
	if np===1
		push!(z, value)
	else
		for i in 1:np
			push!(z, value[i])
		end
	end
	return eval(Meta.parse("$key = $z"))
end

NaN_to_missing(x) = isnan(x) ? missing : x
missing_to_NaN(x) = ismissing(x) ? NaN : x
