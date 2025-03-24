/*#heading(outlined: false)[Danksagung]
#lorem(100)
#heading(outlined: false)[Acknowledgements]
#lorem(100)*/
#import "@preview/abbr:0.2.3"
#import "@preview/big-todo:0.2.0": *

#abbr.make(
  ("EEG", "Electroencephalography"),
  ("CRD", "Corneo-retinal dipole"),
  ("ICA", "Independent Component Analysis"),
  ("EOG", "Electro-oculogram"),
  ("HArtMuT", "Head Artifact Model using Tripoles"),
  ("MEG","Magnetoencephalogram","Magnetoencephalograms"),
)

= Abstract

#abbr.l("EEG") recordings usually contain artefacts arising from various biological processes like muscle activations, eye movements, and blinks, along with other noise from non-biological sources. These artefacts and noise contaminate the measured data, thus making it difficult to analyse the brain activity measured at the scalp by the EEG electrodes. Simulation of such artefacts can be useful in order to help develop and test toolboxes used for analysing recorded EEG signals. In this project, we discuss two models of the eye that can be used for simulation of eye movement artefacts, and demonstrate a method of simulating the measured scalp topographies by using both of these models. We plot the topography of the difference between the scalp potentials at the start and end of a saccade, and compare this with that of a saccade obtained from real data. This model can be further developed to account for other types of artefact sources, and can eventually be provided as a software package for easy use by EEG researchers. 

