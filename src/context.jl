"""
`DispatchContext` holds the computation graph and arbitrary key-value pairs of
metadata.
"""
type DispatchContext
    graph::DispatchGraph
    meta::Dict{Any, Any}
end

Base.copy(ctx::DispatchContext) = DispatchContext(ctx.graph, ctx.meta)

"""
Creates an empty `DispatchContext` with keyword arguments stored in metadata.
"""
function DispatchContext(; kwargs...)
    ctx = DispatchContext(DispatchGraph(), Dict{Any, Any}())
    for (k, v) in kwargs
        ctx.meta[k] = v
    end

    return ctx
end

Base.getindex(ctx::DispatchContext, key) = ctx.meta[key]
Base.setindex!(ctx::DispatchContext, value, key) = ctx.meta[key] = value

"""
Adds a `DispatchNode` to the `DispatchContext`'s graph and records
dependencies.

Returns the `DispatchNode` which was added.
"""
function add!(ctx::DispatchContext, node::DispatchNode)
    push!(ctx.graph, node)

    deps = dependencies(node)

    for dep in deps
        # `IndexNode`s are not automatically stored in the context
        if isa(dep, IndexNode)
            add!(ctx, dep)
        end

        add_edge!(ctx.graph, dep, node)
    end

    return node
end
