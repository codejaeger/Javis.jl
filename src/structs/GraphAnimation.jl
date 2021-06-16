"""
    GraphAnimation

Maintain the graph state comprising of nodes, edges, layout, animation ordering etc.

This will be a part of the Javis [`Object`](@ref) metadata, when a new graph is created.

# Fields
- `graph`: A data structure storing information about nodes, edges, properties, etc.
    - Using a known graph type from the [LightGraphs.jl]() package leads to certain simplicity in usage.
- `width::Int`: The width of the graph on the canvas.
- `height::Int`: The height of the graph on the canvas.
- `mode::Symbol`: The animaition of the graph can be done in two ways.
    - `static`: A lightweight animation which does not try to animate every detail during adding and deletion of nodes.
    - `dynamic`: The graph layout change is animated on addition of a new node. Can be computationally heavy depending on the size of graph.
- `layout::Symbol`: The graph layout to be used. Can be one of :-
    - `:spring`: Emphasizes on spacing nodes and edges as far apart as possible.
    - `:radial`: Generates the best radial visualization for the graph.
- `get_node_attribute`: A function that enables fetching properties defined for nodes in the input graph data structure.
    - Required only when a node property like `cost` needs to be mapped to a drawing property like `radius`.
- `get_edge_attribute`: Similar to `get_node_attribute` but for edge properties.
- `adjacency_list`: A light internal representation of the graph structure initialized only when the graph data type is not known.
    - For undirected graphs it is of type `SimpleGraph` from [LightGraphs.jl]() and for directed graphs it is `SimpleDiGraph`
- `ordering`: Store the relative ordering used to add nodes and edges to a graph using [`GraphNode`](@ref) and [`GraphEdge`](@ref)
    - If input graph is of a known type, defaults to a simple BFS ordering starting at the root node.
- `node_property_limits`: The minima and maxima calculated on the node properties in the input graph.
    - This is internally created and updated when [`updateGraph`](@ref) or the final render function is called.
    - This is skipped for node properties of non-numeric types.
    - Used to scale drawing property values within sensible limits.
- `edge_property_limits`: The minima and maxima calculated on the edge properties in the input graph.
    - Similar to `node_attribute_fn`.
"""
struct GraphAnimation
    graph
    width::Int
    height::Int
    mode::Symbol
    layout::Symbol
    get_node_attribute::Function
    get_edge_attribute::Function
    adjacency_list::LightGraphs.AbstractGraph
    ordering::Vector{AbstractObject}
    edge_property_limits::Dict{Symbol,Tuple{Real,Real}}
    node_property_limits::Dict{Symbol,Tuple{Real,Real}}
end

"""
    GraphAnimation(directed::Bool, width::Int, height::Int, [start_pos])

Create an empty graph on the canvas with no nodes or edges yet.
"""
GraphAnimation(
    directed::Bool,
    width::Int,
    height::Int,
    start_pos::Union{Point,Object} = O,
) = GraphAnimation(nothing, directed, width, height, start_pos)

"""
    GraphAnimation(graph, directed::Bool, width::Int, height::Int, start_pos::Union{Point,Object}; <keyword arguments>)

Creates a Javis object for the graph and assigns its `Metadata` field to the object created by this struct.

# Arguments
- `graph`: A data structure of any type storing the input graph.
- `directed::Bool`: `true` or `false`
- `width::Int`: Size of the graph along the horizontal direction.
- `height::Int`: Size of the graph along the vertical direction.
- `start_pos::Union{Point,Object}`: Center of the graph relative to the canvas.

# Keywords
- `mode`: `:static` or `:dynamic`. Default is `:static`.
- `layout`: `:spring` or `:radial`. Default is `:spring`.
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
ga = GraphAnimation(graph, false, 100, 100, O)
render(video; pathname="graph_animation.gif")
```

# Implementation
To be filled in ...

"""
function GraphAnimation(
    graph,
    directed::Bool,
    width::Int,
    height::Int,
    start_pos::Union{Point,Object} = O;
    mode::Symbol = :static,
    layout::Symbol = :spring,
    get_node_attribute::Function = (args...) -> nothing,
    get_edge_attribute::Function = (args...) -> nothing,
)
    adjacency_list = directed ? LightGraphs.SimpleDiGraph() : LightGraphs.SimpleGraph()
    
    # Check available layouts
    if !(layout in [:spring, :radial])
        layout = :static
        @warn "Unknown layout '$(layout)'. Defaulting to static layout"
    end

    graph_animation = GraphAnimation(
        graph,
        width,
        height,
        mode,
        layout,
        get_node_attribute,
        get_edge_attribute,
        adjacency_list,
        Vector{AbstractObject}(),
        Dict{Symbol,Tuple{Real,Real}}(),
        Dict{Symbol,Tuple{Real,Real}}()
    )
    if mode == :static
        update_fn = (args...) -> begin
            _calculate_property_limits(args)
            _calculate_layout(args)
        end
    elseif mode == :dynamic
        update_fn = (args...) -> begin
            _calculate_property_limits(args)
        end
    end
    # Create Javis object

end
