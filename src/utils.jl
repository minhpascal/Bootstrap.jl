### check return value
function checkReturn{T}(x::T)
    length(x) != 1 ? error("Return value must be a scalar.") : x
end


function jack_knife_estimate(x::AbstractVector, fun::Function, typ::Type = typeof(fun(x)))
    n = nobs(x)
    y = zeros(typ, n)
    idx = trues(n)
    for i in 1:n
        idx[i] = false
        if i > 1
            idx[i-1] = true
        end
        y[i] = fun(x[idx])
    end
    return y
end

function jack_knife_estimate(x::DataFrames.DataFrame, fun::Function, typ::Type = typeof(fun(x)))
    n = nobs(x)
    y = zeros(typ, n)
    idx = trues(n)
    for i in 1:n
        idx[i] = false
        if i > 1
            idx[i-1] = true
        end
        y[i] = fun(x[idx,:])
    end
    return y
end


## Sample quantiles with Gaussian interpolation
## Davison and Hinkley, equation 5.6

function quantile_interp(x::AbstractVector, alpha::AbstractVector)
    x = sort(x)
    qn = Float64[quantile_interp(x, a, true) for a in alpha]
    return qn
end


function quantile_interp(x::AbstractVector, alpha::AbstractFloat, is_sorted::Bool = false)
    if !is_sorted
        x = sort(x)
    end
    n = length(x)
    k = trunc(Int, (n+1) * alpha)
    ## infinity outside of data range
    if k == 0
        return -Inf
    elseif k > (n-1)
        return Inf
    end
    tx = [quantile(Normal(), a) for a in [alpha, k/(n+1), (k+1)/(n+1)]]
    qn = (tx[1] - tx[2])/(tx[3] - tx[2]) * (x[k+1] - x[k]) + x[k]
    return qn
end


### Number of observations ###

nobs(x::AbstractVector) = length(x)
nobs(x::AbstractArray, dim::Integer = 1) = size(x, dim)
nobs(x::DataFrames.AbstractDataFrame) = nrow(x)


### Number of exact bootstrap runs

nrun_exact(n::Integer) = binomial(2n-1, n)
