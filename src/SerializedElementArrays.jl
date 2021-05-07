module SerializedElementArrays

using Serialization

# tempname only supports cleanup since Julia 1.4
function cleanup_default()
  return VERSION >= v"1.4"
end

# Like `tempname()` but compatible with Julia versions prior to 1.4
function temppath(path::AbstractString=tempdir(); cleanup=cleanup_default())
  if VERSION < v"1.4"
    if cleanup
      error(
        "Previous to Julia 1.4, `tempname` doesn't support the `cleanup` keyword argument so `cleanup` must be set to false.",
      )
    end
    if path ≠ tempdir()
      error(
        "`path` was specified as $path. Previous to Julia 1.4, `tempname` doesn't support customizing the path, `path` must be `tempdir() = $(tempdir())`.",
      )
    end
    return tempname()
  end
  return tempname(path; cleanup=cleanup)
end

# An Array where each element is written to disk
struct SerializedElementArray{T,N} <: AbstractArray{T,N}
  pathname::String
  dims::NTuple{N,Int}
  function SerializedElementArray{T,N}(
    ::UndefInitializer, d::NTuple{N,Integer}; cleanup=cleanup_default(), path=tempdir()
  ) where {T,N}
    mkpath(path)
    pathname = temppath(path; cleanup=cleanup)
    mkpath(pathname)
    return new{T,N}(pathname, d)
  end
end

const SerializedElementVector{T} = SerializedElementArray{T,1}
const SerializedElementMatrix{T} = SerializedElementArray{T,2}

pathname(d::SerializedElementArray) = d.pathname

function _filename(d::SerializedElementArray, I::Integer)
  return joinpath(d.pathname, "$I.bin")
end
filename(d::SerializedElementArray, I::Integer) = _filename(d, I)
filename(d::SerializedElementVector, I::Integer) = _filename(d, I)
function filename(d::SerializedElementArray, I::Integer...)
  return filename(d, CartesianIndex(I))
end
function filename(d::SerializedElementArray, I::CartesianIndex)
  return _filename(d, LinearIndices(d)[I])
end

Base.size(d::SerializedElementArray) = d.dims

# Check if the file exists, if not throw an UndefRefError
# Used in getindex and setindex! for SerializedElementArray
function checkfile(filename::AbstractString)
  !isfile(filename) && throw(UndefRefError())
  return nothing
end

function Base.getindex(d::SerializedElementArray{T}, I...)::T where {T}
  @boundscheck checkbounds(d, I...)
  filename_I = filename(d, I...)
  checkfile(filename_I)
  return deserialize(filename_I)
end

function Base.setindex!(d::SerializedElementArray, v, I...)
  @boundscheck checkbounds(d, I...)
  filename_I = filename(d, I...)
  serialize(filename_I, convert(eltype(d), v))
  return d
end

# Constructors with undefined values
function SerializedElementArray{T,N}(
  ::UndefInitializer, d::Vararg{Integer,N}; kw...
) where {T,N}
  return SerializedElementArray{T,N}(undef, d; kw...)
end
function SerializedElementArray{T,N}(; kw...) where {T,N}
  return SerializedElementArray{T,N}(undef, ntuple(_ -> 0, Val(N)); kw...)
end
function SerializedElementArray{T}(
  ::UndefInitializer, d::NTuple{N,Integer}; kw...
) where {T,N}
  return SerializedElementArray{T,N}(undef, d; kw...)
end
function SerializedElementArray{T}(
  ::UndefInitializer, d::Vararg{Integer,N}; kw...
) where {T,N}
  return SerializedElementArray{T,N}(undef, d; kw...)
end
function SerializedElementArray{<:Any,N}(
  ::UndefInitializer, d::NTuple{N,Integer}; kw...
) where {N}
  return SerializedElementArray{Any,N}(undef, d; kw...)
end
function SerializedElementArray{<:Any,N}(
  ::UndefInitializer, d::Vararg{Integer,N}; kw...
) where {N}
  return SerializedElementArray{Any,N}(undef, d; kw...)
end
function SerializedElementArray{<:Any,N}(; kw...) where {N}
  return SerializedElementArray{Any,N}(undef, ntuple(_ -> 0, Val(N)); kw...)
end

function SerializedElementArray{T,N}(A::AbstractArray; kw...) where {T,N}
  d = SerializedElementArray{T,N}(undef, size(A); kw...)
  for I in eachindex(A)
    if isassigned(A, I)
      d[I] = A[I]
    end
  end
  return d
end
function SerializedElementArray{T}(A::AbstractArray{<:Any,N}; kw...) where {T,N}
  return SerializedElementArray{T,N}(A; kw...)
end
function SerializedElementArray{<:Any,N}(A::AbstractArray{T}; kw...) where {T,N}
  return SerializedElementArray{T,N}(A; kw...)
end
function SerializedElementArray(A::AbstractArray{T,N}; kw...) where {T,N}
  return SerializedElementArray{T,N}(A; kw...)
end

"""
    SerializedElementArrays.disk(array::AbstractArray; cleanup=true, path=tempdir())

Convert the `AbstractArray` `array` to an array saved on disk of type `SerializedElementArrays.SerializedElementArray`. Each element of the array will be saved in serialized format to an individual file in a randomly generated directory.

If an `array` of type `SerializedElementArray` is input, this will simply return the original `array` (it acts like a conversion to type `SerializedElementArray`), ignoring the keyword arguments.

# Arguments
- `array::AbstractArray`: the array to convert to a `SerializedElementArrays.SerializedElementArray` stored on disk.

# Keywords
- `cleanup::Bool=true`: controls whether the process attempts to delete the returned path automatically when the process exits.
- `path=tempdir()`: the root of the path where a temporary directory will be made where the elements of the array will be saved. A directory with a random name assigned by the Base function `tempname` will be used.

!!! compat "Julia 1.4"
    This makes use of the Julia function `tempname` to create a temporary directory where the elements of the array will be saved. `tempname` only supports customizing the path and automatically cleaning up the files in Julia 1.4 and later. The `path` and `cleanup` arguments are only supported in Julia 1.4 and later, and in those previous versions they will default to `cleanup=false` and `path=tempdir()`.
"""
disk(array::AbstractArray; kw...) = SerializedElementArray(array; kw...)

disk(array::SerializedElementArray; kw...) = array

end
