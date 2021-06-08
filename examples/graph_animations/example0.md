## Graph Animation Demos

The demo serves to list the features that I am going to implement for graph animation using Javis. The example links at the end will take you to use cases that I think are worth considering before implementing the actual API.

### List of features

* Graph type invariance - The user should have the flexibility in terms of the type of the graph. The default graph type supported would be from LightGraphs.jl
* Add/Remove edges or nodes - Upon such changes the layout should change automatically to take into account the new arrangement
* Utilities to update properties on the graph
    1. `animate_inneighbours` - Incoming neighbours
    2. `animate_outneighbours` - Outgoing neighbours
    3. `animate_neighbours`
    4. `changeNodeProperty` - Update drawing style of node(s) on canvas
    5. `changeEdgeProperty` - Update drawing style of edge(s) on canvas
    6. `highlightNode` - Highlight node(s) using blinking outlines
    7. `highlightEdge` - Highlight edge(s) using blinking outlines
    8. `animatePath` - Animate a path on the graph
    9. `bfs` - Animate bfs at a node
    10. `dfs` - Animate dfs at a node

### Examples

1. [Breadth First Search]()
2. [Shortest Path]()
3. [Cycle Detection]()
4. [Minimum Spanning Tree]()
5. [Bipartite Matching]()
6. [Strongly connected components]()
7. [Graph Coloring]()
