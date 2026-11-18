using Documenter, PhylogenyIO

makedocs(
    sitename = "PhylogenyIO.jl",
    modules = [PhylogenyIO],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages = ["Home" => "index.md"],
    checkdocs = :exports,
)

deploydocs(repo = "github.com/EvoArt/PhylogenyIO.jl.git", devbranch = "main")
