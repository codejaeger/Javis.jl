## Graph Animation Demos

The demo serves to list the features that I am going to implement for graph animation using Javis. The example links at the end will take you to use cases that I think are worth considering before implementing the API.

### List of features

* Graph type invariance - The user should have the flexibility in terms of the type of the graph. The default graph type supported would be from LightGraphs.jl
* Add/Remove edges or nodes - Upon such changes the layout should change automatically to take into account the new arrangement
* Utilities to update the graph
    1. `addNode!` - add a node on the canvas
    2. `addEdge!` - add an edge on the canvas
    3. `changeNodeProperty!` - Update drawing style of node(s) on canvas
    4. `changeEdgeProperty!` - Update drawing style of edge(s) on canvas
    5. `updateGraph!` - Takes in the updated input graph object and updates the drawing properties of nodes and edges correspondingly
* Animation tools on graph
    1. `animate_inneighbors` - Incoming neighbors (for a directed graph)
    2. `animate_outneighbors` - Outgoing neighbors (for a directed graph)
    3. `animate_neighbors` - All neighbors
    4. `highlightNode` - Highlight node(s) using flicker animation of a node property
    5. `highlightEdge` - Highlight edge(s) using flicker animation of an edge property
    6. `animatePath` - Animate a path on the graph
    7. `bfs` - Animate bfs at a node
    8. `dfs` - Animate dfs at a node

### Examples

1. [Graph Traversal](example1.md)
2. [Depth First Search](example2.md)
2. [Shortest Path](example3.md)
3. [Cycle Detection]()
4. [Minimum Spanning Tree]()
5. [Bipartite Matching]()
6. [Strongly connected components]()
7. [Graph Coloring]()
8. [Gradient backpropagation]()

### Reference implementation till now

The struct definitions of `GraphAnimation`, `GraphNode` & `GraphEdge` are provided in [Graphs.jl](../../src/structs/Graphs.jl)

### Updates

#### 22 June
Completed:
* ~~A way to create graphs using `Object(1:100, JGraph(...)`~~
    * Solved temporarily using multiple dispatch on the object constructor and `@Object` macro that expands the tuple `(draw_func, metadata)` returned by `JGraph`. 
* ~~How to provide layout options to users.~~
    * Provide 2 layout options for now and keep a `none` mode so that user can specify his own layout.
* ~~How to access reference to node/edge objects from the parent graph.~~
    * Keep a lightweight adjacency list in the parent with nodes and edges having an attribute to store their position in the ordering list.

Working on:
* How to make a graph node customizable. Having predefined drawing functions like `drawNode(shape="circle", radius=12, text="node", text_align="top_left")` with lots of options does not seem extendible.
    * Use a plugin mechanism to let the user write their own drawing functions for certain node properties while reuse other default options.
* Add nodes to a graph object. The usual method of `Object(1:100, GraphNode(...))` has a problem of how to register a graph node object to a graph.
    * Using a macro syntax `@Graph g 1:100 GraphNode(...)` to register a created node object with the parent graph.

Approach(s) thought of (or used):
* To provide custom drawing options, provide an interface like 
```julia
@Graph g 1:100 GraphNode(12, [draw_shape(:square, 12), draw_text(:inside, "123"), fill(:image, "./img.png"), custom_border()])
```
This requires custom functions to adhere to some rules and export some parameters to other functions. For example, if nodes are drawn as square return `text_bbx` to support the option `:inside` of `draw_text`. Similarly to have your own custom border you can use `border_bbx` from a drawing function to create a border around the node.

Stuck on:
* How to manage keywords arguments passed to different drawing functions. For example, an object passes all the change keyword arguments to the drawing function, but to support node drawing functions like `draw_shape(:square, 12)` or custom functions like `star(...)` which may return something similar to `args(...; length=12)` only specific keyword armguents need to be supplied.

#### 29 June
Completed:
* A demo to do a basic graph animation.
* Add custom node shapes (square and circle), node borders (square and circular borders), node filling (color), node annotation (text within a box)
```julia
@Graph g 1:100 GraphNode(12, [draw_shape(:square, 12), draw_text(:inside, "123"), fill(:color, "red"), border("yellow")])
```
* The predefined functions above like `draw_shape`, `draw_text` etc. each return a function  having some keyword arguments to be used by this draw function.
    * These options need to be provided by the user or exposed by some draw function like `draw_shape`--exposes-->`:text_box`--usedby-->`draw_text`.
    * The issue was how to identify and compile this pool of keywords into a single draw function.

Working on:
* Extending the options available for node drawing configuration.
* Edge drawing functions and line animation options.
    * Need to handle self-loops and curves in graph.
    * Animate a line generated from source to destination.

Approach(s) thought of (or used):
* Add a regular polygon option for node draw shape and add compatible support for it for borders and text box.

Stuck on:
* Aligning text on straight edges depending on the direction of edge.
* Approximate area to draw self loop edges to prevent clutter.

#### 6th July
Completed:
* Node drawing configurations and demo.
    * Divided node property into shape, text, fill & border.
* Animating line (curved lines) from a source to destination node

Working on:
* Edge drawing properties :- shape, style, label, arrowheads.
    * Shape will provide a clip over the edge which maybe a curved or straight line. Shape also includes line width, end offsets and curvature.
    * Styles incorporate features like color blends and dash type.
    * Arrow deals with options to set arrows on the edge.
    * Label/text allows positioning text boxes/latex relative to the edge

Stuck on:
* For both nodes and edges, the `node_shape` and `edge_shape` function was supposed to provide a clip around the edge and any custom function provided by the user would be clipped within that region. `:clip` action does not work as expected on a line.
* How to return a edge outline for edges of different shapes? For example, for a line it an be 2 points for a circle it can be 3 points etc. This is required when positioning labels/glyphs with relative positioning on the edge.
