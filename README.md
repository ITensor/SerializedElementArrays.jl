# SerializedElementArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mtfishman.github.io/SerializedElementArrays.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mtfishman.github.io/SerializedElementArrays.jl/dev)
[![Build Status](https://github.com/mtfishman/SerializedElementArrays.jl/workflows/CI/badge.svg)](https://github.com/mtfishman/SerializedElementArrays.jl/actions)
[![Coverage](https://codecov.io/gh/mtfishman/SerializedElementArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mtfishman/SerializedElementArrays.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Installation

Install with the Julia package manager with `import Pkg; Pkg.add("SerializedElementArrays")`.

## Introduction

This package introduces a function `disk` which transfers an `AbstractArray` in memory to one stored on disk, called a `SerializedElementArray`. The elements of the original array are serialized and saved into individual files in a randomly generated directory in the current path.

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

Internally, files are written to a path in the current directory created by `tempname(".tmp"; cleanup=true)`. Therefore, the files are cleaned up once the Julia process finishes (see the Julia documentation for `tempname`). You can use `disk(a; cleanup=false)` to keep the files after the process ends. However, note that because serialization is used (with the standard library module `Serialization`), in general it is not guaranteed that the files can read and written by different versions of Julia, or an instance of Julia with a different system image. The aim of this package is to make it easier to perform calculations with collections of very large objects which collectively might not fit in memory and are not read and written very often during the calculation, and which are not necessarily needed long term after the calculation finishes. For more stable reading and writing across different versions of Julia, using packages like `HDF5`, `JLD`, or `JLD2`.

## Future plans

- Automate caching of recently accessed elements to speed up repeated access of the same elements. This could use something like [LRUCache.jl](https://github.com/JuliaCollections/LRUCache.jl).
- Make a dictionary interface through a type `SerializedElementDict`. A design question would be if the file structure should be "nested" or "shallow", i.e. when saving nested dictionaries, should the dictionaries themselves be serialized and saved to files or should the individual elements of the nested dictionaries be saved to files?

## Related packages:

- [SerializationCaches.jl](https://github.com/beacon-biosignals/SerializationCaches.jl)

