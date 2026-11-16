# PhyloIO.jl

```@docs
PhyloIO
```

```julia
using PhyloIO
t = parsenewick("((A:1,B:1)95:2,C:3);")
mrca(t, ["A", "B"])
writenewick(ladderize!(t))
```

## Tree type

```@docs
PhyloTree
addnode!
```

## Queries

```@docs
nnodes
ntips
isleaf
isroot
rootnode
parentnode
childnodes
branchlength
nodelabel
getdata
setdata!
preorder
postorder
tips
tipnames
internalnodes
descendants
ancestors
findnode
mrca
nodeindex
rootdistance
treeheight
ntipsbelow
```

## Edits

```@docs
ladderize!
rotatenode!
sorttips!
keeptips
reroot
```

## Reading and writing

```@docs
parsenewick
readnewick
writenewick
readnexus
```

## Simulation

```@docs
randtree
```
