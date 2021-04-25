struct GraphAnimation
    graph::AbstractGraph
    ordering::SimpleDiGraph
    animated_graph::MetaGraph
    mode::Symbol
    frames::Int
end

const CURRENT_GRAPH = Array{GraphAnimation,1}()

function GraphAnimation(graph::AbstractGraph, mode::Symbol)
    animated_graph = MetaGraph(graph)
    ordering = SimpleDiGraph(nv(graph))
    if mode != :incremental
        ordering = bfs_tree(graph)
    end
    return GraphAnimation(graph, ordering, animated_graph, mode, 0)
end
