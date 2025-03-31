#import "@preview/abbr:0.2.3"
#import "@preview/big-todo:0.2.0": *

#let name-with-titles = p => {
  if "pre-title" in p {
    [#p.at("pre-title", default: "") ]
  }
  p.at("name", default: "")
  if "post-title" in p {
    [ #p.at("post-title", default: "")]
  }
}

// prose citation helper function (from https://github.com/typst/typst/issues/2716#issuecomment-1817870741)
// usage: #pc[@refname]
#let pc = (citation) => {
  set cite(form: "prose")
  citation
}

// inline todo helper function
// usage: #ilt("todo text") or #ilt[todo text]
#let ilt = (text) => {
  todo(text, inline: true)
}