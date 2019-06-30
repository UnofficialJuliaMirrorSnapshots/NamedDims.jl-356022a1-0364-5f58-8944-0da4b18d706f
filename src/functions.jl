# This file is for functions that just need simple standard overloading.

## Helpers:

function nameddimsarray_result(original_nda, reduced_data, reduction_dims)
    L = names(original_nda)
    return NamedDimsArray{L}(reduced_data)
end

# if reducing over `:` then results is a scalar
function nameddimsarray_result(original_nda, reduced_data, reduction_dims::Colon)
    return reduced_data
end


###################################################################################
# Overloads

# 1 Arg
for (mod, funs) in (
    (:Base, (
        :sum, :prod, :count, :maximum, :minimum, :extrema, :cumsum, :cumprod,
        :sort, :sort!,)
    ),
    (:Statistics, (:mean, :std, :var, :median)),
)
    for fun in funs
        @eval function $mod.$fun(a::NamedDimsArray; dims=:, kwargs...)
            numerical_dims = dim(a, dims)
            data = $mod.$fun(parent(a); dims=numerical_dims, kwargs...)
            return nameddimsarray_result(a, data, numerical_dims)
        end
    end
end

# 1 arg before
for (mod, funs) in (
    (:Base, (:mapslices,)),
)
    for fun in funs
        @eval function $mod.$fun(f, a::NamedDimsArray; dims=:, kwargs...)
            numerical_dims = dim(a, dims)
            data = $mod.$fun(f, parent(a); dims=numerical_dims, kwargs...)
            return nameddimsarray_result(a, data, numerical_dims)
        end
    end
end

# 2 arg before
for (mod, funs) in (
    (:Base, (:mapreduce,)),
)
    for fun in funs
        @eval function $mod.$fun(f1, f2, a::NamedDimsArray; dims=:, kwargs...)
            numerical_dims = dim(a, dims)
            data = $mod.$fun(f1, f2, parent(a); dims=numerical_dims, kwargs...)
            return nameddimsarray_result(a, data, numerical_dims)
        end
    end
end


################################################
# Non-dim Overloads

# 1 Arg
for (mod, funs) in (
    (:Base, (:zero, :one, :copy,)),
)
    for fun in funs
        @eval function $mod.$fun(a::NamedDimsArray{L}) where L
            data = $mod.$fun(parent(a))
            return NamedDimsArray{L}(data)
        end
    end
end
