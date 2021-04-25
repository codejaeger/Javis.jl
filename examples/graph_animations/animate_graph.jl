using Javis
using LightGraphs
using GraphPlot
using NetworkLayout:Buchheim
using SparseArrays
using MetaGraphs

include("GraphAnimation.jl")
include("utils.jl")

function animate_graph(graph::AbstractGraph, layout::Symbol, mode::Symbol)
    if CURRENT_GRAPH[1].graph != graph
        ga = GraphAnimation(graph, mode)
        push!(CURRENT_GRAPH, ga)
    else
        mode = :rearrange
    end
    w = CURRENT_VIDEO[1].width
    h = CURRENT_VIDEO[1].height
    if layout == :spring
        lx, ly = spring_layout(graph).*(w, h)
    elseif layout == :tree
        a, b, _ = findnz(adjacency_matrix(graph))
        adj = adjacency_list(zip(a, b))
        pts = Buchheim.layout(adj).*(w, h)
        lx = [i[1] for i in pts]
        ly = [i[2] for i in pts]
    end
    setlayout(lx, ly)
    if mode == :rearrange
        # Add easing between 2 network graph arrangements
        g = CURRENT_GRAPH[1]
        startframe = g.frames
        root=1
        function f(root)
            translate_anim = rotate_anim = Animation(
                [0, 1],
                [0, Point(lx[root], ly[root])],
                [sineio()],
            )
            act!(get_prop(g.animated_graph, root, :object), Action(Rframes(startframe:startframe+10), translate_anim, translate()))
            for i in neighbors(g.ordering, root)
                act!(get_prop(g.animated_graph, Edge(root, i), :object), Action(Rframes(startframe:startframe+2), disappear(:fade)))
                f(i)
                act!(get_prop(g.animated_graph, Edge(root, i), :object), Action(Rframes(startframe+10:startframe+12), appear(:fade)))
            end
        end
    elseif mode == :whole
        # Default graph animation
        ordering = ga.ordering
        function default_animation(root)
            animate_node(ga.animated_graph, root)
            for i in neighbors(ordering, root)
                animate_edge(root, i)
                default_animation(i)
            end
        end
        default_animation(1)
    elseif mode == :incremental
        # Do nothing for incremental
    elseif mode == :dynamic
        # Dynamically create graph using NetworkLayout's Layout iterator
        # https://github.com/JuliaGraphs/NetworkLayout.jl#iterator 
    end
end

function draw_node(pos)
    sethue("white")
    circle(pos, 25, :fill)
end

function animate_node(node_id::Int)
    node = Object(Rframes(1:1000), (args...)->draw_node(O), get_prop(CURRENT_GRAPH[1].animated_graph, node_id, :position))
    act!(node, Action(1:5, appear(:fade)))
    set_prop(CURRENT_GRAPH[1].animated_graph, node_id, :object, node)
    add_edge!(CURRENT_GRAPH[1].ordering, )
    return node
end

function draw_edge(a, b)
    setdash("solid")
    line(a, b, :fill)
end

function animate_edge(from_node::Int, to_node::Int)
    g = CURRENT_GRAPH[1].animated_graph
    a = get_prop(g, from_node, :position)
    b = get_prop(g, to_node, :position)
    edge = Object((args...) -> draw_line(a, b))
    act!(edge, Action(1:5, appear(:fade)))
    set_prop!(CURRENT_GRAPH[1].animated_graph, Edge(from_node, to_node), :object, edge)
end
