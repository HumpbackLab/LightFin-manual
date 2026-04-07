#import "@preview/dashy-todo:0.1.3": todo

// 文档模板函数，接受可配置参数
#let doc-config(
  header-title: "LightFin INAV 飞控文档",
  version: "v1.0",
) = {
  // 全局文本设置
  set text(
    font: ("Noto Sans", "Noto Sans CJK SC"),
    size: 11pt,
    lang: "zh",
    region: "cn",
  )

  // 段落设置
  set par(leading: 0.8em, spacing: 1.2em)

  // 页面设置
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(8pt, gray)
        #grid(
          columns: (1fr, 1fr),
          [#header-title],
          align(right)[版本: #version]
        )
        #v(-0.5em)
        #line(length: 100%, stroke: 0.5pt + gray)
      ]
    },
    footer: context [
      #align(center, text(9pt, gray)[第 #counter(page).display() 页])
    ],
  )

  // 标题设置
  set heading(numbering: "1.1 ")
  show heading: it => {
    v(1.2em, weak: true)
    it
    v(0.6em)
  }

  show outline.entry: set par(leading: 1.2em)
}

// 辅助函数：绘制占位/实物图
#let placeholder(caption, img_path: none, height: 10em) = figure(
  if img_path != none {
    image(img_path, width: 100%)
  } else {
    rect(width: 100%, height: height, stroke: 1pt + navy, fill: luma(250), radius: 4pt)[
      #align(center + horizon)[
        #text(gray, size: 14pt)[#caption] \
        #v(0.5em)
        #text(gray, size: 9pt)[请在此替换为实物照片、PCB 截图或软件界面]
      ]
    ]
  },
  caption: caption,
)

#let trimmed-image = (path, trim: (:), alt: none) => context {
  let img = image(path)
  // Get dimensions of the source image
  let dims = measure(img)

  layout(size => {
    let left = trim.at("left", default: 0.0%)
    let right = trim.at("right", default: 0.0%)

    let top = trim.at("top", default: 0.0%)
    let bottom = trim.at("bottom", default: 0.0%)

    let width-rel-trimmed = 100.0% - left - right
    let height-rel-trimmed = 100.0% - top - bottom

    let width-source-trimmed = dims.width * width-rel-trimmed
    let height-source-trimmed = dims.height * height-rel-trimmed

    // Aspect ratio h/w of the layout (available space)
    let aspect-height-layout = size.height / size.width
    // Aspect ratio h/w of the trimmed image
    let aspect-height-trimmed = height-source-trimmed / width-source-trimmed

    let width-final-trimmed = none
    let height-final-trimmed = none

    // Compute final size of trimmed image
    // by expanding along dimension that first hits the layout constraints
    if aspect-height-layout >= aspect-height-trimmed {
      // Expand width of image
      width-final-trimmed = size.width
      height-final-trimmed = aspect-height-trimmed * width-final-trimmed
    } else {
      // Expand height of image
      height-final-trimmed = size.height
      width-final-trimmed = size.height / aspect-height-trimmed
    }

    // Compute the hypothetical size of the image without trimming
    let width-final-untrimmed = width-final-trimmed / float(width-rel-trimmed)
    let height-final-untrimmed = height-final-trimmed / float(height-rel-trimmed)

    box(
        clip: true,
        inset: (
            top: -(top * height-final-untrimmed),
            bottom: -(bottom * height-final-untrimmed),
            left: -(left * width-final-untrimmed),
            right: -(right * width-final-untrimmed)
          ),
      // TODO: Handle explicit sizing according to a parameter (e.g. don't scale over DPI limits)
        image(path, width: width-final-untrimmed, height: height-final-untrimmed, alt: alt)
      )
  })
}

#let caution(body) = block(
  fill: rgb("#fff5f5"),
  stroke: (left: 4pt + red),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
  [*注意：* #body],
)

#let tip(body) = block(
  fill: rgb("#f0f8ff"),
  stroke: (left: 4pt + blue),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
  [*提示：* #body],
)

// 封面模板函数
#let cover-page(
  main-title: "LightFin INAV 飞控文档",
  subtitle: "",
  doc-version: "v1.0",
  update-date: "2026年1月28日",
  hardware-info: "适用硬件：LightFin 飞控",
  show-product-image: true,
) = {
  align(center + horizon)[
    #block(inset: 3em)[
      #text(28pt, weight: "bold", fill: navy)[LightFin] \
      #v(0.4em)
      #text(18pt, weight: "medium")[#main-title] \
      #if subtitle != "" [
        #v(1.2em)
        #text(11pt, gray)[#subtitle]
      ]
    ]

    #if show-product-image [
      #placeholder("产品外观与接口示意图", img_path: "assets/product-overview.aggressive-plus.jpg", height: 15em)
    ]

    #v(1fr)
    #text(10pt, gray)[文档版本：#doc-version | 最后更新：#update-date] \
    #text(10pt, gray)[#hardware-info]
  ]

  pagebreak()

  // 目录
  outline(indent: 2em, depth: 2)

  pagebreak()
}
