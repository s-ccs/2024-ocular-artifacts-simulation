#import "@preview/arkheion:0.1.0": arkheion, arkheion-appendices

#show: arkheion.with(
  title: "Ocular EEG-artefact simulation with UnfoldSim.jl",
  authors: (
    (name: "Maanik Marathe", email: "maanik.work@gmail.com", affiliation: "University of Stuttgart", orcid: "0000-0000-0000-0000"),
    (name: "Author 2", email: "user@domain.com", affiliation: "Company", orcid: "0000-0000-0000-0000"),
    (name: "Author 3", email: "user@domain.com", affiliation: "Company", orcid: "0000-0000-0000-0000"),
  ),
  abstract: [Simulation of eye movement artefacts in EEG using the HArtMuT head model and UnfoldSim.jl.],
  // keywords: ("First keyword", "Second keyword", "etc.", "EEG eye artefact simulation", "Corneo-retinal dipole"),
  date: "March 31, 2025",
)
#set cite(style: "ieee")
#set text(lang: "en", region: "GB")
#show link: underline

= Introduction

EEG recordings contain not only the data from the actual brain sources, but also artefacts from other biological sources (e.g. eye movements, blinks, muscle movements, heartbeat) and non-biological sources (e.g. line noise, channel noise, etc). Various artefact detection removal methods are used when analysing data from EEG recordings, for example independent component analysis (ICA) and linear regression, and toolboxes for EEG analysis often include such methods.

Simulating EEG data is useful when developing and testing such tools, and it is useful to be able to specify a particular ground truth for the simulation, in order to better evaluate the results of applying the analysis methods on the simulated data. Software packages like @schepers_2025_14894630 provide support to simulate EEG data from brain sources and to add various types of noise; however, realistic simulation of biological artefacts in EEG is not yet available.

In this project, we focus on eye movement artefacts - we first build a biologically-motivated model of the human eye, then simulate specific eye movements and observe the corresponding effect on the topography of the recorded EEG.

== Eye structure and corneo-retinal dipole (CRD)
The eye is made up of various types of tissues, some having standing electric potentials. When the subject in an EEG recording changes their gaze direction, the eyeball rotates in its socket and the charged tissues also accordingly move in space. This change in the spatial distribution causes a change in the resultant electric potential measured at each of the scalp electrodes, and this change is visible in the EEG recordings as an eye movement artefact. ((EOG?)) ((ref @mowrer_corneo-retinal_1935? ))

Previous studies like  @mowrer_corneo-retinal_1935 and @matsuo_electrical_1975 showed that an intact eyeball is required in order to see the EOG effects due to eye movements. The retina and cornea have each been shown to have a potential difference between their inner and outer surfaces @lins_ocular_1993-1, with the inner side of the retina being positive relative to the outer side and the outer side of the cornea being positive relative to the inner side ((ref)). This leads to an overall potential difference in the eye, which is often approximated as a single dipole with its positive end towards the cornea at the front. This single dipole is called the "corneo-retinal potential" @mowrer_corneo-retinal_1935 or "corneo-retinal dipole" (CRD) ((steinberg_1983 - check actual ref in lins.)) and is a basis of the model of eye movements in existing studies (@berg_dipole_1991, ((add ref))).

== Modelling eyes and eye movement artefacts

A common approach when modelling eye movement and blink artefacts in EEG is to consider a certain set of source dipoles placed in or near the eyes, varying their position and orientation such that their contribution explains as much of the artefact as possible. For example, @berg_dipole_1991 considered "equivalent dipoles" resulting from the vector difference between the CRD at the start versus at the end of the movement. They recorded data of four subjects performing horizontal and vertical eye movements of 15° away from the centre fixation point. They then tried to fit source dipoles that gave the least residual variance (unexplained variance) in the data. For horizontal movements, the result was a set of four dipoles: one in each eye for a movement to the left, and another pair for the movement to the right. These dipoles were in the horizontal plane, tangential to the surface of the head, and in the direction of the eye movement; however, the dipole orientations for a particular eye movement were not the same in both eyes. A diagram of these dipoles was shown as below, and a more detailed explanation can be found in the original paper.

((placeholder - diagram of B&S dipoles))

Alternatively, the standing potentials in the eye tissues can be represented in the form of "Equivalent Current Dipoles", as done in @harmening_hartmutmodeling_2022 (further described in a section below). These equivalent current dipoles should each have an orientation according to the direction of their tissue potentials: dipoles placed in the cornea point outwards, since the cornea is more positive on the outside of the eyeball, and similarly the retina dipoles point inwards. In this project, we have used this model in order to bring our simulation closer to the biological reality of the movement. 

It is also possible to represent the CRD itself as a single dipole placed in the eye and oriented in the direction of eye gaze. We will call this dipole the "resultant" dipole as it represents the resultant effect of the overall charge distribution in the eye. In order to simulate an eye movement, this dipole can be reoriented according to the gaze direction at various points in time, and the corresponding scalp topography can be calculated. 

placeholder - 
((fig. our model w/ ret. & cornea sources)) ((fig. resultant CRD model with one dipole per eye)) - pointing to the left and right

== HArtMuT forward model

The HArtMuT forward model @harmening_hartmutmodeling_2022 provides a model of sources of electrical activity in the human head along with the potentials resulting from to each of these measured at a set of 227 electrode positions on the scalp surface. In general, electric potentials present in biological tissues can be represented with the help of such dipoles placed at different points in the space occupied by the tissues. As explained in @malmivuo_bioelectromagnetismprinciples_1995, when a current dipole is placed in a volume conductor, it causes an electrical potential field around it. The potential at any point in space can be described by a set of three vectors in the three coordinate directions, and this is known as the "lead vector", called "leadfield" in the HArtMuT model. For a specific orientation of the source dipole, the resultant potential can be calculated by multiplying the lead vector by the source dipole's orientation.

Relevant for this project, the source locations in HArtMuT belonging to the eye are labelled either "Cornea" or "Retina/Choroid/Sclera". There are sources placed in each individual eye, as well as a set of symmetric sources in a vertical plane between the two eyes, that produce the same effect as summing the lead fields of corresponding individual eye points. We have opted to use individual eye source points to stay as close as possible to the biological model, as well as in order to have independent control over the points of each eye, giving us more flexibility during simulation. While working on this project, we also corresponded with Nils Harmening, one of the authors of the original paper and developers of the forward model, to get an updated eye model with lead fields that were better suited to our purpose. This eye-model is currently unpublished and still under development. The main differences from the eye source points in the published HArtMuT model are that the eye sources are distributed in a more spherical shape and that the retina and cornea source types are placed similarly densely on the surface of the eye.

((placeholder: figure headmodel 3d plot showing eye separate and combined sources;  figure eyemodel 3d plot with rounder eyes))


== Simulation - past approaches
- idea: table; overview with paper name, goal, assumptions, method, simulated or just discussed? etc.

= Simulation of eye movements - our approach

In our approach, we specify a gaze direction vector and calculate the EEG topography resulting from both eyes looking in this direction. To do this, we make use of the set of HArtMuT head model source points having retina and cornea labels. Each source point has a fixed position provided in the head model, and we calculate an orientation vector pointing outwards in the direction from the centre of the respective eyeball to the source point. The intrinsic eye gaze direction in the model is taken as the average of the cornea-point orientations of that eye, and we can define the angular extent of the cornea to be the maximum value of the angle between the cornea orientations and this gaze direction.

Although the physical eyeball rotates when the gaze direction changes, the cornea does not move relative to the gaze direction, i.e. the relationship between the cornea points and the current gaze direction vector remains the same at all times. Thus, for any given gaze direction, we can assign corresponding retina or cornea labels to the individual source locations.

We further give each source point a weightage value to represent the orientation of the actual source dipole relative to the orientation vector. As originally calculated, the orientation vector when placed at the source point will represent a dipole pointing outwards, and its negative, a dipole pointing inwards. Thus cornea and retina points are given a weightage of +1 and -1 respectively. The scalp topography for a particular gaze vector is then calculated by multiplying the lead field of each source point by the source orientations and the weightage. 

Finally, the EEG effect of an eye movement from a gaze direction A to a gaze direction B can be calculated by simulating the scalp topography for both and then taking the difference. A sample simulation of a left-to-right horizontal movement from -17° to +17° and a vertical movement from --- to --- (relative to a central fixation point and in the same horizontal/vertical line respectively) is shown below.

((placeholder: top-down diagram of movement showing the two gaze angles, and corresponding topoplots))

== Assumptions and  simplifications

Certain assumptions have been made while developing this model. Firstly, we have assumed each eye to be perfectly spherical, although in reality the cornea surface bulges out slightly at the front, and the eyes are slightly deformed in other directions as well. Next, we assume that the cornea tissue is symmetrically distributed around the axis pointing from the centre of the eye outwards towards the direction of gaze, and thus can be considered to lie on the part of the eye surface that falls within a conical region extending from the eye centre in the direction of gaze. We also assume that during an eye movement, the eye only rotates about its centre and is not translated, although some studies like @moon_positional_2020 show otherwise. Further, some sources indicate that the magnitude of the potentials in the eye changes over time, in particular due to illumination ((ref)). This is not accounted for in our current model.

The current version of the HArtMuT model considers the eyes as part of the skin rather than as a separate tissue type with its own conductivity. This also results effectively in a "closed eyelid" state. Various sources ((ref)) have described the effect of a closing eyelid as modulating the electric potentials of the cornea, and future simulations with our model could take this into account to remove the "closed eyelid" effect. 

= Results

We have carried out three kinds of simulations: First, using our model of multiple retinal and corneal dipoles; second, simulating the CRD as a single dipole at the centre of each eye (resultant dipole method); and third, a set of equivalent dipoles according to the results of @berg_dipole_1991. To compare these, we choose an eye movement from @berg_dipole_1991, namely a movement from the centre fixation point to a point 15° to the left. The topographies obtained via each of these methods are shown in the figure below. The topography for a similar movement from a real dataset is also shown alongside the simulations. 

((placeholder: topoplot of all three together + real data))

= Discussion

== Evaluation

For the scope of this project, we have only a qualitative evaluation of the simulation results. ((placeholder - discussion))
When the eye gaze rotates towards a particular direction, the cornea gets closer to the electrodes in that direction and the retina moves away from them. Since the cornea is relatively positively charged and the retina negative, this causes a positive deflection in the measured potential in the electrodes near the new cornea position and a negative change in the potential at the electrodes that the gaze direction has moved away from. For example, in the selected movement from centre gaze to the left, the electrodes on the left should measure a more positive potential after the movement than before. 

The result of the biological and CRD simulations agrees with this - the difference topographies are positive on the left side and negative to the right. The equivalent difference-dipole simulation also provides a similar topography. However, ((the topographies look different in ----- way - need to evaluate w.r.t. real data by scaling and choosing corresp. electrodes and see which one matches))

== Limitations 
- from assumptions or otherwise 
- evaluation - normalising topographies?
- does not account for eyelid movements accompanying eye movement (see rider artefact) or the effects from muscle activations.
- inherent scaling - source orientations & leadfields are in terms of unit magnitude, so we will need to scale the values data-driven
- lins source - cornea is negative on the outside?  Plus many sources do not mention cornea as contributing to the CRD at all => this is debated, but we have chosen to have cornea considered & pointing outwards
- eyes as their own tissue type /conductivity - will come in a later model?
- retina & cornea source points density on the surface of the eye not equal - currently there is a bias towards the points at the front of the eye (original cornea points)

== Outlook 
- simulating with evenly spaced source points
- simulating eye movements of different angles & with different start/end positions: can compare all 3 models we have and check with recorded data.
- currently just simulated purely horizontal & vertical movements - can also look at gaze for points all over the plane/screen.
- model includes the possibility to give an independent gaze direction for individual eye - can simulate vergence movement 
- does it produce nonlinear HEOG for larger eyemovements? ((ref - papers saying it's linear only up to ~30deg))
- B&S also investigated effective dipoles with changing positions rather than just orientations; could try doing this with the DD simulation.
- Other possibilities to simulate: e.g. cont. saccade; closed vs. open eye; lid movement for blink; eye muscle activation for blink; Bell's phenomenon;
- UnfoldArtifacts.jl (future): package to simplify simulation of such artefacts.

= Summary

In this project, we develop a model of the human eye represented by a set of electrical current dipoles and provide a method to calculate the scalp topography for any given gaze direction of the eye. ((placeholder for analysis/evaluation summary))


= Acknowledgements

((good place to put in the note about discussion with Nils?))

((copy-paste degree symbol ° ))

// Add bibliography and create Bibiliography section
#bibliography("bibliography.bib")

// // Create appendix section
// #show: arkheion-appendices
// =

// == Appendix content