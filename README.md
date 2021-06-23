# SerializedElementArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mtfishman.github.io/SerializedElementArrays.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mtfishman.github.io/SerializedElementArrays.jl/dev)
[![Build Status](https://github.com/mtfishman/SerializedElementArrays.jl/workflows/CI/badge.svg)](https://github.com/mtfishman/SerializedElementArrays.jl/actions)
[![Coverage](https://codecov.io/gh/mtfishman/SerializedElementArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mtfishman/SerializedElementArrays.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Installation

Install with the Julia package manager with `import Pkg; Pkg.add("SerializedElementArrays")`.

## Introduction

This package introduces a function `disk` which transfers an `AbstractArray` in memory to one stored on disk, called a `SerializedElementArray`. The elements of the original array are serialized and by default are saved into individual files in a randomly generated directory inside the system's temporary directory. The aim of this package is to make it easier to perform calculations with collections of very large objects which collectively might not fit in memory and are not read and written very often during the calculation, and which are not necessarily needed long term after the calculation finishes. For more stable reading and writing across different versions of Julia, we recommend using packages like `HDF5`, `JLD`, or `JLD2`.

For example:
```julia
using SerializedElementArrays: disk, pathname

a = reshape(1:6, 2, 3)
d = disk(a)
@show d isa SerializedElementArrays.SerializedElementArray
@show a[1, 2]
@show d[1, 2]
@show readdir(pathname(d))
d[2, 2] = 3
```
Normal array operations like `getindex` and `setindex!` work on `SerializedElementArray`s, but note that they involve reading from and writing to disk so will be much slower than the same operations for `Array`. Keep this in mind when using a `SerializedElementArray` and organize your code to minimizing accessing individual elements.

To create an array stored on disk with undefined elements, `disk` accepts undefined `Array`s:
```julia
using SerializedElementArrays: disk, pathname

a = Array{Matrix{Float64}}(undef, 2, 3)
d = disk(a)
@show isassigned(a, 1, 2)
@show isassigned(d, 1, 2)
@show readdir(pathname(d))
x = randn(5, 5)
d[1, 2] = x
@show x == d[1, 2]
@show readdir(pathname(d))
```
When initialized from undefined `Array`s, no files are created, but elements can be set which are then written to disk.

## Memory management

Note that currently this package does not clear data from memory when it is stored on disk (such as in the above example, where an Array is first allocated in memory and then stored on disk). Freeing memory is handled by Julia's garbage collector. For memory to be cleared, it must become unreachable and then garbage collected. You can force this manually by assigning the Array (and any objects stored in the Array, as well as references to those objects) to an empty object such as `nothing` and then call `GC.gc()`:
```julia
n = 1000
a11 = randn(n, n)
a12 = randn(n, n)
a21 = randn(n, n)
a22 = randn(n, n)
a = [a11 a12; a21 a22]
d = disk(a)
a11, a12, a21, a22 = nothing, nothing, nothing, nothing
a = nothing
GC.gc()
```
or wrap the assignment in a function (or some other local scope) such that there is no reference to the intermediate data being moved to disk outside of the function:
```julia
function make_disk_array(n)
  a11 = randn(n, n)
  a12 = randn(n, n)
  a21 = randn(n, n)
  a22 = randn(n, n)
  a = [a11 a12; a21 a22]
  return disk(a)
end

make_disk_array(10^2)
GC.gc()
```
Note that the explicit call to `GC.gc()` will be performed by Julia eventually and so is not strictly necessary, however it may be useful in situations where you are running out of memory and you want to force Julia to free memory to make more space for new allocations. 

### Experimental automatic memory management

Passing a function to `disk` which returns an `Array` will allow the memory to be automatically freed, for example:
```julia
function big_array(n) 
  a11 = randn(n, n)
  a12 = randn(n, n)
  a21 = randn(n, n)
  a22 = randn(n, n)
  return [a11 a12; a21 a22]
end

n = 10^2
disk(() -> big_array(n))

# Equivalently, the first argument
# is the function that returns the Array
# to be transferred to disk
# and the remaining arguments
# are the inputs to the function:
disk(big_array, n)
```
Internally, by default this will call `GC.gc(false)`, which performs an incremental collection of only the "young" objects in memory.

You can specify a full GC sweep with:
```julia
disk(big_array, n; full=true)
```
or turn off the call to `GC.gc` with:
```julia
disk(big_array, n; force_gc=false)
```
in which case memory will be freed automatically by Julia instead of internally in the `disk` function.

This allow usage of the do-block syntax:
```julia
n = 10^2
disk(n) do n
  a11 = randn(n, n)
  a12 = randn(n, n)
  a21 = randn(n, n)
  a22 = randn(n, n)
  return [a11 a12; a21 a22]
end
```

## File locations

Internally, files are written to a path in the system's temporary directory created by `tempname()`. In Julia 1.4 and later, the files are cleaned up once the Julia process finishes (see the Julia documentation for [tempname](https://docs.julialang.org/en/v1/base/file/#Base.Filesystem.tempname)). You can use `disk(a; cleanup=false)` to keep the files after the process ends. However, note that because serialization is used (with the standard library module [Serialization](https://docs.julialang.org/en/v1/stdlib/Serialization/)), in general it is not guaranteed that the files can be read and written by different versions of Julia, or an instance of Julia with a different system image.

## Future plans

- Automate caching of recently accessed elements to speed up repeated access of the same elements. This could use something like [LRUCache.jl](https://github.com/JuliaCollections/LRUCache.jl).
- Make a dictionary interface through a type `SerializedElementDict`. A design question would be if the file structure should be "nested" or "shallow", i.e. when saving nested dictionaries, should the dictionaries themselves be serialized and saved to files or should the individual elements of the nested dictionaries be saved to files?

## Related packages:

- [SerializationCaches.jl](https://github.com/beacon-biosignals/SerializationCaches.jl)

