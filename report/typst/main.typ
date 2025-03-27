#import "@preview/abbr:0.2.3"
#import "template/thesis.typ": *
#import "@preview/big-todo:0.2.0": *
#import "src/utils.typ": pc
#show: general-styles

#show: thesis.with(
  lang: "en",
  title: (en: "Simulation of
eye movement artefacts in EEG"),
  subtitle: (en:"using the Ensemble and
Corneo-Retinal Dipole methods"),
  thesis-type: (en: "Research Project"),
  academic-title: (en: "Master of Science"),
  curriculum: (en: "Information Technology (INFOTECH)"),
  author: (name: "Maanik Marathe", student-number: 3644269),
  advisors: (
    (name: "Benedikt Ehinger", pre-title: "Jun.-Prof. Dr."),
    (name: "Judith Schepers"),
  ),
  assistants: (),
  reviewers: (),
  keywords: (),
  font: "DejaVu Sans",
  date: datetime.today(),
)

#set cite(style: "american-psychological-association")
#show link: underline

#show: flex-caption-styles
#show: toc-styles
#show: front-matter-styles

#abbr.make(
  ("EEG", "Electroencephalography"),
  ("CRD", "Corneo-retinal dipole"),
  ("ICA", "Independent Component Analysis"),
  ("EOG", "Electro-oculogram"),
  ("HArtMuT", "Head Artifact Model using Tripoles"),
  ("MEG","Magnetoencephalogram","Magnetoencephalograms"),
)
#include "content/front-matter.typ"
#outline()
#show outline: set heading(outlined: true)
#outline(title: [List of Figures], target: figure.where(kind: image))
// #outline(title: [List of Tables], target: figure.where(kind: table))
#abbr.config(space-char: sym.space.nobreak)
#abbr.list()
#show: main-matter-styles
#show: page-header-styles

#for value in (1,) {
  include "content/chapter_"+str(value)+".typ"
}
//#include "content/test.typ"

#show: back-matter-styles
#set page(header: none)

#bibliography("bibliography.bib", style: "american-psychological-association")

