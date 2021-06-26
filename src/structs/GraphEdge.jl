"""
    GraphEdge

# Examples
```julia
function draw(;position_1, position_2, line_width=5)
    setline(line_width)
    line(position_1, position_2, action=:stroke)
    return O
end
function e(g, node1, node2, attr)
    return g[node1][node2]
end

# g mimics an adjacency list with edge weights
g = [Dict(2=>5),
     Dict(1=>3)]
ga = GraphAnimation(g, true, 100, 100, O; get_edge_attribute=e)
node1 = Object(1:30, GraphNode(ga, 1; animate_on=:scale))
node2 = Object(10:40, GraphNode(ga, 2; animate_on=:scale))
edge = Object(30:60, GraphEdge(ga, 1, 2, draw; animate_on=:scale, property_style_map=Dict(""=>:line_width)))
render(video; pathname="graph_node.gif")
```
"""
struct GraphEdge
    from_node::Int
    to_node::Int
    animate_on::Symbol
    property_style_map::Dict{Any,Symbol}
    opts::Dict{Symbol, Any}
end

"""
    GraphEdge(graph::AbstractObject, from_node::Int, to_node::Int, draw::Function; <keyword arguments>)

Create a graph edge with additional drawing function and options.

# Arguments
- `graph::AbstractObject`: The graph created using [`Graph`](@ref) to which this edge should be added to.
- `from_node::Int`
- `to_node::Int`
- `draw::Function`: The drawing function used to draw the edge.
    - Implementing the drawing function in a special way to expose the drawing parameters helps in better animation.

# Keywords
- `animate_on::Symbol`: Control the animation effect on the edges using pre-defined drawing parameters
    - For edges, it can be 
        - `:opacity`
        - `:line_width`
        - `:length`
    - For known graph types, it can additionally be 
        - `:color`
        - `:weights`: only possible for weighted graphs i.e. `SimpleWeightedGraphs`.
- `properties_to_style_map::Dict{Any,Symbol}`: A mapping to of how edge attributes map to edge drawing styles.
"""
GraphEdge(from_node::Int, to_node::Int, draw::Union{Vector{Function}, Function}; kwargs...) =
    GraphEdge(CURRENT_GRAPH[1], from_node, to_node, draw; kwargs...)

GraphEdge(graph::AbstractObject, from_node::Int, to_node::Int, draw::Vector{Function}; kwargs...) =
    GraphEdge(graph, from_node, to_node, compile_draw_funcs(draw); kwargs...)

function GraphEdge(
    graph::AbstractObject,
    from_node::Int,
    to_node::Int,
    draw::Function;
    animate_on::Symbol = :opacity,
    property_style_map::Dict{Any,Symbol} = Dict{Any,Symbol}(),
)
    g = graph.meta
    if !(typeof(g) <: JGraph)
        throw(ErrorException("Cannot define edge since $(typeof(graph)) is not a `JGraph`"))
    end
    if get_prop(g.adjacency_list, from_node, to_node) !== nothing
        @warn "Edge $(from_node)=>$(to_node) is already created on canvas. Recreating it will leave orphan edges in the animation. To undo, call `rem_edge!`"
    end
    add_edge!(g.adjacency_list.graph, from_node, to_node)
    set_prop!(g.adjacency_list, from_node, to_node, length(g.ordering)+1)
    graph_edge = GraphEdge(from_node, to_node, animate_on, property_style_map, Dict{Symbol, Any}())
    return draw, graph_edge
end
