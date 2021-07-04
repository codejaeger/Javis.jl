```julia
using Javis, LaTeXStrings

function edge(; p1, p2, kwargs...)
    sethue("black")
    line(p1, p2, :stroke)
end

function node(p=O, color="black")
    sethue(color)
    circle(p, 10, :fill)
    return p
end

function ground(args...) 
    background("white")
    sethue("black")
end

video = Video(400, 400)
Background(1:150, ground)

g = @Object 1:150 JGraph(true, 100, 100) O

adjacency_list = [[2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]
for i in 1:length(adjacency_list)
    if i%2 == 0
        @Graph g i*10:150 GraphVertex(i, [node_shape(:circle, true, radius=12), node_fill(:image, "football.png"), node_text("$(i)", :top)]) O
    else
        @Graph g i*10:150 GraphVertex(i, [node_shape(:rectangle, true, width=20, height=20), node_fill(:color, "yellow"), node_text(L"""%$i""", :inside), node_border("green", 2)]) O
    end
end
count = 0
for i in 1:length(adjacency_list)
    for j in adjacency_list[i]
        @Graph g 15+count*10:150 GraphEdge(i, j, (args...; kwargs...)->edge(; kwargs...)) O
        count+=1
    end
end

render(video; pathname="demo.gif")
```

![Demo](demo.gif)