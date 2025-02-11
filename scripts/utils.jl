# using HDF5
# using DataFrames

function read_new_hartmut(;p = "HArtMuT_NYhead_large_fibers.mat")
    file = matopen(p);
    hartmut = read(file, "HArtMuT");
    close(file)
    
    fname = tempname(); # temporary file
    
    fid = h5open(fname, "w") 
    
    
    label = string.(hartmut["electrodes"]["label"][:, 1])
    chanpos = Float64.(hartmut["electrodes"]["chanpos"])
    
    cort_label = string.(hartmut["cortexmodel"]["labels"][:, 1])
    cort_orient = hartmut["cortexmodel"]["orientation"]
    cort_leadfield = hartmut["cortexmodel"]["leadfield"]
    cort_pos = hartmut["cortexmodel"]["pos"]
    
    
    art_label = string.(hartmut["artefactmodel"]["labels"][:, 1])
    art_orient = hartmut["artefactmodel"]["orientation"]
    art_leadfield = hartmut["artefactmodel"]["leadfield"]
    art_pos = hartmut["artefactmodel"]["pos"]
    
    e = create_group(fid, "electrodes")
    e["label"] = label
    e["pos"] = chanpos
    c = create_group(fid, "cortical")
    c["label"] = cort_label
    c["orientation"] = cort_orient
    c["leadfield"] = cort_leadfield
    c["pos"] = cort_pos
    a = create_group(fid, "artefacts")
    a["label"] = art_label
    a["orientation"] = art_orient
    a["leadfield"] = art_leadfield
    a["pos"] = art_pos
        a["fiber"] = Int.(hartmut["artefactmodel"]["fiber"][1,:])
    a["dist_from_muscle_center"] = hartmut["artefactmodel"]["dist_from_muscle_center"][1,:]
    close(fid)
    
    #-- read it back in (illogical, I know ;)
    h = h5open(fname)


    weirdchan = ["Nk1", "Nk2", "Nk3", "Nk4"]
    ## getting index of these channels from imported hartmut model data, exclude them in the topoplot
    remove_indices =
        findall(l -> l ∈ weirdchan, h["electrodes"] |> read |> x -> x["label"])
    print(remove_indices)

    function sel_chan(x)

        if "leadfield" ∈ keys(x)
            x["leadfield"] = x["leadfield"][Not(remove_indices), :, :] .* 10e3 # this scaling factor seems to generate potentials with +-1 as max
        else
            x["label"] = x["label"][Not(remove_indices)]
            pos3d = x["pos"][Not(remove_indices), :]
            pos3d = pos3d ./ (4 * maximum(pos3d, dims = 1))
            x["pos"] = pos3d
        end
        return x
    end
    headmodel = Hartmut(
        h["artefacts"] |> read |> sel_chan,
        h["cortical"] |> read |> sel_chan,
        h["electrodes"] |> read |> sel_chan,
    )
    return headmodel
end

function read_eyemodel(;p = "HArtMuT_NYhead_extra_eyemodel.mat")
    # read the intermediate eye model (only eye-points)
    file = matopen(p);
    hartmut = read(file,"eyemodel")
    close(file)
    hartmut["label"] = hartmut["labels"]
    hartmut
end

function hart_indices_from_labels(headmodel,labels=["dummy"]; plot=false)
    # given a headmodel and a list of labels, return a Dict with the keys being the label and the values being the indices of sources with that label in the given model. plot=true additionally plots the points into an existing Makie figure. 
    labelsourceindices = Dict()
    for l in labels
        labelsourceindices[l] = findall(k->occursin(l,k),headmodel["label"][:])
        if plot
            WGLMakie.scatter!(model["pos"][labelsourceindices[l],:]) #optional: plot these points into the existing figure
        end
        println(l, ": ", length(labelsourceindices[l])," points")
    end
    return labelsourceindices
end

function pos2dfrom3d(pos3d)
	pos2d = UnfoldMakie.to_positions(pos3d')
	pos2d = [Point2f(p[1] + 0.5, p[2] + 0.5) for p in pos2d]; 
    return pos2d
end

function plot_leadfields_difference_topo(lf1,lf2,pos2d)
	# given cornea and retina leadfields, plot them both and the resultant cornea-retina difference leadfield
	f = Figure()
	plot_topoplot!(
		f[1,1], lf1-lf2, positions=pos2d, layout=(; use_colorbar=true), visual = (; enlarge = 0.65, label_scatter = false),)
	plot_topoplot!(
		f[2,1], lf1, positions=pos2d, layout=(; use_colorbar=true), visual = (; enlarge = 0.65, label_scatter = false),)
	plot_topoplot!(
		f[2,2], lf2, positions=pos2d, layout=(; use_colorbar=true), visual = (; enlarge = 0.65, label_scatter = false),)
	return f
end

function calc_orientations(reference, positions; direction="towards")
		# calculate orientations from the given positions w.r.t. the reference
		if direction == "towards"
			orientation_vecs = reference .- positions
		else
			orientation_vecs = positions .- reference
		end
		return orientation_vecs ./ norm.(eachrow(orientation_vecs))
end

function angle(a,b) 
    return acosd.(dot(a, b)/(norm(a)*norm(b)))
end
