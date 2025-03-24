#import "@preview/abbr:0.2.3"
#import "@preview/big-todo:0.2.0": *

= Introduction

#abbr.l("EEG") is a method of recording the electrical activity of the brain via a set of electrodes, usually placed on the scalp and/or the skin surface of the subject. The data thus gathered is later analysed in order to understand more about the inner working of the brain. During an EEG recording, each of the electrodes measure the electrical potential at their respective locations, relative to the potential at some other point (called the reference). That is, they measure the potential difference between these two points @hari_meg-eeg_2017. 

== Artefacts in EEG

Ideally, the recorded EEG data would contain just the scalp potentials resulting from brain activity. However, other biological processes occurring in the body also involve electrical activity, causing changes in the electrical potential measured by the EEG electrodes. For example, the muscles of the head, face, and neck are electrically activated when moving the head or eyes, when talking, etc. The electrical activity during the heartbeat generates a measurable potential as well (the electrocardiogram). The movement of the eye itself also causes a change in the measured scalp potential, as does the action of blinking. These effects are much larger in magnitude than the potentials recorded from the brain activity, and therefore cause problems during analysis since they eclipse the brain-related data. In addition, there are also a number of non-biological sources of noise in the EEG signal, such as power line noise (from the alternating current electrical power supply) or slow drifts or noise present at a certain problematic electrode.

The presence of these undesirable potentials (or artefacts) in the data needs to be minimised in order to have a clean signal containing as far as possible only the measured brain activity. This can be done either by avoiding the artefacts at the time of recording (for example, by asking the subject to move as little as possible during the recording), or removing the artefacts after the data has been recorded. The simplest way to do this is by manual inspection of the data by an expert, marking the contaminated sections of data and removing those sections before analysis. However, this is difficult, time-consuming and results in less data available for analysis. Instead, various automated methods have been developed for removing artefacts and repairing the contaminated trials, of which two popular examples are #abbr.a("ICA") (a Blind Source Separation technique) and linear regression. 

== Simulation of EEG data

For analysing recorded data, software implementations of data analysis and artefact correction methods are provided in the form of packages, such as in autoreject @jas:hal-01313458, EEGLAB @delorme_eeglab_2004, MNE @larson_mne-python_2024, Unfold.jl @ehinger_unfoldjl_2025.  Simulating EEG data is useful when developing and testing such software tools. In particular, it is useful to be able to specify a particular ground truth for the simulation, in order to better evaluate the results of applying the analysis methods on the simulated data. Software packages like SEREEGA @krol_sereega_2018, MNE @larson_mne-python_2024, UnfoldSim.jl @Schepers2025 provide support to simulate EEG data from brain sources and to add different kinds of random noise. However, realistic simulation of biological artefacts like eye movements is not yet available, and this project is an effort to implement such a simulation, with a view to eventually also provide it as a software package. 
// #todo("check for if they at all simulate bio. artefacts, or if they just simulate noise", inline: true)

== Aim and scope of this project

In this project, we focus on simulating eye movements, specifically on purely horizontal and vertical movements. An "eye movement" here is defined as rotation of the eyeball in order to change the gaze direction from a starting point "A" to an ending point "B". The other aspects of an eye movement, like the accompanying eyelid movement and the activations of the muscles in order to rotate the eye, are not considered in our current model. We also assume fast eye movements ("saccades") performed in order to change from gaze direction A to gaze direction B. 
// #todo("define saccades", inline: true)

We first describe a method of simulating the scalp potentials for a particular eye position. Then, we simulate the scalp voltages at the start and at the end of an eye movement. Here, we demonstrate using two possible models of the eye: one biologically-motivated, using many electrical source points in each eye, and one using just one source point per eye (both of these models will be explained in a later section). Next, we calculate the difference between the two lead fields at the start and end of the eye movement, and plot the scalp topography of this difference.  We also compare the results of these simulations with the same difference-topography of a saccade found in a real EEG recording. 

This project is meant as a first proof-of-concept of the simulation method that we describe, and we have only simulated the start and end points 'A' and 'B' of the saccades, without including the intermediate steps. A more detailed discussion of this and other aspects can be found under the 'Limitations' and 'Outlook' sections of this report.

The code for this project was written in Julia; however, the steps of the simulation are explained in a general manner and it should be possible to implement these in a different programming language as well.

= Characteristics, origin, and modelling of eye artefacts

== Eye artefacts in EEG
// add images of what the different eye artefacts look like: EM, blink, ... ; talk about prev studies where they looked at eye artefacts and write what they concluded in short. 
The main categories of eye-related EEG artefacts are eye movements, blinks, and eye muscle activation. The figure shows what these artefacts look like in recorded EEG.

((figure: EEG plot showing artefacts))

// #todo("check - is it okay to directly reuse diagrams from sources (& cite them of course)? e.g. Primer fig. 8.4 shows eye charges & dipole, and the book also has other diagrams showing different artefacts.", inline:true)

Each of these artefacts arises due to a physiological aspect of the corresponding organ. Eye muscle artefacts are generated due to activation of the muscles used in order to move the eyes; // #todo("citation", inline: true)
eyeball rotations involve movement of the eyeball which has its own electrical charge distribution;
//#todo("citation", inline: true); 
and blinks are thought to result from the interaction between the eyelid and the charged surface of the cornea at the front of the eyeball //#todo("citation", inline: true)
. For studying eye artefacts, the #abbr.a("EOG") calculated from the electrodes placed near the eyes 
//#todo("define EOG more precisely", inline: true) 
is also often examined, as these electrodes are located closest to the eyes and therefore record the strongest eye-related potentials.

We will now discuss the origins of eye movement artefacts in some more detail.

== Representation of electrical potential differences as current dipoles

In general, electric potential differences present in human tissues can be represented with the help of current dipoles placed at different points in the space occupied by the tissues @malmivuo_bioelectromagnetismprinciples_1995. When a current dipole is placed in a volume conductor, it creates an electrical potential field around it. The resulting potential at any point in space can be described by a set of three vectors in the three coordinate directions, and this is known as the "lead vector" or "leadfield". For a specific orientation of the source dipole, the resultant potential can be calculated by multiplying the lead vector by the source dipole's orientation.

#figure(
  image("../src/graphics/fig source dipole.png", width: 30%),
  caption: [Current dipole representing a potential difference.],
) <source_dipole>

== Eye structure and corneo-retinal dipole (CRD)

The eye is composed of various types of tissue (e.g. cornea, retina, sclera, choroid, and so on), and certain sections of the eyeball are also filled with fluid (aqueous and vitreous humour). Each of these tissues and fluids have their own electrical properties, including their electrical conductivity, which influences how they conduct electrical potential, as well as any inherent charge distributions caused due to properties of the cells making up the tissue. When the subject in an EEG recording changes their gaze direction, the eyeball rotates in its socket and the charged tissues also accordingly move in space. This change in the spatial distribution causes a change in the resultant electric potential measured at each of the scalp electrodes, and this change is visible in the EEG recordings as an eye movement artefact @mowrer_corneo-retinal_1935. For example, in a movement going from centre gaze (looking straight ahead) to looking to the left, we would expect the electrodes on the left to measure a more positive potential after the movement than before.

Previous studies like @mowrer_corneo-retinal_1935 and @matsuo_electrical_1975 showed that an intact eyeball is required in order to see the EOG effects due to eye movements. The retina and cornea have each been shown to have a potential difference between their inner and outer surfaces @lins_ocular_1993-1, with the inner side of the retina being positive relative to the outer side and the outer side of the cornea being positive relative to the inner side. 
// #todo("reference", inline: true)
This leads to an overall potential difference between the front and the back of the eye, which is often approximated as a single electrical current dipole with its positive end towards the cornea at the front, following the axis of gaze @plochl_combining_2012. This single dipole is called the "corneo-retinal potential" @mowrer_corneo-retinal_1935 or "#abbr.a[CRD]"
// #todo("reference; steinberg_1983 - check actual ref in lins.", inline: true) 
and is a basis of the model of eye movements in existing studies (@berg_dipole_1991, ((ref))).
// #todo("add ref", inline: true)). 


// #todo("add figure simple CRD (or point to the figure from one of the ref.s e.g. primer? see other todo note above)", inline: true)

((figure from M/EEG primer showing eye charges and CRD in the same image - can we actually include this?))

#todo("add some info about sliding electrode effect (but mention that it is not directly relevant to this project rn)", inline: true)

== Modelling eyes and eye movement artefacts

// source modelling - explain from primer pg.35 ch.3

A common approach when modelling eye movement and blink artefacts in EEG is to consider a certain set of source dipoles placed in or near the eyes, varying their position and orientation such that their contribution explains as much of the artefact as possible (in terms of scalp topography data resulting from that source dipole). For example, @berg_dipole_1991 considered "equivalent dipoles" representing the effect of the difference between the CRD position and orientation at the start versus at the end of the movement. 

If instead we directly consider the concept of the corneo-retinal dipole, it is also possible to represent the CRD itself as a single source dipole placed in the eye (say, at the centre) and oriented in the direction of eye gaze. In order to simulate an eye movement, this dipole can be reoriented according to the gaze direction at each point in time, and the corresponding scalp topography at each time point can be calculated. 

Alternatively, an even more detailed model can be created using the electric potentials present 
// (#todo("check the exact technical term w/ src, for "standing potentials", inline: true)) 
in the eye tissues. These can be represented in the form of "Equivalent Current Dipoles", as done in @harmening_hartmutmodeling_2022 (further described in a section below). The equivalent current dipoles should each have an orientation according to the direction of their tissue potentials: dipoles placed in the cornea point outwards, since the cornea is more positive on the outside of the eyeball, and similarly the retina dipoles point inwards. 


#figure(
  image("../src/graphics/fig charges dipoles representation.png", width: 100%),
  caption: [Eye model: the charges in the eye, and the representation using source dipoles.],
) <charges_representation>

The most detailed method allows us to try to derive the EEG scalp potentials from first principles starting from the charge distribution of the eyes. Additionally, since the concept of the corneo-retinal dipole is widely used in the literature, it would be interesting to compare the data simulated via this approach to that from the highly-detailed model with many source dipoles. Therefore, in the simulation phase of this project, we will be using the above two models, which we will call the "ensemble" model and the "CRD" model respectively.

= Simulation of eye movements

// optionally, split the  'previous studies' section and put prev simulation approaches here. then add a section about our approach and nest the hartmut section under it. Or have a section about forward model in general. Or put it in appendix?

== EEG head model

// #todo("explain head model from m/eeg primer ch3 pg 35 & forward model specifically", inline: true)
In EEG research, a 'head model' describes the head and the biological tissues in it as a conducting medium that conducts electrical potentials. The simplest head model is a homogeneous sphere made out of the same material throughout. In reality, different tissues have different conductivities, and the head model can be improved by modifying this basic model to have different sections each corresponding to their own tissue type and having the respective conductivity. Using the concept of a head model and that of using source dipoles to represent electrical activity in the brain, muscles, or eyes, we can build a model consisting of a set of source dipoles placed at different locations in the head. We can further calculate the resulting potentials due to each of these measured at different locations on the head surface (i.e. the scalp), and combine the two - this is known as a forward model @malmivuo_bioelectromagnetismprinciples_1995.

The #abbr.a("HArtMuT") @harmening_hartmutmodeling_2022 is one such forward model. It consists of source dipole locations placed within the brain as well as at the surface of the eye and within the muscles, along with lead fields for sensors (electrodes) at a set of 227 positions on the scalp surface. In this project, we have used the eye-surface source locations from this forward model and calculated the scalp topographies via the corresponding lead fields provided by it.

Relevant for us, the source locations in HArtMuT belonging to the eye fall into two categories: labelled either "Cornea" or "Retina/Choroid/Sclera". There are sources placed in each individual eye, as well as a set of symmetric sources in a vertical plane between the two eyes, that produce the same effect as summing the lead fields of corresponding individual eye points. We decided to use individual eye source points in order to stay as close as possible to the biological model, as well as to have independent control over the points of each eye, giving us more flexibility during simulation. 

// #todo("fix description - not just corresponding but collaborating. also that our discussion led to an improvement e.g. using different tissue type for eyes.") 
While working on this project, we corresponded with Nils Harmening, one of the authors of the original paper and developers of the HArtMuT model, to better understand how the model was created. We also discussed our ideas for improved source locations in order to have sources and lead fields that were better suited to our purpose. He then calculated an updated "eye"-model with the eye sources having the new source locations. The main differences from the published HArtMuT model are that the eye sources in the eye model are distributed in a more spherical shape ((and that the retina and cornea source types are placed similarly densely on the surface of the eye -> if we end up using the uniform model)). This intermediate eye-model is currently unpublished and still under development, and may be further adapted in future based on further discussion.

((placeholder: figure old vs. new eye model: hartmut headmodel 3d plot showing eye separate and combined sources;  figure eyemodel 3d plot with rounder eyes))


== Previous studies on eye movement topography and simulation

// When the eye gaze rotates towards a particular direction, the cornea moves closer to the electrodes in that direction and the retina moves away from them. Since the cornea is positively charged relative to the retina, the electrodes near the new cornea position show a positive deflection and those away from it show a negative deflection. 

((small summary of results from Plöchl et al. - general + about small/large Horiz./vert. movements))

Some previous studies have also involved simulating eye movement artefacts and adding them to simulated EEG signals. @barbara_monopolar_2023 extended a battery model of the eye, and simulated eye movements where both eyes were fixated on the same onscreen target (i.e., not looking in parallel gaze directions, but rather focused on one object closer to the face).  ((the original paper talking about the battery model is not easily found - need to search for this to understand more in detail))

@gawne_effect_2017 and @kierkels_model-based_2006 also simulated eye movements, however they worked with #abbr.pll("MEG"), which are related to but different from EEG.  ((to be described in more detail))

== Method for simulating lead field using the forward model

//#todo("Flowchart/block diagram of steps")
((flowchart of our method?))

// talk about one specific gaze direction.
// In our many-dipoles approach, 
We first introduce the concept of a gaze direction vector. The "gaze direction vector" for an eye is a vector in the same coordinate system as the head model, having unit length and pointing from the centre of the eye in the direction of the object that the subject is looking at. We assume a symmetric eyeball around the axis described by the gaze direction, and thus this gaze direction vector will always pass through the centre of the cornea. When the viewed object is sufficiently far away from the subject, we can assume that the gaze directions of both eyes are parallel to each other. Thus the individual gaze directions can be described by a single vector parallel to both of these. The location of this common gaze direction vector is not important as it only describes a direction. 

We then calculate the EEG topography resulting from both eyes looking in this direction. 

For the CRD method, we do this by using a single source point placed at the centre of the eyeball with an orientation parallel to the gaze direction. The leadfield for this single point gives the scalp topography for that eye, and for the overall scalp topography we add the leadfields of both of the eye centre dipoles.

For the ensemble method, we make use of the set of HArtMuT head model source points with retina and cornea labels. Each source point has a fixed position provided in the head model, and we calculate an orientation vector pointing outwards in the direction from the centre of the respective eyeball to the source point. 

The intrinsic eye gaze direction in the model is taken as the average of the cornea-point orientations of that eye, and we can define the angular extent '\u{03B8}' of the cornea to be the maximum value of the angle difference between the individual cornea orientations and this gaze direction; that is, the angle difference of the "cornea"-labelled point that is farthest from the intrinsic gaze direction.

// ((placeholder - diagram - eye gaze coordinate system (wrt front gaze=0) and corresponding cornea angle. Cornea & retina coloured. ))

Although the eyeball rotates when the subject changes their gaze direction, the cornea does not move relative to the gaze direction, i.e. the relationship between the cornea point orientations and the current gaze direction vector remains the same at all times. Thus, for any given gaze direction, we can find the angle between the gaze vector and the calculated orientation vector at each source point. If this angle is less than the maximum cornea angle '\u{03B8}', we can label that point as "retina" type, and if not, we label it as "retina" type.

#figure(
  image("../fig ret cor theta comparison.png", width: 50%),
  caption: [Comparison between retina and cornea source orientations, gaze direction, and maximum cornea angle.],
) <charges_representation>

// #figure(
//   image("../src/graphics/fig ret cor source dipoles.png", width: 100%),
//   caption: [Source dipoles placed in the retina and cornea, and the change in spatial distribution of these dipoles from the start to the end of an eye movement. (top-down view)],
// ) <retina_cornea_source_dipoles>

We further give each source point a weight (+1 or -1, i.e. a sign) to represent the orientation of the actual source dipole relative to the orientation vector. As originally calculated, the orientation vector when placed at the source point will represent a dipole pointing outwards, and giving a source point a negative weight value represents a dipole pointing inwards. Thus, the cornea and retina dipoles are given weights of +1 and -1 respectively. The scalp topography for a particular gaze vector is then calculated by multiplying the lead field of each source point by the source orientations and the weightage. 

Finally, for both models, the EEG effect of an eye movement from a gaze direction A to a gaze direction B can be calculated by simulating the scalp topography for both and then taking the difference (B-A). 

// A sample simulation of a left-to-right horizontal movement from -15° to +15° (relative to a central fixation point and in the same horizontal/vertical line respectively) is shown below. 
// ((todo: add a vertical movement from --- to ---)) 


== Assumptions and  simplifications

Certain assumptions have been made while developing this model. Firstly, we have assumed each eye to be perfectly spherical, although in reality the cornea surface bulges out slightly at the front, and the eyes are slightly deformed in other directions as well (as seen in the eye source points in the published HArtMuT head model). Next, we assume that the cornea tissue is symmetrically distributed around the axis pointing from the centre of the eye outwards towards the direction of gaze, and thus can be considered to lie on the part of the eye surface that falls within a conical region extending from the eye centre in the direction of gaze. We also assume that during an eye movement, the eye only rotates about its centre and is not translated (although some studies like @moon_positional_2020 show otherwise). Further, some sources indicate that the magnitude of the potentials in the eye changes over time, in particular due to illumination .
// #todo("ref - see @plochl_combining_2012 pg. 17", inline: true). 
This is not accounted for in our current model.

The current version of the HArtMuT model considers the eyes as part of the skin rather than as a separate tissue type with its own conductivity. This also results effectively in a "closed eyelid" state. Various sources 
// #todo("ref", inline: true) 
have described the effect of a closing eyelid as modulating the electric potentials of the cornea ("sliding electrode" effect) 
// #todo("ref - see @plochl_combining_2012 for listed sources", inline: true)
, and future simulations with our model could take this into account to remove the "closed eyelid" effect. 

// == Two kinds of simulations: CRD method, many-dipoles method 
// // #todo("rename?", inline: true) 

// // describe how we used the prev simulation approach for each of these models.





= Results

We carried out two kinds of simulations: First, using our model of multiple retinal and corneal source dipoles; and second, simulating the CRD as a single dipole at the centre of each eye (resultant dipole method). 
We chose to simulate an eye movement from the centre fixation point to a point 15° to the left (for horizontal movement).


The topographies obtained via each of these methods are shown in the figure below. The topography for a similar movement from a real dataset is also shown alongside the simulations. 

#figure(
  image("../src/graphics/fig 2 methods topo l-r.png", width: 70%),
  caption: [Difference topographies resulting from simulation of the ensemble model and the CRD model],
) <simulation_horiz_topo>

#figure(
  image("../fig em l-r real one.png", width: 35%),
  caption: [Leftward eye movement topography from real data],
) <realdata_horiz_topo>


The results of the biological and CRD simulations agree with the conceptual idea - the difference topographies are positive on the left side and negative to the right when the cornea moves from the centre to the left and the retina accordingly from the centre to the right. This is also similar to the results from @plochl_combining_2012. 

#todo("add figures from plöchl paper for comparison", inline: true)
#todo("real data topo - generate a png in matlab rather than taking a screenshot. Add heading etc", inline: true)

= Discussion

== Evaluation

For the scope of this project, we have only a qualitative evaluation of the simulation results. This is for a few different reasons. First, the lead field provided in the forward model contains scaled values, and thus does not directly correspond to actual voltages measured on the scalp. Next, the CRD simulation uses only two source points whereas the ensemble method uses several hundred sources. After summing the lead fields from these, the simulated data is thus of a different order of magnitude than that of the CRD model. Further, although we have assumed a simplified scenario with both eyes looking in the same direction (implying a stimulus located far away from the subject), the stimuli in EEG studies are presented on a screen in front of the subject, which means that the eye gaze directions are not perfectly parallel. Finally, there are certain limitations arising from the forward model used, which mean that the model is not yet as accurate as possible to reality and so the actual values yielded by the simulation are not directly comparable with the values from real data.   

== Limitations 

In the current published HArtMuT model, the eyes are not considered as their own tissue type with their own conductivity in the head model, and the cornea source points are more densely spaced than the retina source points, causing a bias towards the points located at the front of the eye. Further, the eye shape described by the eye source points in the model is rather flattened - this is possibly due to deformation that takes place during the warping to the NYHead model 
// #todo("check exact wording of this", inline: true)
. These limitations also carry over to our simulations.
However, during our discussions with Nils Harmening, we obtained a new eye model with source points more evenly spaced along a spherical surface, and another model calculated considering the conductivities of the eye tissues themselves instead of modelling them as skin as was done in the published model. In future, the simulation process we have described here could be carried out using these updated models. 
// #todo("update this if using the spherical/water model", inline: true)

// #todo("do we just refer to him as 'Nils' hereafter?", inline: true)

Another limitation is that we are not considering the effects due to eyelid closure or movement. According to @iwasaki_effects_2005, the eyelids move along with eye movements, and greatly influence the frontal EEG observed during vertical eye movements. @lins_ocular_1993 also describes a "rider artefact" 
// #todo("describe rider artefact", inline: true)
. We are not simulating either of these effects at this stage. In fact, the forward model considers the eyes to have the same conductivity as skin, i.e. it simulates the state as if the eyelid is closed during the eye movement and the eye is covered by the eyelid. Since the eyelid closure is thought to modify the strength of the corneo-retinal dipole, the simulation for an open eyelid state will have to be done in a different manner where eyeballs have their own conductivity instead of being considered part of the skin. 

For the eye movement itself, we have only considered the scalp potentials at the start and at the end of the movement, rather than simulating the trajectories complete with intermediate points. We also considered purely horizontal and purely vertical movements, which is relatively uncommon in real data. 

The magnitude of the simulated scalp potentials also represents a scaled version of the actual scalp potentials measured in EEG, since the forward model itself has scaling built-in. #todo("fix weird wording", inline: true) Thus, to simulate values in a realistic range, some calculations must be done in order to scale the simulated potentials to match the values recorded in real data. 

In addition, we have assumed equal magnitudes for both cornea and retina dipoles, but it is possible that the magnitudes of the potential difference in the actual tissue are not equal, and this could in turn be reflected in the weights given to the source points when their labels are updated. 
Further investigation into the magnitudes of the cornea and retina potentials is therefore required. There is in fact some difference of opinion on the charge of the retina @lins_ocular_1993 and whether or not it contributes to the corneo-retinal dipole: @berg_dipole_1991 and @plochl_combining_2012 do not mention the role of the cornea at all when talking about the CRD. However, for our simulations we have chosen to include the model of the cornea with its dipoles pointing outwards, as assumed in the design of the HArtMuT model @harmening_hartmutmodeling_2022. 

Finally, during an eye movement, the muscles around the eyes contract or relax as required in order to rotate the eyeball in its socket. The muscle contractions are controlled by means of electrical currents running through the muscle fibres. Thus the scalp potentials due to an eye movement consist not only of the potentials resulting from the change in eye charge distribution, but also those resulting from the muscle activations. However, we have not simulated the potentials resulting from electrical activations in the muscles themselves, although that is a possible task for future work in extending this project. 
// bene feedback: deformation of eyes in hartmut model is mostly a modelling failure rather than depicting reality - could come from the warping process - see Nils email discussion. 

== Outlook 

There are several possible opportunities to build further on this model. The forward model used can be updated to the one having more evenly spaced source points and considering a separate tissue type for the eyes. We can simulate eye movements that are not just pure horizontal or vertical movements, and the next step thereafter could be to simulate a complete saccade across multiple time points, and check if the eye movement artefact observed in EEG recordings is reproduced by the model. For this, it would also be useful to incorporate the correct relative magnitudes for cornea and retina dipoles, as well as a simulation of the eye movement considering only the retina source points, with a possible comparison between these two simulations to see which version corresponds better to real data. Additionally, the magnitude of simulated data will need to be scaled to match realistic artefact signal magnitudes, so that when the simulated artefact signals are added to simulated brain signals, the overall simulation will be as close as possible to real data.  

Since our model includes the possibility to give an independent gaze direction for individual eyes, we can also in future simulate a vergence movement, i.e., a movement where both eyes are looking at an object closer to the face and the individual eye gaze directions are non-parallel.

Once the basic model has been updated and tested for small eye movements in different directions, eye movements of larger magnitude can also be simulated, since most studies on eye movement artefacts focus on smaller saccades in the range of angles where the HEOG has a linear relationship to the angle of the saccade @plochl_combining_2012.
// #todo("ref", inline: true) ). 
The model can be adapted to account for eyelid effects, including their role during eye movements as well as the generation of blink artefacts, and to account for potentials generated due to muscle activation. Finally, the artefact simulation code can be converted into a software package that provides easy access to these simulation methods. Such a package could be integrated into a software toolbox like UnfoldToolbox.jl in the form of e.g. a package called UnfoldArtefacts.jl. 

// todo: citation for unfoldtoolbox.jl

// do we mention B&S at all??

// more evenly spaced src points in eyemodel (check if latest model from nils is already so)

// different tissue type for eyes; rounder eyes; 

// simulating trajectories to get a better idea of the actual EEG data simulated and better compare with real data. Can see it in time-series and/or ICA and see if it has characteristics similar to real EM, e.g. ICA component.

= Summary

In this project, we present a model of the human eye represented by a set of electrical current dipoles and provide a method to simulate the scalp topography for any given gaze direction of the eye. We simulate the scalp topography of a simple pure horizontal and a pure vertical eye movement by finding the difference in the lead field from the start time point of the movement to the end. We discuss some limitations of the approach described, give an outlook on further directions to work on, and suggest eventually creating a software package to allow researchers to simulate eye artefacts according to their required specifications.

// #todo("All citations - see how to remove brackets where required by sentence structure")

= Acknowledgements

We would like to thank Nils Harmening for the discussion on the HArtMuT model and for the simulation of the new eye models with updated source positions based on the modifications we suggested. 