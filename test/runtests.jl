using Dispatcher
using Base.Test

@testset "Example" begin
    ctx = DispatchContext()
    exec = AsyncExecutor()

    op = Op(()->3)
    @test isempty(dependencies(op))
    a = push!(ctx, op)

    op = Op((x)->x, 4)
    @test isempty(dependencies(op))
    b = push!(ctx, op)

    op = Op(max, a, b)
    deps = dependencies(op)
    @test a in deps
    @test b in deps
    c = push!(ctx, op)

    op = Op(sqrt, c)
    @test c in dependencies(op)
    d = push!(ctx, op)

    op = Op((x)->(rand(Int, x), rand(UInt, x)), c)
    @test c in dependencies(op)
    e, f = push!(ctx, op)

    op = Op((x)->mean(x), f)
    @test f in dependencies(op)
    g = push!(ctx, op)

    run(exec, ctx)
end