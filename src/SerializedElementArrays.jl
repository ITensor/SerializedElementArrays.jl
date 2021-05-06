module SerializedElementArrays

using Serialization

export DiskVector, DiskMatrix, DiskArray, disk

curdir_tempname() = ".tmp"

# An Array where each element is written to disk
struct SerializedElementArray{T,N} <: AbstractArray{T,N}
  pathname::String
  dims::NTuple{N,Int}
  function SerializedElementArray{T,N}(::UndefInitializer, d::NTuple{N,Integer}; cleanup=true) where {T,N}
    mkpath(curdir_tempname())
    pathname = tempname(curdir_tempname(); cleanup=cleanup)
    mkpath(pathname)
    return new{T,N}(pathname, d)
  end
end

const SerializedElementVector{T} = SerializedElementArray{T,1}
const SerializedElementMatrix{T} = SerializedElementArray{T,2}

# Shorthand for SerializedElementArray
const DiskArray{T,N} = SerializedElementArray{T,N}
const DiskMatrix{T} = SerializedElementMatrix{T}
const DiskVector{T} = SerializedElementVector{T}

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
SerializedElementArray{T,N}(::UndefInitializer, d::Vararg{Integer,N}; kw...) where {T,N} = SerializedElementArray{T,N}(undef, d; kw...)
SerializedElementArray{T,N}(; kw...) where {T,N} = SerializedElementArray{T,N}(undef, ntuple(_ -> 0, Val(N)); kw...)
SerializedElementArray{T}(::UndefInitializer, d::NTuple{N,Integer}; kw...) where {T,N} = SerializedElementArray{T,N}(undef, d; kw...)
SerializedElementArray{T}(::UndefInitializer, d::Vararg{Integer,N}; kw...) where {T,N} = SerializedElementArray{T,N}(undef, d; kw...)
SerializedElementArray{<:Any,N}(::UndefInitializer, d::NTuple{N,Integer}; kw...) where {N} = SerializedElementArray{Any,N}(undef, d; kw...)
SerializedElementArray{<:Any,N}(::UndefInitializer, d::Vararg{Integer,N}; kw...) where {N} = SerializedElementArray{Any,N}(undef, d; kw...)
SerializedElementArray{<:Any,N}(; kw...) where {N} = SerializedElementArray{Any,N}(undef, ntuple(_ -> 0, Val(N)); kw...)

function SerializedElementArray{T,N}(A::AbstractArray; kw...) where {T,N}
  d = SerializedElementArray{T,N}(undef, size(A); kw...)
  for I in eachindex(A)
    d[I] = A[I]
  end
  return d
end
SerializedElementArray{T}(A::AbstractArray{<:Any,N}; kw...) where {T,N} = SerializedElementArray{T,N}(A; kw...)
SerializedElementArray{<:Any,N}(A::AbstractArray{T}; kw...) where {T,N} = SerializedElementArray{T,N}(A; kw...)
SerializedElementArray(A::AbstractArray{T,N}; kw...) where {T,N} = SerializedElementArray{T,N}(A; kw...)

disk(A::AbstractArray; kw...) = SerializedElementArray(A; kw...)

end
