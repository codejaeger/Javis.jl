## Breadth First Search

### Points to cover
1. Graph animation creation
2. Algorithm explanation through two visualisations
3. Miscellaneaous

### Graph Creation

The graph object can be created/initialized by the use of a LightGraph typed object or any arbitrary graph types. In the latter case, there is a need to specify some additional accessibility functions to make use of advanced visualisation features. This example covers how to do it with the use of a simple adacency list. It is supposed to be the most simplest way one can use the API with almost a zero learning curve.

**Graph representation**
```julia
graph = [[2, 3, 4, 5],
         [6, 7],
         [8],
         [],
         [],
         [],
         [],
         []]
```
\
**Graph initialization**
```julia
# Parameters - Graph object | is directed? | width | height | starting position
ga = GraphAnimation(graph, true, 300, 300, O)

nodes = [Object(@Frames(prev_start()+5, GraphNode(1, (args...) -> drawNode(), animate_on=:scale; fill_color="yellow", border_color="black", text=string(i), text_valign=:middle, text_halign=:center)) for i in range(1, 8; step=1)]

# Need to find a way to map drawing arguments like text_align (specified before) over here
function drawNode(fill_color, border_color, text, text_valign, text_halign)
    sethue(fill_color)
    circle(O, 5, :fill)
    sethue(border_color)
    circle(O, 5, :stroke)
    text(text, O, valign = text_valign, halign = text_halign)
end
```
The set of drawing options that will be supported depends solely on the user and the drawing function. The functions like `highlightNode` take input one of these drawing parameters and a new value and perform highlighting operations on them.

In a later example, I will demostrate how to map these drawing options to node properties which are part of of the input graph. That will help to animate changes in node properties simultaneously without any additional coding.

The additional option `animate_on` controls the appearance of the node on the canvas. The same option is used during removal of nodes/edges.

The options available are:
* color - both nodes and edges
* opacity - both nodes and edges
* scale - only for nodes
* line_width - only for edges
* length - only for edges

The result is eight balls drawn on the canvas at fixed locations unaltered by changes in the graph by addition/deletion of new nodes.

### Graph visualisation

The algorithm can be explained in two ways:

**Using simple coloring**
* Use a different fill color to convey the nodes in the queue
```julia
# vis[x] indicates if a node is visited and Q is a queue data structure
Q.push(1)
# Is the frames keyword necessary here? If nothing is specified use the frames macro to start 5 frames later
changeNodeProperty(ga, 1, :fill_color, "green")
while !Q.empty()
    i=Q.pop()
    vis[i]=true
    changeNodeProperty(ga, i, :fill_color, "orange")
    for j in neighbours(i)
        if !vis[j]
            Q.push(j)
            changeNodeProperty(ga, 1, :fill_color, "orange")
        end
    end
end
```

**Using node color or border color highlighting**
* Use a different fill or border color to convey the current highlighted node
* Change the color of visited nodes permanently

```julia
# vis[x] indicates if a node is visited and Q is a queue data structure
highlightNode(ga, 1, :fill_color, "white") # Flicker between original yellow and white color for some frames
vis[1]=true
changeNodeProperty(ga, 1, :fill_color, "orange")
Q.push(1)
while !Q.empty()
    i=Q.pop()
    for j in neighbours(i)
        if !vis[j]
            highlightNode(ga, j, :fill_color, "white")
            vis[j]=true
            changeNodeProperty(ga, j, :fill_color, "orange")
            Q.push(j)
        end
    end
end
```
