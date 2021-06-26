"""
    JGraph

Maintain the graph state comprising of nodes, edges, layout, animation ordering etc.

This will be a part of the Javis [`Object`](@ref) metadata, when a new graph is created.

# Fields
- `adjacency_list`: A light internal representation of the graph structure. Can be initialized with a known graph type.
    - For undirected graphs the underlying graph type used is `SimpleGraph` from [LightGraphs.jl]() and for directed graphs it is `SimpleDiGraph`.
- `width::Int`: The width of the graph on the canvas.
- `height::Int`: The height of the graph on the canvas.
- `mode::Symbol`: The animation of the graph can be done in two ways.
    - `static`: A lightweight animation which does not try to animate every detail during adding and deletion of nodes.
    - `dynamic`: The graph layout change is animated on addition of a new node. Can be computationally heavy depending on the size of graph.
- `layout::Symbol`: The graph layout to be used. Can be one of :-
    - `:none`
    - `:spring`
    - `:spectral`
- `get_node_attribute`: A function that enables fetching properties defined for nodes in the input graph data structure.
    - Required only when a node property like `cost` needs to be mapped to a drawing property like `radius`.
- `get_edge_attribute`: Similar to `get_node_attribute` but for edge properties.
- `ordering`: Store the relative ordering used to add nodes and edges to a graph using [`GraphNode`](@ref) and [`GraphEdge`](@ref)
    - If input graph is of a known type, defaults to a simple BFS ordering starting at the root node.
- `node_property_limits`: The minima and maxima calculated on the node properties in the input graph.
    - This is internally created and updated when [`updateGraph`](@ref) or the final render function is called.
    - This is skipped for node properties of non-numeric types.
    - Used to scale drawing property values within sensible limits.
- `edge_property_limits`: The minima and maxima calculated on the edge properties in the input graph.
    - Similar to `node_attribute_fn`.
"""
struct JGraph
    adjacency_list::WeightedGraph
    width::Int
    height::Int
    mode::Symbol
    layout::Symbol
    get_node_attribute::Function
    get_edge_attribute::Function
    ordering::Vector{AbstractObject}
    edge_property_limits::Dict{Symbol,Tuple{Real,Real}}
    node_property_limits::Dict{Symbol,Tuple{Real,Real}}
end

CURRENT_GRAPH = Array{AbstractObject, 1}()

"""
    JGraph(directed::Bool, width::Int, height::Int)

Create an empty graph on the canvas.
"""
JGraph(directed::Bool, width::Int, height::Int) =
    directed ? JGraph(WeightedGraph(LightGraphs.SimpleDiGraph()), width, height) :
    JGraph(WeightedGraph(LightGraphs.SimpleGraph()), width, height)

"""
    JGraph(graph, width::Int, height::Int; <keyword arguments>)

Creates a Javis object for the graph and assigns its `Metadata` field to the object created by this struct.

# Arguments
- `graph`: A known data structure storing information about nodes, edges, properties, etc.
    - Graph types of type `AbstractGraph` from the [LightGraphs.jl]() package are supported.
    - Using this eliminates the requirement to create nodes and edges separately.
- `width::Int`: Size of the graph along the horizontal direction.
- `height::Int`: Size of the graph along the vertical direction.

# Keywords
- `mode`: `:static` or `:dynamic`. Default is `:static`.
- `layout`: `:none`, `:spring` or `:spectral`. Default is `:spring`.
- `get_node_attribute::Function`: A `Function` with a signature `(graph, node::Int, attr::Any)::Any`
    - `graph` is the object containing node properties
    - Returns a value corresponding to the type of the node property `attr`.
        - Must be either a Julia primitive type or `String`.
- `get_edge_attribute::Function`: A `Function` with a signature `(graph, from_node::Int, to_node::Int, attr::Any)::Any`
    - Similar to `get_node_attribute`.

# Examples
```julia
using Javis
function ground()
    background("white")
    sethue("black")
end

video = Video(300, 300)
Background(1:100, ground)
# A star graph
graph = [[2, 3, 4, 5, 6], [], [], [], [], []]
ga = @Object(1:100, JGraph(false, 100, 100), O)
render(video; pathname="graph_animation.gif")
```

# Implementation
To be filled in ...

"""
function JGraph(
    graph,
    width::Int,
    height::Int;
    mode::Symbol = :static,
    layout::Symbol = :spring,
    get_node_attribute::Function = (args...) -> nothing,
    get_edge_attribute::Function = (args...) -> nothing,
)
    # Check available layouts
    if !(layout in [:none, :spring, :spectral])
        layout = :spring
        @warn "Unknown layout '$(layout)'. Defaulting to static layout"
    end

    graph_animation = JGraph(
        graph,
        width,
        height,
        mode,
        layout,
        get_node_attribute,
        get_edge_attribute,
        Vector{AbstractObject}(),
        Dict{Symbol,Tuple{Real,Real}}(),
        Dict{Symbol,Tuple{Real,Real}}(),
    )
    if mode == :static
        return ((args...) -> begin
            _global_property_limits(args...)
            _global_layout(args...)
        end, graph_animation)
    elseif mode == :dynamic
        return ((args...) -> _global_property_limits(args...), graph_animation)
    end
end

function _global_property_limits(video, object, frames; kwargs...)
    g = object.meta
    for obj in g.ordering
        if typeof(obj.meta) == GraphVertex
            for (k, _) in obj.meta.property_style_map
                val = g.get_node_attribute(k)
                if typeof(val) == Real
                    if !(k in keys(g.node_property_limits))
                        g.node_property_limits[k] = (val, val)
                    end
                    g.node_property_limits[k] = (
                        min(g.node_property_limits[k][1], val),
                        max(g.node_property_limits[k][2], val),
                    )
                end
            end
        elseif typeof(obj.meta) == GraphEdge
            for (k, _) in obj.meta.property_style_map
                val = g.get_edge_attribute(k)
                if typeof(val) == Real
                    if !(k in keys(g.edge_property_limits))
                        g.edge_property_limits[k] = (val, val)
                    end
                    g.edge_property_limits[k] = (
                        min(g.edge_property_limits[k][1], val),
                        max(g.edge_property_limits[k][2], val),
                    )
                end
            end
        end
    end
end

function _global_layout(video, object, frame; kwargs...)
    g = object.meta
    if frame == first(get_frames(object))
        layout_x = []
        layout_y = []
        if g.layout == :none
            return
        elseif g.layout == :spring
            # Check due to some errors in calling spring_layout with an empty graph
            if nv(g.adjacency_list.graph) > 0
                layout_x, layout_y = spring_layout(g.adjacency_list.graph)
            end
        elseif g.layout == :spectral
            # Check special property layout_weight is defined on edges and collect weights
            edge_ordering_positions = edge_props(g.adjacency_list.graph)
            weights = map(
                (idx) -> get(g.ordering[idx].change_keywords, :layout_weight, 1),
                edge_ordering_positions,
            )
            if nv(g.adjacency_list.graph) > 0
                layout_x, layout_y = spectral_layout(g.adjacency_list, weights)
            end
        end
        # Normalize coordinates between -0.5 and 0.5
        coords = map((p) -> Point(p), collect(zip(layout_x, layout_y))) .- [(0.5, 0.5)]
        # Scale to graph dimensions
        coords = coords .* [(g.width, g.height)]
        object.opts[:layout] = coords
    end
    # Now assign positions back to all nodes
    for (idx, p) in enumerate(node_props(g.adjacency_list))
        g.ordering[p].meta.opts[:position] = object.opts[:layout][idx]
    end
    # Define keyword arguments for edges defining endpoint position
    for (_, p) in enumerate(edge_props(g.adjacency_list))
        from_node = get_prop(g.adjacency_list, g.ordering[p].meta.from_node)
        to_node = get_prop(g.adjacency_list, g.ordering[p].meta.to_node)
        g.ordering[p].meta.opts[:p1] = g.ordering[from_node].meta.opts[:position]
        g.ordering[p].meta.opts[:p2] = g.ordering[to_node].meta.opts[:position]
    end
end
