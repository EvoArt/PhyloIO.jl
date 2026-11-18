# PhylogenyIO.jl

[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://evoart.github.io/PhylogenyIO.jl/stable/)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://evoart.github.io/PhylogenyIO.jl/dev/)
[![CI](https://github.com/EvoArt/PhylogenyIO.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/EvoArt/PhylogenyIO.jl/actions/workflows/CI.yml)

A rooted phylogenetic tree type with readers and writers for Newick (including
NHX and BEAST/MrBayes annotations) and Nexus trees blocks, plus common tree
queries and edits. No dependencies outside the standard library.

```julia
using Pkg; Pkg.add("PhylogenyIO")

using PhylogenyIO
t = readnexus("trees.nex")          # or readnewick / parsenewick
mrca(t, ["A", "B"])
writenewick("out.nwk", ladderize!(t))
```
