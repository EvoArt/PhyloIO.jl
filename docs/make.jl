using Documenter, PhyloIO

makedocs(
    sitename = "PhyloIO.jl",
    modules = [PhyloIO],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages = ["Home" => "index.md"],
    checkdocs = :exports,
)

deploydocs(repo = "github.com/EvoArt/PhyloIO.jl.git", devbranch = "main")
