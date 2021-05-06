using SerializedElementArrays
using Test

@testset "SerializedElementArrays.jl" begin
  @testset "DiskVector" begin
    d = DiskVector()
    @test size(d) == (0,)
    @test length(d) == 0
    @test ndims(d) == 1
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
    @test ispath(SerializedElementArrays.pathname(d))
    @test !isfile(SerializedElementArrays.filename(d, 1))

    d = DiskVector(undef, 4)
    @test size(d) == (4,)
    @test length(d) == 4
    @test ndims(d) == 1
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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

    d = DiskVector{Int}(undef, 4)
    @test size(d) == (4,)
    @test length(d) == 4
    @test ndims(d) == 1
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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

    d = DiskVector(1:6)
    @test size(d) == (6,)
    @test length(d) == 6
    @test ndims(d) == 1
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
    end

    d = DiskVector{Float64}(1:6)
    @test size(d) == (6,)
    @test length(d) == 6
    @test ndims(d) == 1
    @test eltype(d) == Float64
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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
    @test d2 isa DiskVector{ComplexF64}
    @test size(d2) == (6,)
    @test SerializedElementArrays.pathname(d) ≠ SerializedElementArrays.pathname(d2)
  end

  @testset "DiskMatrix" begin
    d = DiskMatrix()
    @test size(d) == (0, 0)
    @test length(d) == 0
    @test ndims(d) == 2
    @test eltype(d) == Any

    d = DiskMatrix(undef, 4, 5)
    @test size(d) == (4, 5)
    @test length(d) == 20
    @test ndims(d) == 2
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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

    d = DiskMatrix{Int}(undef, 4, 5)
    @test size(d) == (4, 5)
    @test length(d) == 20
    @test ndims(d) == 2
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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

    d = DiskMatrix(reshape(1:6, 2, 3))
    @test size(d) == (2, 3)
    @test length(d) == 6
    @test ndims(d) == 2
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
      @test d[n] isa Int64
    end

    d = DiskMatrix{Float64}(reshape(1:6, 2, 3))
    @test size(d) == (2, 3)
    @test length(d) == 6
    @test ndims(d) == 2
    @test eltype(d) == Float64
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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
    @test d2 isa DiskMatrix{Float64}
    @test size(d2) == (2, 3)
    @test SerializedElementArrays.pathname(d) ≠ SerializedElementArrays.pathname(d2)
  end

  @testset "DiskArray" begin
    @test_throws MethodError DiskArray()
    @test_throws MethodError DiskArray{Float64}()

    # TODO: this also fails for Array, should we support it?
    @test_throws MethodError DiskArray(undef, 2, 3, 4)
    d = DiskArray{Any}(undef, 2, 3, 4)
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Any
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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

    d = DiskArray{Int}(undef, 2, 3, 4)
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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

    d = DiskArray(reshape(1:24, 2, 3, 4))
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Int
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
    @test ispath(SerializedElementArrays.pathname(d))
    for n in 1:length(d)
      @test isfile(SerializedElementArrays.filename(d, n))
      @test isassigned(d, n)
      @test d[n] == n
      @test d[n] isa Int64
    end

    d = DiskArray{Float64}(reshape(1:24, 2, 3, 4))
    @test size(d) == (2, 3, 4)
    @test length(d) == 24
    @test ndims(d) == 3
    @test eltype(d) == Float64
    @test startswith(SerializedElementArrays.pathname(d), ".tmp/jl_")
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
    @test d2 isa DiskArray{Float64, 3}
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
end
