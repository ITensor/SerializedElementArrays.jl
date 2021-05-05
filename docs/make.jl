using SerializedElementArrays
using Documenter

DocMeta.setdocmeta!(SerializedElementArrays, :DocTestSetup, :(using SerializedElementArrays); recursive=true)

makedocs(;
    modules=[SerializedElementArrays],
    authors="Matthew Fishman <mfishman@flatironinstitute.org> and contributors",
    repo="https://github.com/mtfishman/SerializedElementArrays.jl/blob/{commit}{path}#{line}",
    sitename="SerializedElementArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mtfishman.github.io/SerializedElementArrays.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mtfishman/SerializedElementArrays.jl",
)
