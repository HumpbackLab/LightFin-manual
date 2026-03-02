#import "@preview/dashy-todo:0.1.3": todo

#set text(
  font: ("Noto Sans", "Noto Sans CJK SC"),
  size: 11pt,
  lang: "zh",
  region: "cn",
)

#set par(leading: 0.8em, spacing: 1.2em)

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(8pt, gray)
      #grid(
        columns: (1fr, 1fr),
        [LightFin INAV 飞控快速入门指南],
        align(right)[版本: v1.0]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt + gray)
    ]
  },
  footer: context [
    #align(center, text(9pt, gray)[第 #counter(page).display() 页])
  ],
)

#set heading(numbering: "1.1 ")
#show heading: it => {
  v(1.2em, weak: true)
  it
  v(0.6em)
}

#show outline.entry: set par(leading: 1.2em)

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

// 封面
#align(center + horizon)[
  #block(inset: 3em)[
    #text(28pt, weight: "bold", fill: navy)[LightFin] \
    #v(0.4em)
    #text(18pt, weight: "medium")[LightFin INAV 飞控快速入门指南] \
    #v(1.2em)
    #text(11pt, gray)[面向差速固定翼与轻量机型的 1S 一体式飞控解决方案]
  ]

  #placeholder("产品外观与接口示意图", img_path: "assets/product-overview.aggressive-plus.jpg", height: 15em)

  #v(1fr)
  #text(10pt, gray)[文档版本：v1.0 | 最后更新：2026年1月28日] \
  #text(10pt, gray)[适用硬件：LightFin 飞控]
]

#pagebreak()

// 目录
#outline(indent: 2em, depth: 2)

#pagebreak()

// = 快速上手 <getting-started>

本手册面向拿到成品 LightFin 飞控的普通用户，帮助你快速完成连接、配置和起飞。LightFin 飞控已出厂预装 INAV 和 ELRS 固件，可直接按本手册操作。

= 安装 INAV Configurator

INAV Configurator 是配置飞控的上位机软件，支持 Windows、macOS 和 Linux。

1. 访问官方下载页面：
   - *GitHub Releases*: #link("https://github.com/iNavFlight/inav-configurator/releases")[https://github.com/iNavFlight/inav-configurator/releases]
   - 选择最新版本，下载对应操作系统的安装包。如 `INAV-Configurator_win64_9.0.0.exe`
2. 安装并运行 INAV Configurator。
3. 首次运行时，Windows 可能提示安装驱动，按提示完成即可。

= 接口一览

本节详细描述整个板子的接口（连接电机、舵机、电池、调试接口）和线序。

#figure(image("assets/annotation_01.aggressive-plus.jpg", width: 90%), caption: [PCB 顶层布局图])

#tip[
  除了调试接口间距为1.0mm以外，其他接口（电机、电池、舵机）均为1.25mm间距。
]

#tip[
  电池接口与电机接口均作了焊接优化，可以焊接裸线到塑料接口上的金属片。注意焊接时间，以防烫坏接口。
]
== 正方向

描述板子正方向。飞控应安装在机体重心附近，尽量保持水平。

#figure(image("assets/pcb-bottom-view-with-arrow.png", width: 90%), caption: [飞控方向标识])

= 遥控器对频

LightFin 飞控板载 ELRS 接收机，需要与 ELRS 遥控器对频。

#block(
  fill: rgb("#fff8e1"),
  stroke: (left: 4pt + orange),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *出厂对频密码*：`123456`

  请在遥控器端设置相同的对频密码，飞控上电后将自动连接。连接成功后，遥控器应发出提示，同时ELRS指示灯应由慢闪变为常亮。
]

== 在遥控器上设置对频密码
*通过 Lua 脚本使高频头进入WIFI模式 设置*：
   - 长按 *SYS* 键进入系统菜单，选择 *ELRS* Lua 脚本。
   - 进入 *WIFI Connectivity* 选项。
   - 选择 *Enable WIFI*
   - 使用电脑或者手机连接遥控器创建的 WiFi 热点，默认名称为 `ExpressLRS TX`，密码为 `expresslrs`。
  - 在浏览器中访问 `http://10.0.0.1`，在网页中输入Bind Phrase 并保存

== 验证对频成功
1. 飞控上电，观察 ELRS LED 状态：
   - *慢闪（500ms 亮/灭）*：等待连接
   - *快闪（25ms 亮/灭）*：WiFi 模式
   - *常亮*：已连接
   - 官方说明：#link("https://www.expresslrs.org/quick-start/led-status/#receivertransmitter-led-status")[ExpressLRS LED Status]
2. 打开遥控器，等待数秒，LED 应变为常亮。

#tip[
  如果对频失败，依次检查：
  + 遥控器与飞控的对频密码（Binding Phrase）是否完全一致（区分大小写）；
  + 遥控器与飞控的 ELRS 固件主版本是否一致（建议均为 3.x，例如3.6.2）。
]

= 连接和配置

== 无线配置

1. 飞控上电，60 秒后 ELRS 自动开启 WiFi 热点（名称默认为 `ExpressLRS RX`）。
2. 电脑连接该热点，密码默认为 `expresslrs`。
3. INAV Configurator 使用 TCP 方式连接，地址为 `10.0.0.1:5761`。
4. 连接成功后可进行配置。

== 有线配置（需要USB转TTL）

1. 使用附带的 SH1.0 x 4P 的线连接 USB 转 TTL 到电脑（注意不要连接电池，或者连接电池了不要打开开关）。
2. INAV Configurator 正常使用串口连接并配置
3. 连接成功后可进行配置。

#caution[电脑检测不到串口时，需要检查是否已经安装USB转TTL对应的驱动。]
