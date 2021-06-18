"""
    GraphVertex

Store the drawing function and properties individual to the node.

# Examples
```julia
function draw(;position, radius)
    circle(position, radius, :stroke)
    return position
end

g = [Dict(:weight=>2, :neighbors=>[2])
     Dict(:weight=>4, :neighbors=>[1])]
ga = Object(1:100, Graph(g, true, 100, 100), O)

node1 = Object(1:50, GraphVertex(ga, 1, draw; animate_on=:scale, property_style_map=Dict(:weight=>:radius)))
node2 = Object(50:100, GraphVertex(ga, 2, draw; animate_on=:scale, property_style_map=Dict(:weight=>:radius)))
render(video; pathname="graph_node.gif")
```
"""
struct GraphVertex
    node::Int
    draw::Function
    animate_on::Symbol
    property_style_map::Dict{Any,Symbol}
end

"""
    GraphVertex(graph::AbstractObject, node::Int, draw::Function; <keyword arguments>)

Create a graph node, specifying a drawing function or a property style map or both.

# Arguments
- `graph::AbstractObject`: The graph created using [`GraphAnimation`](@ref) to which this node should be added to.
- `node::Int`: A unique id representing the node being added to the graph.
    - Currently, only numeric node ids are supported.
- `draw::Function`: The drawing function used to draw the node.
    - Implementing the drawing function in a special way to expose the drawing parameters helps in better animation.

# Keywords
- `animate_on::Symbol`: Control the animation effect on the nodes using pre-defined drawing parameters. Default is `:opacity`.
    - For nodes, it can be 
        - `:opacity`
        - `:scale`
    - For known graph types, it can additionally be 
        - `:fill_color`
        - `:border_color`
        - `:radius`
- `property_style_map::Dict{Any,Symbol}`: A mapping to of how node attributes map to node drawing styles.
"""
function GraphVertex(
    graph::AbstractObject,
    node::Int,
    draw::Function;
    animate_on::Symbol = :opacity,
    property_style_map::Dict{Any,Symbol} = Dict(),
)
    # Register new node with Graph Animation metadata
    # IF mode is static simply call the draw function and return
    # ELSE recalculate the network layout based on the current graph structure
    #      and update the positions of nodes through easing translations
end
