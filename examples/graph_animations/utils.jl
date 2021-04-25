function setlayout(layout_x::Vector{Float64}, layout_y::Vector{Float64})
    for i in 1:size(layout_x)[1]
        set_prop!(CURRENT_GRAPH[1].animated_graph, i, :position, Point(layout_x[i], layout_y[i]))
    end
end

function adjacency_list(edge_list::Any, nodes::Int)
    adjacency_list = [Any[] for i in range(1; length=nodes)]
    for i in edge_list
        push!(adjacency_list[i[1]], i[2])
    end
    return adjacency_list
end