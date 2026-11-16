using PhyloIO
using Test
using Random

@testset "PhyloIO" begin
    @testset "Newick basics" begin
        t = parsenewick("((A:1,B:2)90:0.5,(C:1,'D e':1.5)0.7:1,F:3);")
        @test ntips(t) == 5
        @test nnodes(t) == 8
        @test tipnames(t) == ["A", "B", "C", "D e", "F"]
        @test branchlength(t, findnode(t, "B")) == 2.0
        m = mrca(t, ["A", "B"])
        @test getdata(t, m, :support) == 90.0
        @test nodelabel(t, m) == ""
        @test getdata(t, mrca(t, "C", "D e"), :support) == 0.7
        @test mrca(t, ["A", "C"]) == rootnode(t)
        @test treeheight(t) ≈ 3.0
        @test isroot(t, rootnode(t))
        @test isleaf(t, findnode(t, "A"))
        @test length(descendants(t, m)) == 2
        @test ancestors(t, findnode(t, "A")) == [m, rootnode(t)]
        @test nodeindex(t, ["A"]) == findnode(t, "A")
        @test findnode(t, "D_e") == findnode(t, "D e")
        @test_throws ArgumentError findnode(t, "nope")
    end

    @testset "round trip" begin
        s = "((A:1,B:2)90:0.5,(C:1,'D e':1.5):1,F:3);"
        t = parsenewick(s)
        @test writenewick(t) == s
        t2 = parsenewick(writenewick(t))
        @test tipnames(t2) == tipnames(t)
        @test rootdistance(t2) ≈ rootdistance(t)
        path = tempname() * ".nwk"
        writenewick(path, t)
        @test tipnames(readnewick(path)) == tipnames(t)
        open(path, "w") do io
            println(io, s)
            println(io, "(X,Y);")
        end
        @test length(readnewick(path; all=true)) == 2
    end

    @testset "annotations" begin
        t = parsenewick("((A:1[&&NHX:S=human:E=1.1],B:1)[&&NHX:B=100]:1,C:2);")
        @test getdata(t, findnode(t, "A"), :S) == "human"
        @test getdata(t, findnode(t, "A"), :E) == 1.1
        @test getdata(t, mrca(t, "A", "B"), :B) == 100.0
        b = parsenewick("[&R] ((A[&rate=0.5]:1.0,B:1.0)[&posterior=0.98,height_95%_HPD={0.8,1.3},clade=\"x,y\"]:2.0,C:3.0);")
        n = mrca(b, "A", "B")
        @test getdata(b, n, :posterior) == 0.98
        @test getdata(b, n, Symbol("height_95%_HPD")) == [0.8, 1.3]
        @test getdata(b, n, :clade) == "x,y"
        @test getdata(b, findnode(b, "A"), :rate) == 0.5
        c = parsenewick("((A,B)95/0.99,C);")
        @test getdata(c, mrca(c, "A", "B"), :supports) == [95.0, 0.99]
        @test all(isnan, c.length)
        @test rootdistance(c) == [0, 1, 2, 2, 1]
        @test_throws ArgumentError parsenewick("((A,B);")
    end

    @testset "Nexus" begin
        nex = """
        #NEXUS
        begin taxa;
          dimensions ntax=3;
          taxlabels Homo Pan Gorilla;
        end;
        begin trees;
          translate
            1 Homo,
            2 Pan,
            3 'Gorilla gorilla'
          ;
          tree TREE1 = [&R] ((1[&rate=1]:1,2:1)[&posterior=1.0]:1,3:2);
          tree TREE2 = [&R] ((1:1,3:1):1,2:2);
        end;
        """
        path = tempname() * ".nex"
        write(path, nex)
        t = readnexus(path)
        @test tipnames(t) == ["Homo", "Pan", "Gorilla gorilla"]
        @test getdata(t, mrca(t, "Homo", "Pan"), :posterior) == 1.0
        @test length(readnexus(path; all=true)) == 2
    end

    @testset "edits" begin
        t = parsenewick("(((A:1,B:1):1,C:2):1,(D:1,E:1):2);")
        ladderize!(t)
        @test tipnames(t)[end] in ("A", "B")
        ladderize!(t; right=false)
        @test tipnames(t)[1] in ("A", "B")
        rotatenode!(t, ["D", "E"])
        sorttips!(t, ["E", "D", "C", "B", "A"])
        @test tipnames(t) == ["E", "D", "C", "B", "A"]
        k = keeptips(t, ["A", "C", "D"])
        @test sort(tipnames(k)) == ["A", "C", "D"]
        @test nnodes(k) == 5
        @test rootdistance(k)[findnode(k, "A")] ≈ 3.0
        r = reroot(t, "E")
        @test ntips(r) == 5
        @test sort(tipnames(r)) == sort(tipnames(t))
        @test sum(filter(!isnan, r.length)) ≈ sum(filter(!isnan, t.length))
        @test length(childnodes(r, rootnode(r))) == 2
        @test ntipsbelow(t)[rootnode(t)] == 5
    end

    @testset "randtree" begin
        rng = Xoshiro(1)
        for model in (:yule, :coalescent)
            t = randtree(30; rng, model, height=10)
            @test ntips(t) == 30
            d = rootdistance(t)
            @test all(isapprox(d[i], 10; atol=1e-9) for i in tips(t))
        end
        @test ntips(randtree(1)) == 1
    end

    @testset "show" begin
        t = randtree(12; rng=Xoshiro(2))
        @test occursin("12 tips", sprint(show, t))
        @test occursin("tips:", sprint(show, MIME"text/plain"(), t))
    end
end
