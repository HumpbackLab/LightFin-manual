#import "template.typ": *

#doc-config(
  header-title: "LightFin INAV 飞控用户手册",
  version: "v1.0",
)

#set heading(numbering: "1.1")
#show heading: set block(above: 1.2em, below: 0.6em)
#show outline.entry: set par(leading: 1.2em)

#let update-date = resolve_update_date()

#cover-page(
  main-title: "LightFin INAV 飞控用户手册",
  subtitle: "面向轻量固定翼与 1S 平台的 INAV 一体式飞控解决方案",
  doc-version: "v1.0",
  update-date: update-date,
  hardware-info: "适用硬件：LightFin 飞控（AT32F435mini 硬件平台，INAV 定制固件）",
)

= 产品概述 <intro>

*LightFin* 是由 *座头鲸工作室 / HumpbackLab* 推出的轻量化固定翼飞控产品。

== 核心定位与适用机型
*LightFin*（硬件平台：AT32F435mini）是一款面向 *INAV* 固件的超小型飞控，集成 *AT32F435* 主控与 *ELRS*（ExpressLRS，开源低延迟射频协议）链路，适用于 1S 供电的轻量固定翼与实验平台。板载传感器覆盖 IMU（惯性测量单元）、气压计与磁力计，满足基础姿态稳定、航向估计与高度感知需求。

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
- *轻量固定翼平台*：适合体积和重量受限的 1S 固定翼平台。
- *1S 轻量平台*：板载电源方案适配 1S LiPo，结构紧凑，减少外部模块。
- *ELRS 一体化*：无需外接接收机，降低布线与重量。

= 硬件概览 <hardware>

// #figure(image("assets/pcb-top-view.aggressive-plus.jpg", width: 100%), caption: [PCB 顶层布局图])

#figure(image("assets/annotation_01.aggressive-plus.jpg", width: 90%), caption: [PCB 顶层布局图])
// #figure(rotate(180deg, image("assets/pcb-bottom-view.aggressive-plus.jpg", width: 100%)), caption: [PCB 底层布局图])

#figure(image("assets/annotation_02.aggressive-plus.jpg", width: 90%, height: 10cm), caption: [PCB 底层布局图])

== 正方向

安装飞控时，应以板上方向标识为准，确保飞控前向与机体前向一致，并尽量保持安装面水平。

#figure(image("assets/pcb-bottom-view-with-arrow.png", width: 90%), caption: [飞控方向标识])

== 指示灯与按键
- *LED 状态灯*：板载 3 颗状态灯，其中 2 颗由 MCU 控制、1 颗由 ESP（ELRS_LED）控制。
- *电源/功能按键*：板载滑动开关，用于电源控制。

== 机械部分
- *PCB 尺寸*：约 30.2 mm × 14.6 mm
- *板厚*：0.8 mm
- *安装孔*：4 × M2 螺丝孔

= 快速上手 <getting-started>

本章面向拿到成品 LightFin 飞控的普通用户，帮助你完成首次连接、基础配置与功能检查。LightFin 飞控已出厂预装 INAV 和 ELRS 固件，可直接按本章操作。

#block(
  fill: rgb("#e8f5e9"),
  stroke: (left: 4pt + green),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *首次使用最短路径*：如果飞控已由卖家预置好参数，你只需完成供电接线、ELRS 对频和接收机响应检查即可开始装机。

  只有在需要校准传感器、修改输出配置、检查链路或重新刷写固件时，才需要连接电脑使用 INAV Configurator。
]

== 第一步：安装 INAV Configurator

INAV Configurator 是配置飞控的上位机软件，支持 Windows、macOS 和 Linux。

1. 访问官方下载页面：
   - *GitHub Releases*: #link("https://github.com/iNavFlight/inav-configurator/releases")[https://github.com/iNavFlight/inav-configurator/releases]
   - 选择最新版本，下载对应操作系统的安装包。如 `INAV-Configurator_win64_9.0.0.exe`
2. 安装并运行 INAV Configurator。
3. 首次运行时，Windows 可能提示安装驱动，按提示完成即可。

== 第二步：硬件连接

本节介绍飞控的两种连接方式。若只需完成基础配置，优先使用无线配置；需要稳定串口、调试或刷写时，再使用 USB-TTL 有线配置。

=== 方式一：无线配置

1. 飞控上电，60 秒后 ELRS 自动开启 WiFi 热点（名称默认为 `ExpressLRS RX`）。
2. 电脑连接该热点，密码默认为 `expresslrs`。
3. INAV Configurator 使用 TCP 方式连接，地址为 `10.0.0.1:5761`。
4. 连接成功后可进行配置。

=== 方式二：有线配置（需要 USB 转 TTL）

#tip[串口连接仅用于高级配置和调试。如果飞控已预配置且只需完成对频和基础检查，则无需连接串口、可跳过本节。]

使用附带的 SH1.0 x 4P 的线连接 USB 转 TTL 到电脑。有线配置时不要连接电池；如果已经连接电池，也不要打开飞控电源开关。

#caution[电脑检测不到串口时，需要检查是否已经安装 USB 转 TTL 对应的驱动。]

==== 准备材料

#table(
  columns: 3,
  rows: 2,
  inset: 8pt,
  align: horizon + center,
  // stroke: none,

  [#image("assets/usb-to-ttl.aggressive-plus.jpg", width: 80%)],
  [#image("assets/sh1.0-to-2.54.aggressive-plus.jpg", width: 80%)],
  [#image("assets/battery.aggressive-plus.jpg", width: 80%)],
  [3.3V 电平 USB 串口模块], [SH1.0-4Pin 转杜邦线], [1S 锂电池], 
)

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

#figure(image("assets/annotation_06.aggressive-plus.jpg", width: 100%, fit: "stretch"), caption: [USB-TTL 串口模块到飞控 UART1 接线示意图])

#caution[TX/RX 交叉连接！飞控的 RX 接串口模块的 TX，飞控的 TX 接串口模块的 RX。]

==== 连接步骤

#figure(image("assets/inav-config-connect.aggressive-plus.png", width: 90%), caption: [连接界面])
1. 按上表接好线，将 USB-TTL 模块插入电脑。
2. 打开 INAV Configurator，左上角选择正确的串口（如 `COM3` 或 `/dev/ttyUSB0`）。
3. 波特率保持默认 *115200*，点击 *Connect*。
4. 连接成功后进入配置界面。

#caution[首次连接配置向导阶段，请勿连接电机！默认配置下，INAV 会激活电调输出，可能导致连接的电机意外转动，造成电脑 USB 端口保护性断开，或造成人身伤害。请在完成输出模式确认后，再连接实际负载。]


== 第三步：首次连接配置向导

首次连接飞控时，INAV Configurator 会弹出配置向导，帮助你快速完成基本设置。

#figure(image("assets/inav-config-default-values.aggressive-plus.jpg", width: 80%), caption: [INAV Configurator 首次连接配置向导 - 机型选择])

在配置向导中：
1. *Platform type*: 选择 *Airplane*
2. *Mixer preset*: 根据实际机型选择对应预设；若仅做基础联机测试，可先保持默认，后续再按机型调整。

#figure(image("assets/inav-config-receiver-wizard.aggressive-plus.jpg", width: 80%), caption: [INAV Configurator 首次连接配置向导 - 接收机配置])

接收机配置：
+ *Serial Receiver Provider*: 选择 *CRSF*
+ *Receiver UART*: 选择 *UART7*
+ 单击右下角 `Next`

#figure(image("assets/inav-config-platform-type-selection.aggressive-plus.jpg", width: 80%), caption: [INAV Configurator 首次连接配置向导 - GPS 向导])

首次连接向导会根据你选择的平台类型进行配置。
飞控将保存这些参数并自动重启。

// 下面开始是重启之后
首次配置向导完成后，Status 页面将显示飞控的整体状态。如图所示，请确保左侧的传感器状态（陀螺仪、加速度计、磁力计、气压计）均为蓝色，这表示硬件连接和识别正常。右侧的 "Pre-arming checks" 列表在此时可能会显示一些红色的叉（例如传感器未校准、飞行模式未设置等），这是正常的。这些红色的检查项将在后续的校准和设置步骤中逐一解决，请暂时忽略。

#figure(image("assets/inav-config-status-page.aggressive-plus.jpg", width: 90%), caption: [Status 页面])

=== 传感器校准

接下来进行传感器校准，包括加速度计和磁力计，它们用于提供飞控的姿态和方向信息。请进入 INAV Configurator 的左侧导航栏，点击 *Calibration* 页面。

首先进行加速度计校准。在 Calibration 页面，点击 "Calibrate Accelerometer" 按钮。

#figure(image("assets/inav-calibration-start.aggressive-plus.jpg", width: 90%), caption: [校准开始界面])

然后，将飞控板按照不同的方向（正面朝上、反面朝上、左侧朝上、右侧朝上、机头朝上、机尾朝上，共六个方向）依次静置在水平表面上。每静置一个方向后，点击一次 Calibrate Accelerometer 按钮，直到界面中的所有灰色方块都被点亮。

#figure(image("assets/inav-calibration-accel-done.aggressive-plus.jpg", width: 90%), caption: [加速度计校准完成])

如上图，加速度计校准成功后，接下来进行磁力计校准（Compass Calibration）。点击 "Calibrate Compass" 按钮，在 30 秒的时间内：将飞控握在空中，缓慢、平稳地旋转飞控，使其每一个面（包括前、后、左、右、顶部和底部）都依次朝向地面。此过程旨在让飞控的磁力计学习所有方向的磁场数据。

#tip[请务必确保在校准过程中，飞控附近没有磁铁或任何电磁干扰源，以免影响校准的准确性。]

#figure(image("assets/inav-calibration-compass-done.aggressive-plus.jpg", width: 90%), caption: [磁力计校准完成])

磁力计校准完成后，所有校准任务即告一段落。此时，请务必点击右下角的 "Save and Reboot" 按钮，保存您的设置并让飞控重新启动，使新的校准数据生效。

飞控重启后，返回 Status 页面。此时应重点确认传感器状态正常、姿态显示合理，且 "Pre-arming checks" 中没有阻止解锁的关键错误。

#figure(image("assets/inav-prearm-green.aggressive-plus.jpg", width: 90%), caption: [解锁检查通过])

=== 配置输出模式

在连接物理负载之前，建议先检查 INAV 的输出模式，避免默认配置与实际硬件不匹配，造成意外转动或输出异常。

#caution[
  在完成本节配置前，请勿连接电机。
]

若你的 LightFin 接的是有刷电机，请按以下步骤将输出模式改为 *BRUSHED*：

1. 连接飞控并进入 INAV Configurator。
2. 左侧导航栏进入 *Outputs* 页面（如下图）。

#figure(
  image("assets/inav-outputs-page.aggressive-plus.jpg", width: 90%),
  caption: [Outputs 页面]
)
#tip[
  LightFin 飞控无电流检测电路，在Outputs页面显示的当前电流值无效，可放心忽略。连接电池情况下，Voltage 部分应显示真实电池电压。
]

3. 打开 *Enable motor and servo output* 开关。
4. 将 *ESC protocol* 设置为 *BRUSHED*（有刷电机）。

#figure(
  image("assets/inav-outputs-enable-brushed.aggressive-plus.png", width: 90%),
  caption: [启用输出并设置 BRUSHED]
)

5. 点击右下角 *Save and Reboot* 保存并重启。重启完成后重新连接，确认设置已生效。

== 第四步：接收机与链路检查

LightFin 飞控板载 ELRS 接收机，需要与 ELRS 遥控器对频。完成对频后，再进入 INAV Configurator 检查 Receiver 页面响应。

#block(
  fill: rgb("#fff8e1"),
  stroke: (left: 4pt + orange),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  请在遥控器端设置相同的对频密码，飞控上电后将自动连接。连接成功后，遥控器应发出提示，同时 ELRS 指示灯应由慢闪变为常亮。
]

=== 在遥控器上设置对频密码

*通过 Lua 脚本使高频头进入WIFI模式 设置*：
   - 长按 *SYS* 键进入系统菜单，选择 *ELRS* Lua 脚本。
   - 进入 *WIFI Connectivity* 选项。
   - 选择 *Enable WIFI*
   - 使用电脑或者手机连接遥控器创建的 WiFi 热点，默认名称为 `ExpressLRS TX`，密码为 `expresslrs`。
  - 在浏览器中访问 `http://10.0.0.1`，在网页中输入Bind Phrase 并保存

=== 验证对频成功
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

=== 通过 WiFi 更新 ELRS 固件
出厂固件已预装，一般无需更新。如需升级：

1. 飞控上电，60 秒后 ELRS 自动开启 WiFi 热点（名称默认为 `ExpressLRS RX`）。
2. 电脑连接该热点，密码默认为 `expresslrs`。
3. 浏览器访问 `http://10.0.0.1`，进入 ELRS Web UI。
4. 上传新固件（`.bin` 文件），等待重启更新完成。

#caution[WiFi 更新仅适用于 ELRS 固件。INAV 固件需通过 SWD 有线烧录（参见后续“固件烧录流程”章节）。]

== 第五步：功能与安全检查

=== 设置解锁开关
+ 进入 *Modes* 页面。
+ 找到 *ARM* 模式，点击 *Add Range*。
+ 选择遥控器上的一个开关通道（如 CH 5），设置触发范围（如 1800-2100）。
  - 请先在遥控器上配置好通道映射，确保在Receiver页面可以看到通道数值符合预期。
+ 保存设置。

#figure(
  image("assets/inav-modes-arm-range.aggressive-plus.jpg", width: 90%),
  caption: [ARM 模式范围]
)

=== 输出与传感器检查

#figure(
  image("assets/inav-outputs-motor-enable-control.aggressive-plus.jpg", width: 90%),
  caption: [Outputs 页面启用输出控制]
)

#caution[
  进行任何输出测试前，请先断开螺旋桨或其他危险负载，并确保机体不会因电机转动造成人身伤害。
]

建议在交付装机前至少完成以下检查：

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  align: horizon,

  [☐], [加速度计已校准，飞控水平放置时 Setup 页面显示水平],
  [☐], [遥控器已对频，Receiver 页面摇杆响应正常],
  [☐], [输出模式与实际硬件一致（如有刷电机已设置为 BRUSHED）],
  [☐], [Outputs 页面可正确识别并驱动对应输出通道],
  [☐], [ARM 开关已设置，可正常解锁/上锁],
  [☐], [电池电压正常，飞控供电稳定],
  [☐], [Status 页面无阻止解锁的关键错误],
)

#pagebreak()

= 进阶设置与固件烧录 <quick-start>

以下内容面向需要重新烧录固件或进行深度调试的用户。

== 开箱检查与准备
#caution[首次上电前请检查焊点与连接器方向，确认无短路、反接、虚焊。]

- 检查 PCB 外观、接口及按键是否完整。
- 准备工具：DAP Link（或兼容 SWD 下载器）、USB-UART（3.3V）、烧录夹、1S 锂电池。

== 关键接口连接
#figure(image("assets/annotation_01.aggressive-plus.jpg", width: 100%), caption: [PCB正面接线示意图])

=== 安装方向要求
- 以 PCB 丝印方向标识为准，确保飞控坐标与机体前向一致。
- 飞控安装面应尽量保持水平，避免明显倾斜。
- 建议使用泡棉或软胶减震固定，避免高频震动干扰 IMU。

=== 电源输入（MX1.25-2Pin）
- *VIN*：电池正极输入。
- *GND*：电池负极。

=== 电机输出
- *PWM1/PWM2（2Pin）*：用于有刷电机。
- *PWM3/PWM4（3Pin）*：支持有刷电机与舵机接线。

=== UART 连接
- *UART1*：正面SH1.0-4Pin连接器，连接上位机。
- *ELRS/CRSF串口*：ELRS 通信使用，已连接AT32-UART7和ELRS-UART0，用于 ESP8285/ELRS 烧录。
- *UART5*：备用串口，通过测试点引出。

== 固件烧录流程

=== ESP8285 ELRS 固件
1. 飞控上电，60s内没有遥控器对频成功时，ESP8285 会自动进入 WiFi 模式，创建名为 `ExpressLRS RX` 的热点。
2. 电脑连接该热点，密码默认为 `expresslrs`。
3. 浏览器访问10.0.0.1,进入 ELRS Web UI。在网页端上传对应固件即可完成烧录。

=== AT32 INAV 固件
1. 使用镊子短接进入烧录模式所需的两个触点后，再给飞控板上电。
2. 常用有两种操作方式：
  - *方式一*：保持镊子短接后立即使用 USB 转 TTL 连接电脑，电池不用接。适合电脑连接比较方便的场景。
  - *方式二*：接好电池，保持镊子短接后立即打开飞控电源开关，再从容使用 USB 转 TTL 连接电脑。此时 *不要* 连接 USB 转 TTL 给飞控板供电的那条线。
3. 观察上电后的状态：
  - 正常飞控上电时，板上的两个灯会闪烁。
  - 如果短接后上电，两个灯仍然闪烁，说明没有正常进入烧录模式，需要断电后重试。
4. 进入烧录模式后，使用浏览器打开 #link("https://humpbacklab.github.io/AT32-WebISP/")[AT32-WebISP]。
5. 在网页中选择对应串口和固件文件，按页面提示完成 AT32 MCU 固件烧录。

= 详细技术规范 <specs>

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
- 确认对频密码（Binding Phrase）一致。
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
- 重新确认输出通道映射与接线关系是否一致。

== 传感器问题

*Q: 加速度计校准失败*
- 确保校准时飞控完全静止且水平放置。
- 避免在振动环境（如桌面有电脑风扇）中校准。
- 尝试重启飞控后再次校准。

*Q: 磁力计/气压计显示红色*
- 检查传感器是否受到干扰（远离强磁场、避免阳光直射气压计）。
- 部分情况下传感器需要预热，等待数秒后重新检查。

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
  [对频], [Binding，遥控器发射机与接收机建立配对关系的过程。],
  [解锁/ARM], [使飞控进入可飞行状态，电机响应油门输入。],
)
