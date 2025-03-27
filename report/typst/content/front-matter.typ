#import "@preview/abbr:0.2.3"
#import "@preview/big-todo:0.2.0": *

/*#heading(outlined: false)[Danksagung]
#lorem(100) */
#heading(outlined: false)[Acknowledgements]
We would like to thank Nils Harmening for the discussion on the HArtMuT model and for the simulation of the new eye models with updated source positions and tissue conductivities based on the modifications we suggested. 


= Abstract
#abbr.l("EEG") recordings usually contain artefacts arising from various biological processes like muscle activations, eye movements, and blinks, along with other noise from non-biological sources. These artefacts and noise contaminate the measured data, thus making it difficult to analyze the brain activity measured at the scalp by the EEG electrodes. Simulation of data can be useful in order to help develop and test toolboxes used for analyzing recorded EEG signals. Although EEG data simulation from brain sources has already been implemented,  simulation of artefacts is still lacking. In this project, we discuss two models of the eye that can be used for simulation of eye movement artefacts, and demonstrate a method of simulating the measured scalp topographies by using both of these models. To evaluate the simulation, we plot the topography of the difference between the scalp potentials at the start and end of an eye movement, and compare this qualitatively with that of a similar eye movement obtained from real data. This model can be refined to more accurately depict the measured artefact potentials, and can be further developed to account for other types of artefact sources. Eventually, the code for simulating artefacts can be provided as a software package for easy use by EEG researchers. 
#todo("Rewrite and rephrase; talk about results as well", inline: true)

