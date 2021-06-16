"""
    GraphEdge

# Examples
```julia
function draw(opts)
    circle(opts['position'], opts['radius'] :stroke)
    return opts['position']
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
    draw::Function
    animate_on::Symbol
    property_style_map::Dict{Any,Symbol}
end

"""
    GraphEdge(graph::AbstractObject, from_node::Int, to_node::Int, draw::Function; <keyword arguments>, kwargs...)

Create a graph edge with additional drawing function and options.

# Arguments
- `graph::AbstractObject`: The graph created using [`GraphAnimation`](@ref) to which this node should be added to.
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
- `kwargs`: Additional drawing arguments used in the drawing function `draw`.
    - These are translated to be stored in the the `opts` field in [`GraphEdge`](@ref)
"""
function GraphEdge(
    graph::AbstractObject,
    from_node::Int,
    to_node::Int,
    draw::Function;
    animate_on::Symbol = :opacity,
    property_style_map::Dict{Any,Symbol} = Dict(),
    kwargs...,
) end
