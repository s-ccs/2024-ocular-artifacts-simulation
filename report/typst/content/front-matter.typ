#import "../src/utils.typ": * 

/*#heading(outlined: false)[Danksagung]
#lorem(100) */
#heading(outlined: false)[Acknowledgements]
We would like to thank Nils Harmening for the discussion on the HArtMuT model and for the simulation of the new eye models with updated source positions and tissue conductivities based on the modifications we suggested. 


= Abstract
#abbr.l("EEG") recordings usually contain artefacts arising from various biological processes like muscle activations, eye movements, and blinks, along with other noise from non-biological sources. These artefacts and noise contaminate the measured data, thus making it difficult to analyze the brain activity measured at the scalp by the EEG electrodes. Simulation of data can be useful in order to help develop and test toolboxes used for analyzing recorded EEG signals. Although EEG data simulation from brain sources has already been implemented, realistic simulation of artefacts is still lacking. In this project, we discuss the principle underlying the origin of the eye movement artefact, namely the presence of standing potential differences in the eyeballs), present two models of representing these potentials, and demonstrate a method of simulating the measured scalp topographies by using both of these models. To evaluate the simulation, we plotted the topography of the difference between the scalp potentials at the start and end of an eye movement, and compare this qualitatively with the prediction based on the conceptual idea of the origin. The results matched our initial expectations, however further investigation is necessary. This model can be refined to more accurately model the source potentials, and can be further developed to account for other types of artefact sources. Eventually, the code for simulating artefacts can be provided as a software package for easy use by EEG researchers. 

