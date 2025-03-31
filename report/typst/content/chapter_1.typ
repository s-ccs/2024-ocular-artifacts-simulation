#import "../src/utils.typ": * 

= Introduction

#abbr.l("EEG") is a method of recording the electrical activity of the brain via a set of electrodes (or sensors), usually placed on the scalp and/or the facial skin of the subject. When taking an EEG measurement, an appropriate electrode positioning system is chosen out of the several available standardized systems, and the electrodes are arranged on the scalp according to the selected system.

During an EEG recording, each of the electrodes measures the electrical potential at its respective location, relative to the potential at some other point (called the reference). That is, the recorded value at an electrode is a measure of the potential difference between that electrode and the reference @hari_meg-eeg_2017. The data thus gathered is later analyzed in order to understand more about the inner working of the brain.

== Artefacts in EEG

Ideally, the recorded EEG data would contain pure signal, i.e. just the scalp potentials resulting from brain activity. However, there are often a number of sources of noise in the recorded EEG, such as power line noise (from the alternating current electrical power supply) or slow drifts or noise present at a certain problematic electrode. Such noise can be removed during preprocessing of the data, for example by filtering the data or by discarding or interpolating the data for a noisy electrode.

In addition, there is another category of unwanted potentials (or "artefacts") present in the recorded EEG data. Various biological processes occurring in the body also involve electrical activity. For example, the muscles of the head, face, and neck are electrically activated when moving the head or eyes, when talking, and so on. The electrical activity during the heartbeat generates a measurable potential (the electrocardiogram). The movement of the eyeball itself also causes a change in the measured scalp potential, as does the action of blinking. These processes thus modify the electrical potential measured by the EEG electrodes.

These artefact effects can be much larger in magnitude than the potentials recorded from the brain activity, and therefore cause problems during analysis since they may obscure the data related to brain activity. Thus, their presence in the data needs to be minimized in order to have a clean signal containing as far as possible only the measured brain activity. 

The removal of these artefacts can be done either by avoiding the artefacts at the time of recording (for example, by asking the subject to move as little as possible during the recording), or by removing the artefacts after the data has been recorded. The simplest way to do this is by manual inspection of the data by an expert, marking the contaminated sections of data and removing those sections before analysis. However, this is difficult and time-consuming, and results in less data available for analysis. Therefore, automated methods have been developed for removing artefacts and repairing the contaminated trials, of which two popular examples are #abbr.a("ICA") (a Blind Source Separation technique) and linear regression. 


== Simulation of EEG data and artefacts

For analyzing recorded data, software implementations of data analysis and artefact correction methods are provided in the form of packages, such as in autoreject @jas:hal-01313458, EEGLAB @delorme_eeglab_2004, MNE @larson_mne-python_2024, and Unfold.jl @ehinger_unfoldjl_2025. These can be tested using real datasets from EEG recording studies. 

To reduce the dependence on real datasets, simulating EEG data is also useful for developing and testing such software tools. It is useful to be able to specify a ground truth for the simulation, in order to better evaluate the results of applying the analysis methods on the simulated data. Software packages like SEREEGA @krol_sereega_2018, MNE @larson_mne-python_2024, and UnfoldSim.jl @Schepers2025 provide support to simulate EEG data from brain sources and to add different kinds of random noise to the data. 

Some previous studies have also involved simulating eye movement artefacts and adding them to simulated EEG signals. For example, #pc[@barbara_monopolar_2023] extended a previously-defined battery model of the eye, and simulated eye movements where both eyes were fixated on the same onscreen target (i.e., not looking in parallel gaze directions, but rather focused on one object closer to the face). However, a general method for realistic simulation of the different types of biological artefacts like eye movements, blinks etc. is not yet available, and therefore simulated data is still dissimilar to real data in this aspect.

== Aim and scope of this project

As seen in the preceding sections, artefacts in real EEG data are undesirable and need to be removed before starting to process the data for research, and tools have been created to perform this removal. Current methods for simulation of data do not allow for creating realistic artefacts along with the brain-source data. We wanted to better understand how these artefacts come about, and using this understanding, work towards a method of realistic artefact simulation.

Thus, in this project, we first investigate the origin of the measured EEG potentials during eye movements, and describe two possible methods to simulate these potentials. We then simulate two kinds of movements with these methods, namely a purely horizontal movement and a purely vertical one, and qualitatively examine the simulation results using a topography plot of the difference in potentials between two gaze directions.

For the scope of this project, an "eye movement" is defined as the rotation of the eyeball in order to change the gaze direction from a starting direction "A" to an ending direction "B". The other physiological aspects of an eye movement, like the accompanying eyelid movement and the activations of the muscles in order to rotate the eye, are not considered in our current model. During evaluation, we also compare the potentials measured only at the start and at the end point of the eye movement, and do not simulate the intermediate trajectory followed by the eye to go from A to B.

The code for this project was written in Julia; however, the steps of the simulation are explained in a general manner and it should be possible to implement these in a different programming language as well.

== Important terms used in this report

=== Scalp Topography / Topoplot
Scalp topography plotting is a common visualization technique used in EEG analysis. Here, the data values at each of the sensor locations are plotted onto a two-dimensional image representing a top-down view of the head. The sensor locations in three-dimensional space are mapped to the corresponding two-dimensional locations on the head image, and the data value at each spatial point is represented by a color mapped to the value. Thus a topographical map is created, which allows us to see the pattern of the data across the scalp. 

=== Source Dipole and Lead Field
Electric potential differences present in human tissues can be represented by means of electrical current dipoles placed at different points in the space occupied by the tissues @malmivuo_bioelectromagnetismprinciples_1995. 

#figure(
  image("../src/graphics/fig source dipole.png", width: 30%),
  caption: "Electrical current dipole representing a potential difference"
)

#v(0pt, weak: true)

When such a current dipole (also called "*source dipole*") is placed in a three-dimensional conducting medium (known as a "volume conductor"), it creates an electrical potential field around it. The resulting potential at any point in space can be described using a set of three vectors in the three coordinate directions, and this is known as the "*lead vector*" or "*lead field*". For a specific orientation of the source dipole, the resultant potential at a point in space can be calculated by multiplying together the source dipole's orientation and the lead vector at that point in space.

=== Head Model <eeg-head-model>
In EEG research, a 'head model' describes the head and the biological tissues in it as a conducting medium that conducts electrical potentials @hari_meg-eeg_2017 @malmivuo_bioelectromagnetismprinciples_1995. The simplest head model is a homogeneous sphere, made of the same material throughout. In reality, different tissues have different conductivities, and this impacts the conduction of the electrical potentials through the head. The head model can thus be improved by subdividing the head volume into different tissue types, and then by assigning the respective tissue conductivity to each section. 

When a source dipole is placed in such a volume conductor, the task of calculating the resultant potentials at each measured point on the head surface is known as the "forward problem" @malmivuo_bioelectromagnetismprinciples_1995, and a head model containing information is known as a "*forward model*". 

In this project, we have used the #abbr.a("HArtMuT") @harmening_hartmutmodeling_2022 as a forward model to simulate scalp potentials. We represent the electrical potential differences located in the eyes by selecting appropriate source points from the head model, and calculate the scalp potentials using the corresponding lead fields provided.

=== Gaze Direction Vector
The "gaze direction vector" for an eye is a vector in the same coordinate system as the head model, having unit length and pointing from the center of the eye in the direction of the object that the subject is looking at. The location of this vector is not important as it only describes a direction. 

We assume that the eyeball is symmetric around the axis described by the gaze direction vector, and thus this gaze direction vector will always pass through the center of the cornea. 

When the viewed object is sufficiently far away from the subject, we can assume that the gaze directions of both eyes are parallel to each other. Thus the individual gaze directions can be described by a single, common gaze direction vector. 

= Origin and modelling of eye artefacts

== Eye artefacts in EEG

The main physiological sources of eye-related EEG artefacts are eyeball movements, eye muscle activation, and eyelid movements. Eyeball movements involve rotation of the eyeball which has its own electrical charge distribution (see @crd); eye muscle artefacts are generated due to activation of the muscles used in order to move the eyes. Eyelid movement can contribute to multiple artefacts: according to #pc[@iwasaki_effects_2005], the eyelids move along with eye movements, and greatly influence the frontal EEG observed during vertical eye movements. #pc[@matsuo_electrical_1975] explain blink artefacts as resulting from the interaction between the eyelid and the charged surface of the cornea at the front of the eyeball, where the eyelid conducts the positive charges from the cornea towards the frontal electrodes (also known as the "sliding electrode" effect).

Along with the EEG signals measured at the scalp electrodes, the #abbr.a("EOG") signal is often calculated using the electrodes placed near the eyes. Two kinds of EOG signals can be calculated: horizontal, as the difference between the potentials measured at the electrodes placed at the outer edges of the left and right eyes, and vertical, as the difference between potentials measured by electrodes placed above and below the eye. The EOG is often examined in relation to eye movement, as these electrodes are located closest to the eyes and therefore record the strongest eye-related potentials.

In the coming sections, we will discuss in some more detail the origin of the EEG artefacts specifically arising from eyeball movement and describe two methods of modelling the eyes in order to later simulate these artefacts.


== Eye structure and corneo-retinal dipole (CRD) <crd>

The eye is composed of various types of tissue (cornea, retina/sclera/choroid), and parts of the eyeball are filled with fluid (aqueous and vitreous humor). Each of these tissues and fluids have their own electrical conductivity, which influences how they conduct electrical potential. In addition, certain tissue types also have inherent charge distributions caused due to properties of the cells making up the tissue. 

Previous studies like #pc[@mowrer_corneo-retinal_1935] and #pc[@matsuo_electrical_1975] showed that an undamaged eyeball is required in order to see the EOG effects due to eye movements. The retina and cornea have each been shown to have a potential difference between their inner and outer surfaces, with the retina being more positive towards the inside of the eyeball compared to the outside, and the cornea being more positive towards the outside of the eyeball than on the inside @iwasaki_effects_2005. These potentials give rise to an overall potential difference between the front and the back of the eye, with the front of the eye being more positive compared to the back. This potential difference is called the "corneo-retinal potential" @mowrer_corneo-retinal_1935 and is a basis of the model of eye movements in existing studies @berg_dipole_1991 @plochl_combining_2012 @lins_ocular_1993. This potential can be approximated as a single electrical current dipole with its positive end towards the cornea at the front, following the axis of gaze @plochl_combining_2012, and this is commonly known as the "*#abbr.a[CRD]*".

#figure(
  grid(columns: 1, rows: (250pt, 30pt), row-gutter: 3mm,
    image("../src/graphics/eyecharges_crd.png"),
    "Vertical section of the eyeball with corneo-retinal dipole represented by the large black arrow. 
    Reproduced from " + pc[@hari_meg-eeg_2017] + ".",
  ),
  caption: "Eyeball charges and corneo-retinal dipole"
)

Although sources agree that the charge distribution in the retina is part of the cause for the corneo-retinal dipole, there is some difference of opinion about the contribution of the cornea. #pc[@berg_dipole_1991], #pc[@plochl_combining_2012], and #pc[@hari_meg-eeg_2017] in their discussions of the corneo-retinal dipole do not mention the charge of the cornea itself at all. 

However, the concept of the corneo-retinal dipole as it is described here (i.e., a potential difference between the front and back of the eye, being overall positive at the front compared to the back) is common to all the previous studies reviewed in this area.


== Modelling: CRD and Ensemble methods

A common approach when modelling eye movement and blink artefacts in EEG artefact removal is to consider a certain set of source dipoles placed in or near the eyes, varying their position and orientation such that their contribution to the scalp topography explains as much of the artefact as possible. For example, #pc[@berg_dipole_1991] considered "equivalent dipoles" representing the effect of the difference between the CRD position and orientation at the start versus at the end of the movement.

If instead we directly consider the concept of the corneo-retinal dipole, it is also possible to represent the CRD itself as a single source dipole placed in the eye (say, at the center) and oriented in the direction of eye gaze. In order to simulate an eye movement, this dipole can be reoriented according to the gaze direction at each point in time, and the corresponding scalp topography at each time point can be calculated. We will call this model the "*corneo-retinal dipole method*" or the "*CRD method*".

An even more detailed method of simulation can be achieved by using a number of "Equivalent Current Dipoles" in order to model the inherent electric potentials of the eye tissues, as done by #pc[@harmening_hartmutmodeling_2022] (further described in @hartmut-info). The equivalent current dipoles should each have an orientation according to the direction of their tissue potentials: dipoles placed in the cornea point outwards, since the cornea is more positive on the outside of the eyeball, and similarly the retina dipoles point inwards. We will call this method the "*ensemble method*". The ensemble method allows us to simulate the change in spatial distribution of the retina and cornea tissue charges as they move during the eye movement. 

The next chapter describes our method of simulation using the two models introduced above.


= Simulation of eye movements

Now that the two models of the eye have been defined, we can use a forward model to simulate scalp topographies with both of these models.

== Assumptions and simplifications in our model

For this project, we have assumed each eye to be perfectly spherical. In reality, the eyes are more or less spherical, but the surface bulges out slightly at the front. In addition, certain medical conditions like myopia, hypermetropia etc. may cause the eyes to be slightly deformed. However, we have considered the simplest scenario of a healthy subject with perfectly spherical eyes.

Next, we assume that the cornea tissue is symmetrically distributed around the axis pointing from the center of the eye outwards towards the direction of gaze. We also assume that during an eye movement, the eye only rotates about its center and is not translated (although some studies like #pc[@moon_positional_2020] show that some translation may occur). 

Further, some sources @plochl_combining_2012 indicate that the magnitude of the potentials in the eye changes over time, in particular due to illumination. This is not accounted for in our current model.



== Selected forward model: HArtMuT <hartmut-info>

As described in @eeg-head-model, a forward model is useful in computing lead fields from specific source dipole locations. The #abbr.l("HArtMuT") @harmening_hartmutmodeling_2022 is one such forward model. It provides a set of "cortical" source dipole locations placed within the brain, and another set of "artefactual" sources placed on the surface of the eyes and within the muscles. For each of these source points, the model contains lead field vectors for a set of 227 electrode positions on the scalp, neck, and face.

In this project, we have used the HArtMuT source locations present on the eye surface. These fall into two categories: labelled either "Cornea" or "Retina/Choroid/Sclera". There are sources placed in each individual eye, as well as a set of symmetric sources in a vertical plane between the two eyes, that produce the same effect as summing the lead fields of corresponding individual eye points. We decided to use individual eye source points in order to stay as close as possible to the biological model, as well as to have independent control over the points of each eye, giving us more flexibility during simulation. 

#figure(grid(columns: 3, rows: (auto, 30pt, 30pt, 5pt), row-gutter: 3mm, column-gutter: 4mm, align: bottom,

  image("../src/graphics/em_compare_hartmut_angleview.png"), image("../src/graphics/em_compare_hartmut_frontview.png"), image("../src/graphics/em_compare_hartmut_topview.png"), 

  "a) Viewed from the front-right side of the head", "b) Viewed head-on from in front of the eyes", "c) Viewed from the top down, gaze towards the top of the page",

  grid.cell(colspan: 3, "Three-dimensional plot: cornea points in blue, retina points in yellow.
  Created using Makie.jl " + [@DanischKrumbiegel2021]),
),

  caption: "HArtMuT eye source locations"
)

However, certain changes were required to the eye source locations before running the simulation step. In the original model, the eye source point locations did not describe a sphere, and the cornea-type points were more densely clustered than the retina-type points. This would violate our assumption of spherical eyeballs and result in a bias towards the "cornea" source locations compared to the "retina" locations. Thus, our main requirements were that the eye sources be distributed in a more spherical shape and that the retina and cornea source types have a similar density of spacing across the surface of the eye. 

We corresponded with Nils Harmening, one of the authors of the original paper and developers of the HArtMuT model, to better understand how the model was created. We also discussed our ideas for improvements in order to have sources and lead fields that were better suited to our purpose. After our discussion, an updated "eye"-model was then recalculated, with the eye sources at the new source locations.

#figure(grid(columns: 3, rows: (auto, 30pt, 30pt, 5pt), row-gutter: 3mm, column-gutter: 4mm, align: bottom,

  image("../src/graphics/em_compare_sph_angleview.png"), image("../src/graphics/em_compare_sph_frontview.png"), image("../src/graphics/em_compare_sph_topview.png"), 

  "a) Viewed from the front-right side of the head", "b) Viewed head-on from in front of the eyes", "c) Viewed from the top down, gaze towards the top of the page",

  grid.cell(colspan: 3, "Three-dimensional plot: cornea points in blue, retina points in yellow.
  Created using Makie.jl " + [@DanischKrumbiegel2021]),
),

  caption: "Updated (spherical) eye model source locations"
)

The original head model also had two sets of sources for cornea points, with the same location but different orientations. Ignoring the duplicated sources, the updated model had a different proportion of retina and cornea source locations than that of the original HArtMuT head model eye sources, and more source points overall. The differences are summarized in @eyemodel-diff.

#v(20pt, weak: true)

#figure(
  table(
  inset: 5pt,
  columns: (auto, auto, auto, auto),
  table.header(
    [*Model*], [*Cornea points count*], [*Retina Points count*], [*Total eye points*]
    ),
  "HArtMuT model", "240", "360", "600",
  "Updated eye model", "134", "705", "839",
  ),
  caption: [Comparison between eye source counts in the original and modified forward model],
  gap: 10pt,
) <eyemodel-diff>

#v(-5pt, weak: true)

The current version of the HArtMuT model considers the eyes as part of the skin rather than as a separate tissue type with its own conductivity. This also results effectively in a "closed eyelid" state. Future simulations with our model could take this into account and remove the "closed eyelid" effect using more realistic conductivities and updated source dipole strengths. For this, we have also discussed a further update to this model, where the eyes will be considered as having their own distinct conductivity rather than taking on the conductivity of the skin. This intermediate eye-model is currently unpublished and still under development, and may be adapted in future based on further collaboration. 

== Simulating scalp topography using the forward model

This section describes the steps required in both methods for simulating the EEG topography for a particular gaze direction.

=== Corneo-retinal dipole method 
For the corneo-retinal dipole method, we do this by using a single source point placed at the center of each eyeball and having an orientation parallel to the gaze direction. The leadfield for the individual eye center point gives the scalp topography for that eye, and for the overall scalp topography we add the leadfields of both of the eye center dipoles.

=== Ensemble method
The ensemble method requires some additional steps. We make use of the set of HArtMuT head model source points with retina and cornea labels. Each source point has a fixed position provided in the head model, and we calculate an orientation vector with respect to the center of the respective eyeball. These vectors will help define the source dipoles at each of these locations. 

#figure(
  image("../src/graphics/fig charges dipoles representation.png", width: 100%),
  caption: [Representation of eyeball charges using source dipoles (top-down view, cross-section)],
) <charges_representation>

The intrinsic eye gaze direction in the model is taken as the average of the cornea-point orientations of that eye, and we can define the angular extent '\u{03B8}' of the cornea to be the maximum value of the angle difference between the individual cornea orientations and this gaze direction; that is, the angle difference of the "cornea"-labelled point that is farthest from the intrinsic gaze direction.

Biologically, when the eyeball rotates as the subject changes their gaze direction, the cornea does not move relative to the gaze direction, i.e. the relationship between the cornea points and the current gaze direction remains the same at all times. Thus, in our model, for any given gaze direction, we can find and check the angle between the gaze vector and the calculated orientation vector at each source location. If this angle is less than the maximum cornea angle '\u{03B8}', we can relabel that point as "cornea" type, and if not, we relabel it as "retina" type.

#figure(
  image("../src/graphics/fig ret cor source dipoles.png", width: 100%),
  caption: [Spatial distribution of retina and cornea source dipoles during an eye movement (top-down view, cross-section)],
) <retina_cornea_source_dipoles>

To avoid recalculating orientations for each gaze direction vector, we only calculate orientations once at the start of the simulation, oriented away and outwards from the center of the eyeball. For each gaze direction vector, we first calculate the updated label of each source location, then assign each of them a weight (+1 or -1, i.e. a sign) to represent the orientation of the actual source dipole relative to the calculated orientation vector. Cornea and retina points are given weights of +1 and -1 respectively. The scalp topography for a particular gaze vector is then calculated by multiplying the lead field of each source point by the corresponding source orientations and weights, and then summing these individual scalp potentials. 

== Simulation of eye movement from gaze direction A to B

The following set of steps are required in order to simulate the eye movement in the form of a difference topography:

#set enum(numbering: "1.a.")
+ Load forward model
+ Select appropriate eye source points by label: retina and cornea (for ensemble method) or eye centers (CRD method)
+ Set gaze direction vector
+ For the *corneo-retinal dipole method*: set source orientations = gaze direction vector
  
  For the *ensemble method*:  
  + Calculate orientations away from centre
  + Calculate "resting" gaze direction vector and max. cornea angle 
  + Classify retina/cornea points based on gazedir and cor_angle; assign weights
  
+ Calculate scalp potentials: multiply the leadfields and (weighted if ensemble method) orientations for the selected sources, then sum.
+ Difference topography: Simulate the scalp topography (steps 4-5) for gaze direction A, then repeat the same steps for gaze direction B. Finally, calculate the difference (B-A). 




= Results

We chose one test eye movement from the center fixation point to a point 15° to the left (for horizontal movement) and one from the center fixation point to a point 15° upwards (for vertical movement). We simulated these two test movements using the ensemble method as well as the corneo-retinal dipole method. 

The topographies thus obtained are shown in the figures below. Each topo-plot figure contains the scalp topography plots at the movement start point (A), movement end point (B), and the difference (B-A). The last plot is the difference plot shown once again, with the projected electrode positions displayed on the head in order to give a better idea of the deflection at individual electrodes. The plots are generated using UnfoldMakie.jl @Mikheev2025.

== Ensemble method difference topography

#figure(
  image("../src/graphics/results/result_ensemble_horiz.svg", width: 70%),
  caption: [Ensemble method horizontal movement topo plots],
) 

#figure(
  image("../src/graphics/results/result_ensemble_vert.svg", width: 70%),
  caption: [Ensemble method vertical movement topo plots],
) 


== CRD method difference topography


#figure(
  image("../src/graphics/results/result_crd_horiz.svg", width: 70%),
  caption: [CRD method horizontal movement topo plots],
) 

#figure(
  image("../src/graphics/results/result_crd_vert.svg", width: 70%),
  caption: [CRD method vertical movement topo plots],
) 


== Description of results

For the center gaze position, both methods show a positive potential measured at the front of the head, where the electrodes are located closer to the eyes, and a negative potential towards the back of the head.  

In the horizontal movement simulation, the scalp topography is still positive at the front and negative at the back, but the area of positive measured potential is shifted to the left compared to the center gaze. The difference plot shows the change more clearly - the electrodes on the left of the face show a positive value in the difference plot, indicating they experienced an upward deflection, while those on the right show the opposite. 

In the vertical movement simulation, the shift in positive potential is not as easily apparent from simple inspection as in the horizontal simulation. The difference plot however shows that the EEG scalp electrodes all see a positive deflection, with those near the eyes having the highest degree of change.

In both simulation methods, the scale of the difference plot is smaller than that of the corresponding individual gaze direction topographies. For the given size of eye movement (15°), the difference magnitudes for both methods are in the range of approximately one-tenth of the respective gaze direction topographies. 

There is also a large difference in the difference plot scales of the two methods. 


= Discussion

== Qualitative Evaluation

When the subject in an EEG recording changes their gaze direction, the eyeball rotates in its socket and the charged tissues accordingly move in space. This change in the spatial distribution causes a change in the resultant electric potential measured at each of the scalp electrodes, and this change is visible in the EEG recordings as an eye movement artefact @mowrer_corneo-retinal_1935. 

For a movement going from center gaze (looking straight ahead) towards a gaze looking to the left, we would expect the electrodes on the left to measure a more positive potential after the movement than before the eye movement (center gaze). Similarly, for an upward eye movement we expect the electrodes above the eyes to measure more positive after the movement than they were at center gaze.

=== Why qualitative evaluation?
For this project, we have only a qualitative evaluation of the simulation results. This is for a few different reasons. First, the lead field provided in the forward model contains scaled values, and does not give us actual voltages measured on the scalp. Thus, a suitable scaling factor would have to be found to bring the calculated lead field values up to the level of realistic scalp voltages. 

Next, the CRD simulation uses only two source points whereas the ensemble method uses several hundred sources. After summing the lead fields from these, the simulated data using the ensemble method is thus of a different order of magnitude than that simulated using the CRD model and these two are not directly comparable. 

For comparison with real data, we also searched the data recorded in a combined EEG-Eye Tracking study @gert_span_2022 in order to find saccades of similar end points and size. However, a direct comparison of our simulation with real data saccades was difficult as there were few comparable purely horizontal or vertical saccades to be found in the dataset.

Further, it is not possible to directly quantitatively compare the simulated values with real data without some further processing. The model is not yet as accurate as possible to reality (see @limitations). Although we have assumed a simplified scenario with both eyes looking in parallel directions (implying a stimulus located very far away from the subject), the stimuli in EEG studies are often presented on a screen in front of the subject, which means that the eye gaze directions are not perfectly parallel in a real study. To obtain simulation data corresponding to this condition, we would need to extend the simulation to allow setting different gaze direction vectors for each eye.

Hence, for the purpose of this project, we performed a simple qualitative evaluation by plotting the difference topographies and looking at the general trends at individual electrodes over a range of angles. Possible further work could be to adapt the model to give values in a comparable range to real data and then evaluate the characteristics relative to real data.

=== Difference Topo-plots
Observing the difference topographies, we can see that the difference plots from simulations via both, the ensemble method as well as the corneo-retinal dipole method match the expectation laid out above. 

As noted earlier, the leadfield magnitude ranges from the two methods are very different. A possible explanation of this is that the ensemble simulation is a sum of several hundred lead fields whereas the CRD simulation involves only two leadfields. 

=== Examining individual electrodes
We can also simulate the leadfields for a range of gaze angles and plot the individual electrode potential as the gaze direction varies. For this, we selected a subset of electrodes: some close to the eye (Fp, AF7/AF8, FFT9h/FFT10h, Nz; expected to show the largest effect from eye movements) as well as an electrode farther away (CPz - at the top of the head, expected to have only a slight change). The simulated gaze directions went from -40 to +40 degrees in the respective direction (horizontal or vertical).

#figure(
  image("../src/graphics/results/results_traj_ensemble_horiz.svg", width: 70%),
  caption: [Ensemble method horizontal movement, specific electrode potentials],
) 

#figure(
  image("../src/graphics/results/results_traj_ensemble_vert.svg", width: 70%),
  caption: [Ensemble method vertical movement, specific electrode potentials],
) 

#figure(
  image("../src/graphics/results/results_traj_crd_horiz.svg", width: 70%),
  caption: [CRD method horizontal movement, specific electrode potentials],
) 

#figure(
  image("../src/graphics/results/results_traj_crd_vert.svg", width: 70%),
  caption: [CRD method vertical movement, specific electrode potentials],
) 

In general, we see that the potentials at the individual eye-adjacent electrodes and the nose electrode go up as the positively charged cornea comes closer to them and go down as the CRD begins to point away from them again. 

== Limitations <limitations>

In the current published HArtMuT head model, the eyes are not considered as their own tissue type with their own conductivity, and the cornea source points are more densely spaced than the retina source points, causing a bias towards the points located at the front of the eye. Further, the eye shape described by the eye source points in the model is rather flattened - this is possibly due to deformation that takes place during the mapping step in the generation of the HArtMuT model. These limitations also carry over to our simulations.

Some of these limitations have been overcome: we collaborated with Nils Harmening to obtained a new eye model with source points more evenly spaced along a spherical surface. We have also discussed a further update to the model where the eyes have their own conductivity.

Another limitation is that we are not considering the effects due to eyelid closure or movement. In fact, the forward model considers the eyes to have the same conductivity as skin, i.e. the effect is as if the eyelid is closed during the eye movement and the eye is covered by the eyelid. Since the eyelid closure is understood to modify the strength of the corneo-retinal dipole, the ensemble method simulation for an open eyelid state will likely require different weights for the relative strength of the corneal and retinal potentials, and in the corneo-retinal dipole method dipole strength will have to be modified based on the degree of eye closure. The relative degree of contribution of retinal and corneal potentials is also unclear, and more investigation is needed to understand the exact manner in which the weights need to be distributed.

For the simulations and their evaluation, we only considered the scalp potentials at the start and at the end of the movement, rather than simulating the trajectories complete with intermediate points. The simulated data from the two methods and the data from real participants have different scales, since the forward model itself does not directly output scalp potentials in volts. We also considered purely horizontal and purely vertical movements, which is relatively uncommon in real data. 

Finally, during an eye movement, the muscles around the eyes contract or relax as required in order to rotate the eyeball in its socket. The muscle contractions are controlled by means of electrical currents running through the muscle fibers. Thus the scalp potentials due to an eye movement should consist not only of the potentials resulting from the change in eye charge distribution, but also those resulting from the muscle activations. However, we have not simulated the potentials resulting from electrical activations in the muscles themselves, although that is a possible task for future work in extending this project. 

== Outlook 

There are several possible opportunities to build further on this model. The forward model used can be updated to consider a separate tissue type for the eyes. We can simulate eye movements that are not just pure horizontal or vertical movements, and the next step thereafter could be to simulate a complete saccade across multiple time points, and check if the eye movement artefact observed in EEG recordings is reproduced by the model. For this, it would also be useful to incorporate the correct relative magnitudes for cornea and retina dipoles, as well as a simulation of the eye movement considering only the retina source points, with a possible comparison between these two simulations to see which version corresponds better to real data. Additionally, the magnitude of simulated data will need to be scaled to match realistic artefact signal magnitudes, so that when the simulated artefact signals are added to simulated brain signals, the overall simulation will be as close as possible to real data.  

Since our model can be extended to specify an independent gaze direction for individual eyes, we can also in future simulate a vergence movement, i.e., a movement where both eyes are looking at an object closer to the face and the individual eye gaze directions are non-parallel.

Once the basic model has been updated and tested for small eye movements in different directions, eye movements of larger magnitude can also be simulated, since most studies on eye movement artefacts focus on smaller saccades in the range of angles where the HEOG has a linear relationship to the angle of the saccade @plochl_combining_2012. 
The model can be adapted to account for eyelid effects, including their role during eye movements as well as the generation of blink artefacts, and to account for potentials generated due to muscle activation. Finally, the artefact simulation code can be converted into a software package that provides easy access to these simulation methods, or could be integrated into an existing simulation package like UnfoldSim @Schepers2025.


= Summary

The retina and cornea tissues of the eye are electrically charged, forming what is called the "corneo-retinal potential" which can be represented as an electrical dipole with its positive end towards the cornea and negative end towards the retina. This dipole moves in space during an eye movement and causes changes in measured potentials at EEG electrodes, and these changes contribute unwanted potentials or "artefacts" in the recorded EEG.

In this project, we presented the "ensemble" model of the human eye, represented by a set of electrical current dipoles ("source dipoles") placed at various locations on the surface of the eye, and the "corneo-retinal dipole" model (consisting of just one source dipole per eye placed at the eye centers).

Next, we simulated the scalp potentials ("lead fields") at the start and at the end of an eye movement. The eye movements considered were a pure horizontal and a pure vertical eye movement, defined by the start and end direction of eye gaze. We qualitatively evaluated the simulation for each of these two methods, by calculating the difference between the lead fields at the start and end of the movement, and plotting the scalp topography of this difference.

The difference topographies of the two methods agreed with the expectation that we had that the electrodes nearest the new position of the cornea would have a positive deflection and those nearest the new position of the retina would have a negative deflection. In addition, we simulated the difference potentials for different end gaze angles, and their trends at a few electrodes of interest near the eye also agreed with our prediction.

The model can be improved in the future by including more realistic conductivities for the eye tissues, by assigning different gaze directions to individual eyes, and by testing different relative magnitudes for cornea and retina potentials. The simulation output can be scaled to be comparable to real data, and an exact trajectory from real data can be simulated with the model and the two can be compared.