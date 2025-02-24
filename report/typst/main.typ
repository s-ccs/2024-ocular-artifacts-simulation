#import "@preview/arkheion:0.1.0": arkheion, arkheion-appendices

#show: arkheion.with(
  title: "Eye Artefact Simulation with UnfoldSim.jl",
  authors: (
    (name: "Maanik Marathe", email: "maanik.work@gmail.com", affiliation: "University of Stuttgart", orcid: "0000-0000-0000-0000"),
    (name: "Author 2", email: "user@domain.com", affiliation: "Company"),
    (name: "Author 3", email: "user@domain.com", affiliation: "Company"),
  ),
  abstract: [Simulation of eye artefacts in EEG using the HArtMuT head model and UnfoldSim.jl.],
  keywords: ("First keyword", "Second keyword", "etc."),
  date: "March 31, 2025",
)
#set cite(style: "chicago-author-date")
#set text(lang: "en", region: "GB")
#show link: underline

= Introduction

- Eye movements effect on EEG - explain artefacts created (with plots if required), current approaches to dealing with them
- Explain need for simulating EEG data (ref. UnfoldSim)
- Need for simulating artefacts - creating data with a specific ground truth
- 3-line overview of what we did in this project.

== Human eye structure

=== Biological structure: 
- Different tissue types and their electrical properties; what do various papers say about this? In summary, what is relevant to us.

=== Modelling: 
- Considering the eye as dipole / set of dipoles.
- Table: past papers' approaches to modelling the eye


== HArtMuT model
- Basic intro
- Dis/advantages & assumptions
- Some first explorations, with plots and such (maybe just point to the Pluto notebook?)
- Explanation of how eye sources are modelled in HArtMuT. Single and symmetric sources + which one we chose and why
- Source locations - the points/meshes from the MIDA atlas have been used - experts manually segmented the MRI and specified which points were considered cornea, retina, sclera etc. Orientations have unit length.
- The labels used in the MIDA atlas for the eye are  `Aqueous, Vitreous, Lens, Cornea,  and Retina/Choroid/Sclera`, and the points we use / available in HArtMuT are either `Cornea` type or `Retina/Choroid/Sclera` type. 
- Leadfield explained, in context of HArtMuT. Position, orientation, the fact that in EEG only a difference signal is detected (ref. Berg&Scherg(?) paper)
- HArtMuT - small vs. large model, number of points: 
  #table(
    columns: 4,
    table.header([Model], [Cornea-Sclera], [Retina], [Total (eye + muscle)]),
  
    [Small], [720], [360], [4260], 
    [Large], [720], [360], [76211],
  )

== Relation: eye movement & EEG
- 

== Simulation - past approaches
- idea: table; overview with paper name, goal, assumptions, method, simulated or just discussed? etc.

= Simulation - our approach
Simple explanation of how we are going to simulate.
- e.g. with single or symmetric?
- concept of a source point - position, orientation, weightage
- "resting" state - normal gaze ahead, in original HArtMuT model
- Rotating the eyeball by changing gaze direction, relabelling source points as cornea/retina w.r.t gaze direction, and applying orientation (and potentially weightage) to the updated source points.  
- How does this work with the symmetric sources?

== Assumptions & Simplifications
- We have assumed the eye to be perfectly spherical.
- Categorisation of source points is either as retina/choroid/sclera or as cornea - considering only 2 main tissue types. (the source points in HArtMuT are selected from these two labels, and we use them directly)
- All source points of a particular label ('retina'/'cornea') are charged the same way and with the same magnitude as the other points in the label. That is, there is no gradual tapering off at the changeover point between the retina and cornea type points.
...

== Simulation process/steps

= Evaluation
- 

= Discussion - Limitations and outlook
- Limitations - from assumptions or otherwise 
- Outlook - e.g. eye rotation; lid movement for blink; eye muscle activation for blink; Bell's phenomenon; closed vs. open eye; other muscle artefacts
- UnfoldArtifacts.jl: (very) short intro of UnfoldSim/UnfoldArtefacts - also can just point to the git/docs

= Summary





// Add bibliography and create Bibiliography section
#bibliography("bibliography.bib")

// Create appendix section
#show: arkheion-appendices
=

== Appendix content