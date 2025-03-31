# **Research project:** Simulation of Eye Movement Artefacts in EEG, introducing the Ensemble and Corneo-Retinal Dipole methods
**Author:** *Maanik Marathe*

**Supervisor(s):** *Jun.-Prof. Dr. rer. nat. Benedikt Ehinger, Judith Schepers, M.Sc.*

**Year:** *2024*

## Project Description
Understanding the origin of eye movement artefacts in EEG and simulating eye movements using a forward model of the head.

## Bibliography
See `report/typst/bibliography.bib`.

## Instruction for a new student
- The code for this project is mainly in the form of Pluto.jl notebooks.
- High-level simulation: The notebook `notebooks/eval.jl` contains all the necessary steps to simulate a pure horizontal or pure vertical eye movement. To select the horizontal or vertical option for simulation, set the value of the variables `gazevectors` and `sacc_direction` accordingly. E.g., `gazevectors = gazevectors_horiz; sacc_direction = "horiz"` for horizontal gaze movement.
  - Note that CairoMakie is required for exporting the 2D plots as images, but WGLMakie is required for viewing and interacting with the 3D plots of the eye model source locations and orientation vectors.
  - The points of interest in the notebook are marked with "@NOTE" and roughly describe the steps in the simulation.
- For a more in-depth look into the exact steps of the simulation, see `notebooks/simulate.jl`.
- To explore the HArtMuT model in more detail, see `notebooks/hartmut-playground.jl`.
- Utility functions are defined either in the notebook file itself, or in `scripts/utils.jl` (included in the Pluto notebook using Revise.jl). If you make a change in `scripts/utils.jl`, re-run the cell containing `@use_file include("../scripts/utils.jl")` so that the updates are included in the notebook. 
- If the 2D/3D plot cells run but the plots are not visible, try running `WGLMakie.Page()` and then re-running the plotting cells.

## Overview of Folder Structure 

```
│projectdir          <- Project's main folder. It is initialized as a Git
│                       repository with a reasonable .gitignore file.
│
├── report           <- **Immutable and add-only!**
│   ├── thesis       <- Final Thesis PDF
│   |  ├── typst     <- Files for creating the report using Typst
│   ├── talks        <- PDF of the Final-Talk
|
├── _research        <- WIP scripts, code, notes, comments,
│   |                   to-dos and anything in an alpha state.
│
├── plots            <- All exported plots go here, best in date folders.
|   |                   Note that to ensure reproducibility it is required that all plots can be
|   |                   recreated using the plotting scripts in the scripts folder.
|
├── notebooks        <- Pluto, Jupyter, Weave or any other mixed media notebooks.*
│
├── scripts          <- Various scripts, e.g. simulations, plotting, analysis,
│   │                   The scripts use the `src` folder for their base code.
│
├── src              <- Source code for use in this project. Contains functions,
│                       structures and modules that are used throughout
│                       the project and in multiple scripts.
│
├── test             <- Folder containing tests for `src`.
│   └── runtests.jl  <- Main test file
│   └── setup.jl     <- Setup test environment
│
├── README.md        <- Top-level README. A fellow student needs to be able to
|   |                   continue your project. Think about her!!
|
├── .gitignore       <- focused on Julia, but some Matlab things as well
│
├── (Manifest.toml)  <- Contains full list of exact package versions used currently.
|── (Project.toml)   <- Main project file, allows activation and installation.
└── (Requirements.txt)<- in case of python project - can also be an anaconda file, MakeFile etc.
                        
```
