#let name-with-titles = p => {
  if "pre-title" in p {
    [#p.at("pre-title", default: "") ]
  }
  p.at("name", default: "")
  if "post-title" in p {
    [ #p.at("post-title", default: "")]
  }
}

#let pc = (citation) => {
  set cite(form: "prose")
  citation
} // prose citation helper function from https://github.com/typst/typst/issues/2716#issuecomment-1817870741