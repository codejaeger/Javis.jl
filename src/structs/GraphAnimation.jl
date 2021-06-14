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
    - `static`: A lightweight animation which does not try to animate every detail during transitions unless asked to.
    - `dynamic`: Animates almost every single change made to the state of the graph. Can be computationally heavy depending on the use case.
- `layout::Symbol`: The graph layout to be used. Can be one of :-
    - `:spring`: Emphasizes on spacing nodes and edges as far apart as possible.
    - `:radial`: Generates the best radial visualization for the graph.
- `get_node_attribute`: A function that enables fetching properties defined for nodes in the input graph data structure.
    - Required only when a node property like `cost` needs to be mapped to a drawing property like `radius`.
- `get_edge_attribute`: Similar to `get_node_attribute` but for edge properties.
- `adjacency_list`: A light internal representation of the graph structure initialized only when the graph data type in not known.
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
    start_pos::Union{Point,Object}
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
) =
    directed ?
    GraphAnimation(LightGraphs.SimpleDiGraph(), directed, width, height, start_pos) :
    GraphAnimation(LightGraphs.SimpleGraph(), directed, width, height, start_pos)

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
    # if mode == :static
    #     # Invoke the graph layout generation algorithm here
    #     # That is when the entire graph is already created
    #     # After that change the start positions of nodes using the info from ordering list
    # end
    # for j in CURRENT_GRAPH[1].ordering
    #     # Get object type from some object specific field like metadata
    #     if j.metadata.type == :graph_node
    #         for style in keys(get(j.metadata, weight_style_map, Dict()))
    #             if style in keys(CURRENT_GRAPH[1].node_weight_limits)
    #                 # Update the limits for this style property on node
    #             end
    #         end
    #     elseif j.metadata.type == :graph_node
    #         # Do the same computation for edge styles
    #     end
    # end
    # # Now update the node and edge object drawing parameters like scale, opacity, 
    # # layout weights etc.
end
