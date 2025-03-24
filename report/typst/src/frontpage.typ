#import "translations/translations.typ": translate
#import "utils.typ": name-with-titles

#let signature = person => [
  #line(length: 90%, stroke: 0.5pt)

  #person.at("name", default: "")
]

#let frontpage(
  font,
  author,
  advisors,
  assistants,
  reviewers,
  show-curriculum,
  date,
) = {
  text(font: font)[
    #place(dx: -40pt, dy: -20pt)[
      #box()[
        #image("graphics/unistuttgart_logo_englisch.png", alt: "Logo University of Stuttgart")
      ]
    ]

    #v(6em)

    #align(center)[
      //#show par: set block(spacing: 1.5em)

      #box(width: 100%, height: 7.5em)[
        #place(bottom)[
          #box(width: 100%, height: 100%)[
            #text(translate("title"), size: 2.1em, weight: "bold")

            //#text(translate("subtitle"), size: 1.5em, weight: "bold")
          ]
        ]
      ]

      #v(2em)

      #upper(text(translate("thesis-type"), size: 1.4em))

      #translate("submitted-to")

      #text(translate("academic-title"), size: 1.4em, weight: "bold")

      #if show-curriculum [
        #translate("in-study")

        #text(translate("curriculum"), size: 1.2em, weight: "bold")
      ]

      #translate("submitted-by")

      //#show par: set block(spacing: 0.6em)
      #text(name-with-titles(author), size: 1.2em, weight: "bold")

      #translate("student-number") #author.at("student-number", default: "")
    ]

    #v(3em)

    #align(left)[
      #translate("at-faculty")

      #translate("at-U")
      
      #[
        //#show par: set block(spacing: 0.5em)
        // #translate("advisor"): #name-with-titles(advisor)

        #if advisors.len() > 0 [
          #translate("advisors"): #name-with-titles(advisors.at(0))
          #for adv in advisors.slice(1) [
            // there's probably a better way than hiding this
            // #hide[#translate("advisors"): ]#name-with-titles(adv)
            // #translate("advisors"):
            , #name-with-titles(adv)
          ]
        ]

        #if assistants.len() > 0 [
          #translate("assistance"): #name-with-titles(assistants.at(0))
          #for assistant in assistants.slice(1) [

            // there's probably a better way than hiding this
            #hide[#translate("assistance"): ]#name-with-titles(assistant)
          ]
        ]
      ]
    ]

    #if reviewers.len() > 0 {
      let signatures = reviewers.map(signature)
      while signatures.len() < 3 {
        signatures.insert(0, [])
      }

      v(3em)
      [#translate("dissertation-reviewed-by"):]
      v(3em)
      grid(columns: (1fr, 1fr, 1fr), align: center, ..signatures)
    }

    #place(
      bottom + center,
      dy: 3em,
    )[
      #set line(stroke: 0.5pt)

      #grid(
        columns: (1fr, 1fr, 1fr),
        rows: (auto, auto),
        align: (left, center, center),
        row-gutter: 4em,

        [#translate("city"), #date.display("[day].[month].[year]") #v(2em)],
        signature(author),
        signature(advisors.at(0)),

        grid.cell(colspan: 3)[
          #align(center)[
            //#show par: set block(spacing: 0.5em)
            #line(length: 100%)
            #translate("U")

            #translate("U-postal") $dot$ #translate("U-address") $dot$ #translate("U-tel") $dot$ #translate("U-web")
          ]
        ],
      )
    ]
  ]
}