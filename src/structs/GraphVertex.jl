"""
    GraphVertex

Store the drawing function and properties individual to the node.

# Examples
```julia
function draw(;position, radius)
    circle(position, radius, :stroke)
    return position
end

g_props = [Dict(:weight=>2, :neighbors=>[2])
     Dict(:weight=>4, :neighbors=>[1])]
ga = @Object(1:100, Graph(true, 100, 100), O)

node1 = @Graph(ga, 1:50, GraphVertex(1, [draw_shape(:square, 12), draw_text(:inside, "123"), fill(:image, "./img.png"), custom_border()]; animate_on=:scale, property_style_map=Dict(:weight=>:radius)))
# each of these draw_* functions return functionsn with specified change keywords like radius, border_color etc.
# expose as many of these props as supported by Luxor drawing
node2 = @Graph(ga, 50:100, GraphVertex(2, draw; animate_on=:scale, property_style_map=Dict(:weight=>:radius)))
render(video; pathname="graph_node.gif")
```
"""
struct GraphVertex
    node::Int
    animate_on::Symbol
    property_style_map::Dict{Any,Symbol}
    opts::Dict{Symbol, Any}
end

"""
    GraphVertex(node::Int, draw::Function; <keyword arguments>)
    GraphVertex(graph::AbstractObject, node::Int, draw::Function; <keyword arguments>)
    GraphVertex(graph::AbstractObject, node::Int, draw::Vector{Function}; <keyword arguments>)

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
GraphVertex(node::Int, draw::Union{Vector{Function}, Function}; kwargs...) =
    GraphVertex(CURRENT_GRAPH[1], node, draw; kwargs...)

GraphVertex(graph::AbstractObject, node::Int, draw::Vector{Function}; kwargs...) =
    GraphVertex(graph, node, compile_draw_funcs(draw); kwargs...)

function GraphVertex(
    graph::AbstractObject,
    node::Int,
    draw::Function;
    animate_on::Symbol = :opacity,
    property_style_map::Dict{Any,Symbol} = Dict{Any,Symbol}(),
)
    g = graph.meta
    if !(typeof(g) <: JGraph)
        throw(ErrorException("Cannot define node since $(typeof(graph)) is not a `JGraph`"))
    end
    if g.mode == :static
        if get_prop(g.adjacency_list, node) !== nothing
            @warn "Node $(node) is already created on canvas. Recreating it will leave orphan node objects in the animation. To undo, call `rem_node!`"
        end
        if g.layout != :none
            draw_fn = (args...; position=O, kwargs...) -> begin Luxor.translate(position); draw(args...; position=position, kwargs...) end
        else
            draw_fn = draw
        end
        add_vertex!(g.adjacency_list.graph)
        set_prop!(g.adjacency_list, nv(g.adjacency_list), length(g.ordering)+1)
        graph_vertex = GraphVertex(node, animate_on, property_style_map, Dict{Symbol, Any}())
        return draw_fn, graph_vertex
    elseif g.mode == :dynamic
    end
end

"""
    compile_draw_funcs(fn_list::Vector{Function})

Aggregate all the draw functions into one. Not yet implemented.
"""
function compile_draw_funcs(draw)::Function
    # Figure out how to map specific change keywords to each drawing functions
    change_keywords = Dict{Symbol, Any}()
    # Process drawing functions
    combined_draw = (args...) -> begin for d in draw d(args...) end end
    return combined_draw
end