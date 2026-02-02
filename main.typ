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
        [AT32F435mini INAV 飞控用户手册],
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
    #text(28pt, weight: "bold", fill: navy)[AT32F435mini] \
    #v(0.4em)
    #text(18pt, weight: "medium")[INAV 飞控用户手册] \
    #v(1.2em)
    #text(11pt, gray)[面向差速固定翼与轻量机型的 1S 一体式飞控解决方案]
  ]

  #placeholder("产品外观与接口示意图", img_path: "assets/product-overview.png", height: 15em)

  #v(1fr)
  #text(10pt, gray)[文档版本：v1.0 | 最后更新：2026年1月28日] \
  #text(10pt, gray)[适用硬件：AT32F435mini 飞控（INAV 定制固件）]
]

#pagebreak()

// 目录
#outline(indent: 2em, depth: 2)

#pagebreak()

= 产品概述 <intro>

== 核心定位与适用机型
AT32F435mini 是一款面向 *INAV* 固件的超小型飞控，集成 *AT32F435* 主控与 *ELRS*（ExpressLRS，开源低延迟射频协议）链路，适用于 1S 供电的轻量机型，尤其适合 *差速控制的无襟翼固定翼*（如纸飞机改装）。板载传感器覆盖 IMU（惯性测量单元）、气压计与磁力计，满足稳定飞行与高度/航向估计的基础需求。

== 核心硬件特性
#table(
  columns: (1.2fr, 2fr, 2.2fr),
  inset: 8pt,
  align: horizon + center,

  [*模块*], [*型号/器件*], [*说明*],

  [主控 MCU], [AT32F435CGU7], [QFN48，板载 SWD 调试与多路 UART/PWM],
  [无线链路], [ESP8285 + SX1280], [板载 ELRS 射频链路，SPI 控制射频芯片；WiFi和ELRS双天线设计],
  [IMU], [LSM6DSOWTR], [SPI1 总线，提供加速度计/陀螺仪数据],
  [磁力计], [QMC5883P], [I2C2，总线地址 0x2C],
  [气压计], [SPL06-001], [I2C2，总线地址 0x77],
  [电源管理], [TPS22975 + TPS63001], [负载开关 + Buck-Boost 供电],
)

== 使用场景与优势
- *差速固定翼*：双电机差速控制转向与俯仰，适合无襟翼/无舵面设计。
- *1S 轻量平台*：板载电源方案适配 1S LiPo，结构紧凑，减少外部模块。
- *ELRS 一体化*：无需外接接收机，降低布线与重量。

= 硬件概览 <hardware>

// #figure(image("assets/pcb-top-view.png", width: 100%), caption: [PCB 顶层布局图])

#figure(image("assets/annotation_01.png", width: 90%), caption: [PCB 顶层布局图])
// #figure(rotate(180deg, image("assets/pcb-bottom-view.png", width: 100%)), caption: [PCB 底层布局图])

#figure(image("assets/annotation_02.png", width: 90%, height: 10cm), caption: [PCB 底层布局图])
== 指示灯与按键
- *LED 状态灯*：板载 3 颗状态灯，其中 2 颗由 MCU 控制、1 颗由 ESP（ELRS_LED）控制。
- *电源/功能按键*：板载滑动开关，用于电源控制。

== 机械部分
- *PCB 尺寸*：约 30.2 mm × 14.6 mm
- *板厚*：0.8 mm
- *安装孔*：4 × M2 螺丝孔

= 快速上手 <getting-started>

本章面向拿到成品飞控的普通用户，帮助你快速完成连接、配置和起飞。飞控已出厂预装 INAV 和 ELRS 固件，可直接按本章操作。

#block(
  fill: rgb("#e8f5e9"),
  stroke: (left: 4pt + green),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *最快起飞路径*：如果飞控已由卖家预配置好机型参数，你只需完成以下步骤即可首飞：
  + *装机和对频*（第五步）：将电池和电机连接到飞控，让遥控器与飞控建立连接
  + *首飞检查*（第六步）：确认一切正常后起飞

  只有当你需要调整参数、排查问题或首次配置机型时，才需要连接电脑使用 INAV Configurator。
]

== 第一步：安装 INAV Configurator

INAV Configurator 是配置飞控的上位机软件，支持 Windows、macOS 和 Linux。

1. 访问官方下载页面：
   - *GitHub Releases*: #link("https://github.com/iNavFlight/inav-configurator/releases")[https://github.com/iNavFlight/inav-configurator/releases]
   - 选择最新版本，下载对应操作系统的安装包。如 `INAV-Configurator_win64_9.0.0.exe`
2. 安装并运行 INAV Configurator。
3. 首次运行时，Windows 可能提示安装驱动，按提示完成即可。

== 第二步：硬件连接

本节介绍飞控的电源、电机和串口接线方式。

// 配置步骤先不连接电池，由usb串口提供5V电源。


=== 串口连接

#tip[串口连接仅用于高级配置和调试。如果飞控已预配置且只需对频后直接飞行，则无需连接串口、可跳过本节。]

==== 准备材料

#table(
  columns: 3,
  rows: 2,
  inset: 8pt,
  align: horizon + center,
  // stroke: none,

  [#image("assets/usb-to-ttl.png", width: 80%)],
  [#image("assets/sh1.0-to-2.54.png", width: 80%)],
  [#image("assets/battery.png", width: 80%)],
  [3.3V 电平 USB 串口模块], [SH1.0-4Pin 转杜邦线], [1S 锂电池], 

)#todo[A4纸/折纸教程？]

==== 接线方式
飞控正面的 *UART1 接口*（SH1.0-4Pin）用于连接上位机：

#table(
  columns: (1fr, 1fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*飞控引脚*], [*连接到*], [*说明*],
  [Pin 1 (VBAT)], [串口模块 5V], [飞控电源],
  [Pin 2 (GND)], [串口模块 GND], [电源地],
  [Pin 3 (RX)], [串口模块 TX], [飞控接收 ← 电脑发送],
  [Pin 4 (TX)], [串口模块 RX], [飞控发送 → 电脑接收],
)

#figure(image("assets/annotation_06.png", width: 100%, fit: "stretch"), caption: [USB-TTL 串口模块到飞控 UART1 接线示意图])

#caution[TX/RX 交叉连接！飞控的 RX 接串口模块的 TX，飞控的 TX 接串口模块的 RX。]

==== 连接步骤

#figure(image("assets/inav-config-connect.png", width: 90%), caption: [连接界面])
1. 按上表接好线，将 USB-TTL 模块插入电脑。
// 2. 给飞控接上 1S 电池，拨动开关上电。
3. 打开 INAV Configurator，左上角选择正确的串口（如 `COM3` 或 `/dev/ttyUSB0`）。
4. 波特率保持默认 *115200*，点击 *Connect*。
5. 连接成功后进入配置界面。

#caution[首次连接配置向导阶段，请勿连接电机！默认配置下，INAV 会激活电调输出，可能导致连接的电机意外转动，造成电脑 USB 端口保护性断开，或造成人身伤害。请务必在电机配置完成后，在第四步再连接电机。]


== 第三步：首次连接配置向导

首次连接飞控时，INAV Configurator 会弹出配置向导，帮助你快速完成基本设置。

#figure(image("assets/inav-config-default-values.png", width: 80%), caption: [INAV Configurator 首次连接配置向导 - 机型选择])

在配置向导中：
1. *Platform type*: 选择 *Airplane*
2. *Mixer preset*: 选择 *Airplane without a tail (Wing, Delta, etc)*

#figure(image("assets/inav-config-receiver-wizard.png", width: 80%), caption: [INAV Configurator 首次连接配置向导 - 接收机配置])

接收机配置：
+ *Serial Receiver Provider*: 选择 *CRSF*
+ *Receiver UART*: 选择 *UART7*
+ 单击右下角 `Next`

#figure(image("assets/inav-config-platform-type-selection.png", width: 80%), caption: [INAV Configurator 首次连接配置向导 - GPS 向导])

首次连接向导会根据你选择的平台类型进行配置。
飞控将保存这些参数并自动重启。

// 下面开始是重启之后
首次配置向导完成后，Status 页面将显示飞控的整体状态。如图所示，请确保左侧的传感器状态（陀螺仪、加速度计、磁力计、气压计）均为蓝色，这表示硬件连接和识别正常。右侧的 "Pre-arming checks" 列表在此时可能会显示一些红色的叉（例如传感器未校准、飞行模式未设置等），这是正常的。这些红色的检查项将在后续的校准和设置步骤中逐一解决，请暂时忽略。

#figure(image("assets/inav-config-status-page.png", width: 90%), caption: [Status 页面])

=== 传感器校准

接下来进行传感器校准，包括加速度计和磁力计，它们用于提供飞控的姿态和方向信息。请进入 INAV Configurator 的左侧导航栏，点击 *Calibration* 页面。

首先进行加速度计校准。在 Calibration 页面，点击 "Calibrate Accelerometer" 按钮。

#figure(image("assets/inav-calibration-start.png", width: 90%), caption: [校准开始界面])

然后，将飞控板按照不同的方向（正面朝上、反面朝上、左侧朝上、右侧朝上、机头朝上、机尾朝上，共六个方向）依次静置在水平表面上。每静置一个方向后，点击一次 Calibrate Accelerometer 按钮，直到界面中的所有灰色方块都被点亮。

#figure(image("assets/inav-calibration-accel-done.png", width: 90%), caption: [加速度计校准完成])

如上图，加速度计校准成功后，接下来进行磁力计校准（Compass Calibration）。点击 "Calibrate Compass" 按钮，在 30 秒的时间内：将飞控握在空中，缓慢、平稳地旋转飞控，使其每一个面（包括前、后、左、右、顶部和底部）都依次朝向地面。此过程旨在让飞控的磁力计学习所有方向的磁场数据。

#tip[请务必确保在校准过程中，飞控附近没有磁铁或任何电磁干扰源，以免影响校准的准确性。]

#figure(image("assets/inav-calibration-compass-done.png", width: 90%), caption: [磁力计校准完成])

磁力计校准完成后，所有校准任务即告一段落。此时，请务必点击右下角的 "Save and Reboot" 按钮，保存您的设置并让飞控重新启动，使新的校准数据生效。

飞控重启后，返回 Status 页面。此时您会看到 "Pre-arming checks" 列表已经全部变为绿色。这表示所有飞行前的安全检查均已通过，飞机已准备好解锁（ARM）并进行飞行。

#figure(image("assets/inav-prearm-green.png", width: 90%), caption: [解锁检查通过])

=== 预配置电机模式

在连接物理电机到飞控之前，需要修改INAV的默认电机设置，避免默认配置下电机意外转动，造成潜在的危险或设备损坏。

#caution[
  在完成本节配置前，请勿连接电机。
]

按以下步骤将默认输出模式改为有刷电机（BRUSHED）：

1. 连接飞控并进入 INAV Configurator。
2. 左侧导航栏进入 *Outputs* 页面（如下图）。

#figure(
  image("assets/inav-outputs-page.png", width: 90%),
  caption: [Outputs 页面]
)
#tip[
  纸飞机飞控无电流检测电路，在Outputs页面显示的当前电流值无效，可放心忽略。连接电池情况下，Voltage 部分应显示真实电池电压。
]

3. 打开 *Enable motor and servo output* 开关。
4. 将 *ESC protocol* 设置为 *BRUSHED*（有刷电机）。

#figure(
  image("assets/inav-outputs-enable-brushed.png", width: 90%),
  caption: [启用输出并设置 BRUSHED]
)

5. 点击右下角 *Save and Reboot* 保存并重启。重启完成后重新连接，确认设置已生效。

== 第四步：配置差速纸飞机

差速纸飞机使用左右两个电机的转速差实现转向，无需舵面。请继续进行下面的配置和测试步骤。

=== 连接电源和电机

在配置输出前，需要先连接两路电机到飞控PWM输出接口，并连接电池供电。为了连接INAV Configurator，仍然需要连接USB-TTL串口。

飞控使用 1S 锂电池供电，通过 *MX1.25-2Pin* 接口连接：

#table(
  columns: (1fr, 1fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*接口引脚*], [*连接到*], [*说明*],
  [Pin 1 (VIN)], [电池正极], [1S 锂电池（3.0V-4.2V）],
  [Pin 2 (GND)], [电池负极], [电源地],
)

飞控提供 4 路 PWM 输出，其中 *PWM1/PWM2* 用于差速纸飞机的左右电机：

#table(
  columns: (1fr, 1.5fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*接口*], [*引脚定义*], [*连接说明*],
  [U14 (PWM1)], [Pin1: PWM1, Pin2: VBAT], [左电机：正极接 Pin1，负极接 Pin2],
  [U15 (PWM2)], [Pin1: VBAT, Pin2: PWM2], [右电机：正极接 Pin1，负极接 Pin2],
)

#caution[
  在进行任何电机测试、接线或配置操作时，请务必 *不要连接螺旋桨*。
]

飞控正面的 *UART1 接口*（SH1.0-4Pin）用于连接上位机。飞控供电已由电池提供，请*悬空*VBAT电源线：

#table(
  columns: (1fr, 1fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*飞控引脚*], [*连接到*], [*说明*],
  [Pin 1 (VBAT)], [*悬空*], [飞控电源],
  [Pin 2 (GND)], [串口模块 GND], [电源地],
  [Pin 3 (RX)], [串口模块 TX], [飞控接收 ← 电脑发送],
  [Pin 4 (TX)], [串口模块 RX], [飞控发送 → 电脑接收],
)

下图给出了电机、电池与 USB-TTL 串口的同时连接方式，供接线核对：
#figure(image("assets/annotation_04.png", width: 90%, height: 8.2cm), caption: [电机、电池及USB串口模块连接示意图])

连接主电池供电，将飞控背面的开关拨动到 ON 位置，此时几个指示灯应亮起。

=== 测试电机

#figure(
  image("assets/inav-outputs-motor-enable-control.png", width: 90%),
  caption: [Motor 菜单启用电机控制]
)
// 确保螺旋桨未连接，然后将左侧的三个滑块（分别对应Motor1，Motor2和两者同时）调整少许，当电机控制值大于 5% 时电机应转动，验证飞控动力部分工作正常。
// 低速下用手接触电机转轴感受其转动方向，两个电机转动方向应相反。若电机正反转颠倒，可直接交换电机两根线。

=== 配置 Mixer 混控（差速）

差速纸飞机通常不需要舵面（Servo），只需配置两路电机（Motor）的混控即可。

1. 进入 *Mixer* 页面，确认当前为默认状态（如下图）。

#figure(
  image("assets/inav-mixer-page-default.png", width: 90%),
  caption: [Mixer 页面默认状态]
)

2. 在 *Mixer preset* 中选择 *Flying Wing with differential thrust*，点击 *Load mixer*。

#figure(
  image("assets/inav-mixer-preset-differential-thrust.png", width: 90%),
  caption: [选择差速混控预设]
)

3. 在下方 *Servo Mixer* 区域，逐条 *Delete* 删除所有舵机输出项。

#figure(
  image("assets/inav-mixer-delete-servo-mixers.png", width: 90%),
  caption: [删除 Servo Mixer 项]
)

4. 在 *Motor Mixer* 区域，按下表填写两路电机的 Roll/Yaw 混控系数。

#table(
  columns: (1fr, 2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*输出通道*], [*功能*], [*混控设置*],
  [Motor 1], [左电机], [Throttle 1, Roll -0.1, Yaw -0.1],
  [Motor 2], [右电机], [Throttle 1, Roll +0.1, Yaw +0.1],
)#todo[核实实际推荐配置]

#figure(
  image("assets/inav-mixer-motor-roll-settings.png", width: 90%),
  caption: [Motor Mixer 参数设置]
)

5. 点击右下角 *Save and Reboot* 保存并重启。

#tip[Yaw 的正负号决定转向方向。如果飞机转向相反，交换两个电机的 Yaw 符号即可。]

=== 设置解锁开关#todo[核实步骤]
+ 进入 *Modes* 页面。
+ 找到 *ARM* 模式，点击 *Add Range*。
+ 选择遥控器上的一个开关通道（如 CH 5），设置触发范围（如 1800-2100）。
  - 请先在遥控器上配置好通道映射，确保在Receiver页面可以看到通道数值符合预期。
+ 保存设置。

#figure(
  image("assets/inav-modes-arm-range.png", width: 90%),
  caption: [ARM 模式范围]
)

== 第五步：最终连接和遥控器配置

在连接遥控器（对频）之前，请先将电池和电机如下图连接到飞控，但无需连接 USB 串口线。

#figure(
  block(
  trimmed-image(
    "assets/annotation_07.png", trim: (
    left: 17%, right: 25%, top: 18%, bottom: 10%
      )
    ),
    width: 60%
  ),
  caption: [飞控最终连线图]
)

飞控板载 ELRS 接收机，需要与 ELRS 遥控器对频。

=== 对频前准备
- 确保遥控器已安装 ELRS 发射模块并刷入对应固件。
- 遥控器和飞控的 ELRS 固件版本应匹配（建议均使用 3.x 版本）。

=== 密码对频

建议使用 *密码对频*（Binding Phrase）方式，无需手动触发对频模式，只需确保遥控器与飞控使用相同的对频密码即可自动连接。

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

==== 在遥控器上设置对频密码 #todo[具体步骤待确认]

1. *通过 Lua 脚本设置*（OpenTX/EdgeTX）：
   - 长按 *SYS* 键进入系统菜单，选择 *ELRS* Lua 脚本。
   - 找到 *Binding Phrase* 选项。
   - 输入对频密码：`123456`
   - 保存并退出。

2. *通过 ELRS Configurator 设置*（刷写固件时）：
   - 在 ELRS Configurator 中勾选 *Binding Phrase*。
   - 输入：`123456`
   - 刷写固件到发射模块。

==== 验证对频成功
1. 飞控上电，观察 ELRS LED 状态：
   - *慢闪（500ms 亮/灭）*：等待连接
   - *快闪（25ms 亮/灭）*：WiFi 模式
   - *常亮*：已连接或处于烧录模式
   - 官方说明：#link("https://www.expresslrs.org/quick-start/led-status/#receivertransmitter-led-status")[ExpressLRS LED Status]
2. 打开遥控器，等待数秒，LED 应变为常亮。
3. 连接 INAV Configurator，进入 *Receiver* 页面，拨动遥控器摇杆确认响应正常。

#tip[
  如果对频失败，依次检查：
  + 遥控器与飞控的对频密码（Binding Phrase）是否完全一致（区分大小写）；
  + 遥控器与飞控的 ELRS 固件主版本是否一致（建议均为 3.x，例如3.6.2）。
]

=== 通过 WiFi 更新 ELRS 固件
出厂固件已预装，一般无需更新。如需升级：

1. 飞控上电，60 秒后 ELRS 自动开启 WiFi 热点（名称默认为 `ExpressLRS RX`）。
2. 电脑连接该热点，密码默认为 `expresslrs`。
3. 浏览器访问 `http://10.0.0.1`，进入 ELRS Web UI。
4. 上传新固件（`.bin` 文件），等待重启更新完成。

#caution[WiFi 更新仅适用于 ELRS 固件。INAV 固件需通过 SWD 有线烧录（参见后续"固件烧录流程"章节）。]

== 第六步：首飞检查清单

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  align: horizon,

  [☐], [加速度计已校准，飞控水平放置时 Setup 页面显示水平],
  [☐], [遥控器已对频，Receiver 页面摇杆响应正常],
  [☐], [电机方向正确（推力向后）],
  [☐], [ARM 开关已设置，可正常解锁/上锁],
  [☐], [电池电压正常，飞控供电稳定],
  [☐], [螺旋桨安装牢固，方向正确],
  [☐], [重心位置合适，飞机平衡],
)

完成以上检查后，找一片开阔场地，手掷起飞，享受飞行！

#pagebreak()

= 进阶设置与固件烧录 <quick-start>

以下内容面向需要重新烧录固件或进行深度调试的用户。

== 开箱检查与准备
#caution[首次上电前请检查焊点与连接器方向，确认无短路、反接、虚焊。]

- 检查 PCB 外观、接口及按键是否完整。
- 准备工具：DAP Link（或兼容 SWD 下载器）、USB-UART（3.3V）、烧录夹、1S 锂电池。

== 关键接口连接
#figure(image("assets/annotation_01.png", width: 100%), caption: [PCB正面接线示意图])

=== 机体安装与方向
- 飞控应安装在机体重心附近，尽量保持水平。
- 以 PCB 丝印方向标识为准，确保机头方向与飞控坐标一致。
- 建议使用泡棉或软胶减震固定，避免高频震动干扰 IMU。

=== 电源输入（MX1.25-2Pin）
- *VIN*：电池正极输入。
- *GND*：电池负极。

=== 电机输出
- *PWM1/PWM2（2Pin）*：用于有刷电机。
- *PWM3/PWM4（3Pin）*：支持有刷电机与舵机接线。

#caution[舵机功能当前固件尚未完成，仅保留硬件兼容性。]

=== UART 连接
- *UART1*：正面SH1.0-4Pin连接器，连接上位机。
- *ELRS/CRSF串口*：ELRS 通信使用，已连接AT32-UART7和ELRS-UART0，用于 ESP8285/ELRS 烧录。
- *UART5*：备用串口，通过测试点引出。

== 固件烧录流程

#caution[INAV 固件必须通过 SWD 有线方式烧录，需要使用 *6pin 1.25mm 烧录夹*夹在 PCB 底面的测试点焊盘上。请仔细确认线序后再连接！]

#figure(image("assets/debug-probe.png", width: 80%), caption: [烧录夹连接示意图])#todo[需要更新]

=== AT32 占位固件
目的：释放 CRSF/UART7 控制权，方便 ESP8285 串口烧录。

1. 通过 DAP Link 连接 SWDIO / SWCLK / GND / VBAT(5V)。
2. 下载 `at32-dummy.elf` #todo[下载链接待补充]。
3. 烧录完成后：
   - UART7 被配置为数字输入。
   - 两颗 LED 交替闪烁。

=== ESP8285 ELRS 固件
1. 使用镊子短接 GPIO0 与 GND，使 ESP 进入 Bootloader。
2. 通过 USB-UART 连接 UART7（ELRS/CRSF）。
3. UART5（TP18/TP7）为备用串口，通常不用于 ESP8285 烧录。
4. 复位 ESP（断电重上电或拉低 ESP_NRST）进入下载模式。
5. 打开 ELRS Configurator，选择与下图一致的配置并选择串口刷写。

#figure(image("assets/elrs-config1.png", width: 80%), caption: [ELRS Configurator 配置截图 1])
#figure(image("assets/elrs-config2.png", width: 80%), caption: [ELRS Configurator 配置截图 2])

=== AT32 INAV 固件
1. 通过 DAP Link 连接 SWDIO / SWCLK / GND / VBAT。
2. 两种方式：
  - 本地编译固件（选择目标：`NEUTRONRCF435MINI_FW`）并烧录；或
  - 下载 `NEUTRONRCF435MINI_FW.elf` #todo[下载链接待补充]。

= 详细技术规范 <specs>

== 电源树
#table(
  columns: (1.2fr, 2fr, 2.2fr),
  inset: 8pt,
  align: horizon + center,

  [*节点*], [*路径*], [*电压/备注*],

  [VIN], [电池输入], [1S 锂电池，额定最大值 5.7V],
  [VBAT], [TPS22975 负载开关输出], [开关控制，供电机与系统],
  [VCC], [TPS63001 Buck-Boost 输出], [系统主电源3.3V],
  [VDDR], [SX1280 射频电源], [局部去耦供电，未外部引出],
)

- *电压采样*：ADC_VBAT 连接电池电压分压，用于 INAV 电池监测。#todo[分压系数设置？]

== 传感器与总线地址
#table(
  columns: (1.3fr, 1.6fr, 1.2fr, 1.4fr),
  inset: 8pt,
  align: horizon + center,

  [*传感器*], [*型号*], [*总线*], [*地址/片选*],

  [IMU], [LSM6DSOWTR], [SPI1], [SPI1_CS + IMU_INT],
  [磁力计], [QMC5883P], [I2C2], [0x2C],
  [气压计], [SPL06-001], [I2C2], [0x77],
)

== 接口与引脚定义

=== 串口资源分配（摘要）
#table(
  columns: (1fr, 1.6fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*UART*], [*用途*], [*备注*],
  [UART1], [MSP/CLI 上位机], [通过 U12 连接],
  [UART5], [备用串口], [通过 TP7/TP18 测试点],
  [UART7], [ELRS/CRSF 内部链路], [板载 ELRS 使用，兼作 ESP8285 烧录],
)

=== 电源输入（U13，ZX-MX1.25-2PWT）
#table(
  columns: (1fr, 1.2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*Pin*], [*Net*], [*说明*],
  [1], [VIN], [电池正极输入],
  [2], [GND], [电池负极],
)

=== 有刷电机输出（U14/U15，2pin）
#table(
  columns: (1fr, 1.2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*接口*], [*Pin*], [*Net / 说明*],
  [U14], [1], [PWM1（电机控制）],
  [U14], [2], [VBAT（电机正极）],
  [U15], [1], [VBAT（电机正极）],
  [U15], [2], [PWM2（电机控制）],
)

=== 三针动力/舵机接口（CN1/CN2，HC-1.25-3PWT）
#table(
  columns: (1fr, 1fr, 1.2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*接口*], [*Pin*], [*Net*], [*说明*],
  [CN1], [1], [PWM3], [信号输出（电机/舵机）],
  [CN1], [2], [VBAT], [电源正极],
  [CN1], [3], [GND], [电源地],
  [CN2], [1], [PWM4], [信号输出（电机/舵机）],
  [CN2], [2], [VBAT], [电源正极],
  [CN2], [3], [GND], [电源地],
)

#caution[舵机固件功能未完成，仅保留硬件兼容，请勿在当前固件中启用舵机控制。]

=== UART1（MSP/CLI，U12，ZX-SH1.0-4PWT）
#table(
  columns: (1fr, 1.2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*Pin*], [*Net*], [*说明*],
  [1], [VBAT], [供电输出（1S）],
  [2], [GND], [地],
  [3], [UART1_RX], [MSP/CLI 接收],
  [4], [UART1_TX], [MSP/CLI 发送],
)

#tip[UART1 接口旁的固定焊盘为 PWM4 网络，避免短路/误触。]
#tip[UART1 引出的是 VBAT（1S）电源，需连接串口 5V 电源。但TX/RX必须为 3.3V TTL逻辑电平。]

=== 调试/烧录测试点（TP）
#table(
  columns: (1fr, 1.6fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*测试点*], [*Net*], [*用途*],
  [TP3], [SWCLK], [AT32 SWD 时钟],
  [TP4], [SWDIO], [AT32 SWD 数据],
  [TP1/TP9], [GND], [SWD 参考地],
  [TP8], [VBAT], [目标供电],
)

=== 备用串口测试点（UART5）
#table(
  columns: (1fr, 1.6fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*测试点*], [*Net*], [*说明*],
  [TP18], [UART5_TX], [备用串口发送],
  [TP7], [UART5_RX], [备用串口接收],
  [TP15], [GPIO0], [Bootloader 拉低进入烧录],
  [TP1/TP9], [GND], [参考地],
)

= 调试建议与注意事项 <debug>

- *ELRS/CRSF 串口*：默认占用 UART7，避免与外设复用。
- *供电安全*：1S LiPo 供电，避免超过负载开关额定电压。
- *电机保护*：有刷电机调试时请勿安装螺旋桨，防止造成人身伤害。

= 故障排除 <troubleshooting>

== 连接问题

*Q: INAV Configurator 无法连接飞控*
- 检查 USB-TTL 模块是否正确安装驱动（Windows 设备管理器中应显示 COM 端口）。
- 确认 TX/RX 是否交叉连接（飞控 RX 接模块 TX，飞控 TX 接模块 RX）。
- 尝试更换 USB 线缆或 USB 端口。
- 确认波特率设置为 115200。

*Q: 连接后显示乱码或无响应*
- 检查串口模块是否为 3.3V TTL 电平（部分模块默认 5V，需切换跳线）。
- 确认飞控已正常上电（LED 应有指示）。

== 对频问题

*Q: 遥控器无法与飞控对频*
- 确认双方 ELRS 固件版本一致（建议均为 3.x）。
- 确认对频密码（Binding Phrase）一致，出厂默认为 `123456`。
- 尝试通过 WiFi 进入 ELRS Web UI 检查接收机状态。

*Q: 对频成功但 Receiver 页面无响应*
- 检查 INAV 中 UART7 是否正确配置为 Serial Rx。
- 确认 Receiver 页面中 Serial Receiver Provider 设置为 CRSF。

== 电机问题

*Q: 解锁后电机不转*
- 检查电机接线是否正确（PWM 信号线和电源正极）。
- 确认 Outputs 页面中已启用对应电机通道。
- 检查油门摇杆是否在最低位置（某些安全设置要求油门归零才能解锁）。
- 检查是否存在未解除的安全锁定（如加速度计未校准）。

*Q: 电机转向错误*
- 对于有刷电机，交换电机两根线即可反转。
- 在 Outputs 页面调整混控中的正负号。

== 传感器问题

*Q: 加速度计校准失败*
- 确保校准时飞控完全静止且水平放置。
- 避免在振动环境（如桌面有电脑风扇）中校准。
- 尝试重启飞控后再次校准。

*Q: 磁力计/气压计显示红色*
- 检查传感器是否受到干扰（远离强磁场、避免阳光直射气压计）。
- 部分情况下传感器需要预热，等待数秒后重新检查。

= 产品规格汇总 <specs-summary>

#table(
  columns: (1fr, 2fr),
  inset: 10pt,
  align: horizon,

  [*项目*], [*规格*],
  [PCB 尺寸], [30.2 mm × 14.6 mm],
  [PCB 层数], [4 层],
  [板厚], [0.8 mm],
  [安装孔], [4 × M2],
  [工作电压], [3.0V - 4.2V（1S 锂电池）],
  [最大输入电压], [5.7V],
  [主控 MCU], [AT32F435CGU7（QFN48）],
  [无线链路], [ESP8285 + SX1280（ELRS 2.4GHz）],
  [IMU], [LSM6DSOWTR（SPI1）],
  [磁力计], [QMC5883P（I2C2, 0x2C）],
  [气压计], [SPL06-001（I2C2, 0x77）],
  [电机输出], [4 路 PWM（2 × 2Pin + 2 × 3Pin）],
  [串口], [UART1（上位机）/ UART7（ELRS 内部）],
)

= 术语表 <glossary>

#table(
  columns: (1fr, 3fr),
  inset: 10pt,
  align: horizon,

  [*术语*], [*说明*],
  [INAV], [开源飞控固件，支持固定翼、多旋翼等多种机型，提供自稳、导航等功能。],
  [ELRS], [ExpressLRS，开源低延迟射频通信协议，用于遥控器与飞控之间的通信。],
  [CRSF], [Crossfire 协议，ELRS 使用的串口通信协议格式。],
  [MSP], [MultiWii Serial Protocol，飞控与上位机之间的通信协议。],
  [CLI], [Command Line Interface，命令行界面，用于高级配置和调试。],
  [SWD], [Serial Wire Debug，ARM 处理器的调试/烧录接口。],
  [IMU], [Inertial Measurement Unit，惯性测量单元，包含加速度计和陀螺仪。],
  [差速控制], [通过左右电机转速差实现转向的控制方式，无需舵面。],
  [对频], [Binding，遥控器发射机与接收机建立配对关系的过程。],
  [解锁/ARM], [使飞控进入可飞行状态，电机响应油门输入。],
)
