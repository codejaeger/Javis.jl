"""
    GraphAnimation

Maintain information for the graph object to be drawn and animated on the canvas.

"""
struct GraphAnimation
    reference_graph
    width::Int
    height::Int
    mode::Symbol
    layout::Symbol
    start_pos::Union{Point, Object}
    node_attribute_fn::Function
    edge_attribute_fn::Function
    adjacency_list::AbstractGraph
    ordering::Vector{AbstractObject}
    edge_weight_limits::Dict{Symbol, Tuple{Real, Real}}
    node_weight_limits::Dict{Symbol, Tuple{Real, Real}}
end

GraphAnimation(reference_graph, directed::bool) = GraphAnimation(reference_graph, directed, 300, 300, O)
GraphAnimation(width::Int, height::Int, start_pos::Union{Point, Object}) = GraphAnimation(LightGraphs.SimpleGraph(), false, width::Int, height::Int, start_pos)

function GraphAnimation(
    reference_graph,
    directed::bool,
    width::Int,
    height::Int,
    start_pos::Union{Point, Object};
    mode::Symbol=:static,
    layout::Symbol=:spring,
    get_node_attribute::Function=(args...)->nothing,
    get_edge_attribute::Function=(args...)->nothing
)
    
end

function _graph_animation_object(mode)
    if mode==:static
        # Invoke the graph layout generation algorithm here
        # That is when the entire graph is already created
        # After that change the start positions of nodes using the info from ordering list
    end
    for j in CURRENT_GRAPH[1].ordering
        # Get object type from some object specific field like metadata
        if j.metadata.type==:graph_node
            for style in keys(get(j.metadata, weight_style_map, Dict()))
                if style in keys(CURRENT_GRAPH[1].node_weight_limits)
                    # Update the limits for this style property on node
                end
            end
        else if j.metadata.type==:graph_node
            # Do the same computation for edge styles
        end
    end
    # Now update the node and edge object drawing parameters like scale, opacity, 
    # layout weights etc.
end

struct GraphNode
    node_id
    properties_to_style_map::Dict{Any, Symbol}
    draw_fn::Function
end

# For nodes store drawing options as part of the Javis object itself
GraphNode(node_id) = GraphNode(node_id, Dict{Symbol, Symbol}())

function GraphNode(node_id, weight_style_map::Dict{Symbol, Symbol})
# Create a anonymous draw function based on the weight_style_map and additional drawing
# options and then call GraphNode(node_id, draw_function)
end

function GraphNode(node_id, draw::Function)
# Register new node with Graph Animation metadata
# IF mode is static simply call the draw function and return
# ELSE recalculate the network layout based on the current graph structure
#      and update the positions of nodes through easing translations
end

Object(1:1, GraphNode(2, Circle()))

struct GraphEdge
    from_node
    to_node
    properties_to_style_map::Dict{Any, Symbol}
    draw_fn::Function
end

function GraphEdge()

end


## Will use light graph functionality
function animate_node!()
end

function animate_edge!()
end

function remove_node!()
end

function remove_edge!()
end
