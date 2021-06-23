using SerializedElementArrays
using Test

using SerializedElementArrays: disk

@testset "SerializedElementArrays.jl" begin
  @testset "SerializedElementArrays.SerializedElementVector" begin
    d = SerializedElementArrays.SerializedElementVector()
    @test size(d) == (0,)
    @test length(d) == 0
    @test ndims(d) == 1
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    @test !isfile(SerializedElementArrays.filename(d, 1))

    d = SerializedElementArrays.SerializedElementVector(undef, 4)
    @test size(d) == (4,)
    @test length(d) == 4
    @test ndims(d) == 1
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test !isfile(SerializedElementArrays.filename(d, n))
      @test !isassigned(d, n)
    end
    d[1] = 1
    @test isfile(SerializedElementArrays.filename(d, 1))
    @test d[1] == 1
    d[2] = 1.2
    @test isfile(SerializedElementArrays.filename(d, 2))
    @test d[2] == 1.2
    d[3] = "XXX"
    @test d[3] == "XXX"
    @test isfile(SerializedElementArrays.filename(d, 3))
    @test !isassigned(d, 4)
    @test_throws UndefRefError d[4]

    d = SerializedElementArrays.SerializedElementVector{Int}(undef, 4)
    @test size(d) == (4,)
    @test length(d) == 4
    @test ndims(d) == 1
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test !isfile(SerializedElementArrays.filename(d, n))
      @test !isassigned(d, n)
    end
    d[1] = 1
    @test isfile(SerializedElementArrays.filename(d, 1))
    @test isassigned(d, 1)
    @test d[1] == 1
    @test_throws InexactError d[2] = 1.2

    d = SerializedElementArrays.SerializedElementVector(1:6)
    @test size(d) == (6,)
    @test length(d) == 6
    @test ndims(d) == 1
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
    end

    d = SerializedElementArrays.SerializedElementVector{Float64}(1:6)
    @test size(d) == (6,)
    @test length(d) == 6
    @test ndims(d) == 1
    @test eltype(d) == Float64
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
    end

    a = Array(d)
    @test a isa Vector{Float64}
    @test length(a) == 6
    for n in 1:length(a)
      @test a[n] == n
    end

    a = Vector(d)
    @test a isa Vector{Float64}
    @test length(a) == 6
    for n in 1:length(a)
      @test a[n] == n
    end

    a = Vector{ComplexF64}(d)
    @test a isa Vector{ComplexF64}
    @test length(a) == 6
    for n in 1:length(a)
      @test a[n] == complex(n)
    end

    @test_throws MethodError Matrix(d)

    d2 = disk(a)
    @test d2 isa SerializedElementArrays.SerializedElementVector{ComplexF64}
    @test size(d2) == (6,)
    @test SerializedElementArrays.pathname(d) ≠ SerializedElementArrays.pathname(d2)
  end

  @testset "SerializedElementArrays.SerializedElementMatrix" begin
    d = SerializedElementArrays.SerializedElementMatrix()
    @test size(d) == (0, 0)
    @test length(d) == 0
    @test ndims(d) == 2
    @test eltype(d) == Any

    d = SerializedElementArrays.SerializedElementMatrix(undef, 4, 5)
    @test size(d) == (4, 5)
    @test length(d) == 20
    @test ndims(d) == 2
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test !isfile(SerializedElementArrays.filename(d, n))
      @test !isassigned(d, n)
    end
    d[1] = 1
    @test isfile(SerializedElementArrays.filename(d, 1))
    @test d[1] == 1
    d[2] = 1.2
    @test isfile(SerializedElementArrays.filename(d, 2))
    @test d[2] == 1.2
    d[3] = "XXX"
    @test d[3] == "XXX"
    @test isfile(SerializedElementArrays.filename(d, 3))
    d[1, 2] = "YYY"
    @test d[1, 2] == "YYY"
    @test d[5] == "YYY"
    @test isfile(SerializedElementArrays.filename(d, 1, 2))
    @test isfile(SerializedElementArrays.filename(d, 5))
    @test !isassigned(d, 4)
    @test_throws UndefRefError d[4]

    d = SerializedElementArrays.SerializedElementMatrix{Int}(undef, 4, 5)
    @test size(d) == (4, 5)
    @test length(d) == 20
    @test ndims(d) == 2
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test !isfile(SerializedElementArrays.filename(d, n))
      @test !isassigned(d, n)
    end
    d[1, 2] = 1
    @test isfile(SerializedElementArrays.filename(d, 5))
    @test isfile(SerializedElementArrays.filename(d, 1, 2))
    @test isassigned(d, 5)
    @test isassigned(d, 1, 2)
    @test d[1, 2] == 1
    @test d[5] == 1
    @test_throws InexactError d[2, 2] = 1.2

    d = SerializedElementArrays.SerializedElementMatrix(reshape(1:6, 2, 3))
    @test size(d) == (2, 3)
    @test length(d) == 6
    @test ndims(d) == 2
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
      @test d[n] isa Int64
    end

    d = SerializedElementArrays.SerializedElementMatrix{Float64}(reshape(1:6, 2, 3))
    @test size(d) == (2, 3)
    @test length(d) == 6
    @test ndims(d) == 2
    @test eltype(d) == Float64
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
      @test d[n] isa Float64
    end

    a = Array(d)
    @test a isa Matrix{Float64}
    @test length(a) == 6
    for n in 1:length(a)
      @test a[n] == n
    end

    a = Matrix(d)
    @test a isa Matrix{Float64}
    @test length(a) == 6
    for n in 1:length(a)
      @test a[n] == n
    end

    d2 = disk(a)
    @test d2 isa SerializedElementArrays.SerializedElementMatrix{Float64}
    @test size(d2) == (2, 3)
    @test SerializedElementArrays.pathname(d) ≠ SerializedElementArrays.pathname(d2)
  end

  @testset "SerializedElementArrays.SerializedElementArray" begin
    @test_throws MethodError SerializedElementArrays.SerializedElementArray()
    @test_throws MethodError SerializedElementArrays.SerializedElementArray{Float64}()

    # TODO: this also fails for Array, should we support it?
    @test_throws MethodError SerializedElementArrays.SerializedElementArray(undef, 2, 3, 4)
    d = SerializedElementArrays.SerializedElementArray{Any}(undef, 2, 3, 4)
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test !isfile(SerializedElementArrays.filename(d, n))
      @test !isassigned(d, n)
    end
    d[1] = 1
    @test isfile(SerializedElementArrays.filename(d, 1))
    @test d[1] == 1
    d[2] = 1.2
    @test isfile(SerializedElementArrays.filename(d, 2))
    @test d[2] == 1.2
    d[3] = "XXX"
    @test d[3] == "XXX"
    @test isfile(SerializedElementArrays.filename(d, 3))
    d[1, 2, 3] = "YYY"
    @test d[1, 2, 3] == "YYY"
    @test isfile(SerializedElementArrays.filename(d, 1, 2, 3))
    @test !isassigned(d, 4)
    @test_throws UndefRefError d[4]

    d = SerializedElementArrays.SerializedElementArray{Int}(undef, 2, 3, 4)
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test !isfile(SerializedElementArrays.filename(d, n))
      @test !isassigned(d, n)
    end
    d[1, 2, 3] = 1
    @test isfile(SerializedElementArrays.filename(d, 1, 2, 3))
    @test isassigned(d, 1, 2, 3)
    @test d[1, 2, 3] == 1
    @test_throws InexactError d[2, 2, 4] = 1.2

    d = SerializedElementArrays.SerializedElementArray(reshape(1:24, 2, 3, 4))
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
      @test d[n] isa Int64
    end

    d = SerializedElementArrays.SerializedElementArray{Float64}(reshape(1:24, 2, 3, 4))
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Float64
    @test startswith(SerializedElementArrays.pathname(d), tempdir())
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
      @test d[n] isa Float64
    end

    a = Array(d)
    @test a isa Array{Float64,3}
    @test length(a) == 24
    for n in 1:length(a)
      @test a[n] == n
    end

    a = Array{<:Any,3}(d)
    @test a isa Array{Float64,3}
    @test length(a) == 24
    for n in 1:length(a)
      @test a[n] == n
    end

    d2 = disk(a)
    @test d2 isa SerializedElementArrays.SerializedElementArray{Float64,3}
    @test size(d2) == (2, 3, 4)
    @test SerializedElementArrays.pathname(d) ≠ SerializedElementArrays.pathname(d2)
  end

  @testset "Composite element type" begin
    v = [randn(3, 4) for n in 1:2, m in 1:3]
    d = disk(v)
    @test size(d) == (2, 3)
    @test length(d) == (6)
    @test eltype(d) == Matrix{Float64}
    d11 = d[1, 1]
    @test size(d11) == (3, 4)
    @test d11 isa Matrix{Float64}
    d23 = d[end, end]
    @test size(d23) == (3, 4)
    @test d23 isa Matrix{Float64}
  end

  @testset "Undefined references" begin
    a = Array{Matrix{Float64}}(undef, 2, 3)
    d = disk(a)
    @test size(d) == (2, 3)
    @test !isassigned(a, 1, 2)
    @test !isassigned(d, 1, 2)
    @test isempty(readdir(SerializedElementArrays.pathname(d)))
    x = randn(5, 5)
    d[1, 2] = x
    @test x == d[1, 2]
    @test length(readdir(SerializedElementArrays.pathname(d))) == 1
    y = randn(3, 4)
    d[2, 3] = y
    @test y == d[2, 3]
    @test length(readdir(SerializedElementArrays.pathname(d))) == 2
  end

  if VERSION >= v"1.4"
    @testset "Custom paths" begin
      a = randn(3, 4)
      d = disk(a; path="my_tmp")
      @test size(d) == (3, 4)
      @test length(readdir(SerializedElementArrays.pathname(d))) == 12
      @test dirname(SerializedElementArrays.pathname(d)) == "my_tmp"
    end
  end

  @testset "disk(::SerializedElementArray)" begin
    a = randn(2, 3)
    d1 = disk(a)
    d2 = disk(a)
    @test SerializedElementArrays.pathname(d1) ≠ SerializedElementArrays.pathname(d2)
    d3 = disk(d2)
    @test SerializedElementArrays.pathname(d2) == SerializedElementArrays.pathname(d3)
  end

  @testset "disk(::Function)" begin
    n, m = 4, 5
    d1 = disk(n, m) do n, m
      [i + j for i in 1:n, j in 1:m]
    end
    d2 = disk(n, m; full=true) do n, m
      [i + j for i in 1:n, j in 1:m]
    end
    d3 = disk(n, m; force_gc=false) do n, m
      [i + j for i in 1:n, j in 1:m]
    end
    @test d1[1, 2] == 1 + 2
    @test d2[1, 2] == 1 + 2
    @test d3[1, 2] == 1 + 2
  end
end
