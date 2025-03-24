// #import "@preview/arkheion:0.1.0": arkheion, arkheion-appendices
#import "@preview/abbr:0.2.3"
#import "template/thesis.typ": *
#import "@preview/big-todo:0.2.0": *
#show: general-styles

#show: thesis.with(
  lang: "en",
  title: (en: "Eye movement artefact simulation in EEG using the Ensemble and
  Corneo-Retinal Dipole methods"),
  subtitle: (:),
  thesis-type: (en: "Research Project"),
  academic-title: (en: "Master of Science"),
  curriculum: (en: "Information Technology (INFOTECH)"),
  author: (name: "Maanik Marathe", student-number: 3644269),
  // advisor: (),
  advisors: (
    (name: "Benedikt Ehinger", pre-title: "Jun.-Prof. Dr."),
    (name: "Judith Schepers"),
  ),
  assistants: (),
  reviewers: (),
  keywords: ("Lorem Ipsum"),
  font: "DejaVu Sans",
  date: datetime.today(),
)

#set cite(style: "american-psychological-association")
#show link: underline

#show: flex-caption-styles
#show: toc-styles
#show: front-matter-styles

#include "content/front-matter.typ"
#outline()
#show outline: set heading(outlined: true)
#outline(title: [List of Figures], target: figure.where(kind: image))
#outline(title: [List of Tables], target: figure.where(kind: table))

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