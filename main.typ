#import "@preview/dashy-todo:0.0.3": todo

#set text(
  font: ("Segoe UI", "Microsoft YaHei"),
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

// 注释图已由 Python 生成，位于 assets/pcb-*-annotated.png

// 封面
#align(center + horizon)[
  #block(inset: 3em)[
    #text(28pt, weight: "bold", fill: navy)[AT32F435mini] \
    #v(0.4em)
    #text(18pt, weight: "medium")[INAV 飞控用户手册] \
    #v(1.2em)
    #text(11pt, gray)[面向差速固定翼与轻量机型的 1S 一体式飞控解决方案]
  ]

  #placeholder("产品外观与接口示意图", height: 15em) #todo[补充实物外观与接口示意图]

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
AT32F435mini 是一款面向 *INAV* 固件的超小型飞控，集成 *AT32F435* 主控与 *ELRS* 射频链路，适用于 1S 供电的轻量机型，尤其适合 *差速控制的无襟翼固定翼*。板载传感器覆盖 IMU、气压计与磁力计，满足稳定飞行与高度/航向估计的基础需求。

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

#figure(image("assets/pcb-top-view.png", width: 100%), caption: [PCB 顶层布局图])
#figure(rotate(180deg, image("assets/pcb-bottom-view.png", width: 100%)), caption: [PCB 底层布局图])
#figure(image("assets/SCH_AT32F435mini飞控-重制版_2026-01-29.pdf", width: 100%), caption: [原理图])

== 指示灯与按键
- *LED 状态灯*：板载 3 颗状态灯，其中 2 颗由 MCU 控制、1 颗由 ESP（ELRS_LED）控制。
- *电源/功能按键*：板载滑动开关，用于电源控制。

== 机械部分
- *PCB 尺寸*：约 30.2 mm × 14.6 mm
- *板厚*：0.8 mm
- *安装孔*：4 × M2 螺丝孔

= 快速上手 <getting-started>

本章面向拿到成品飞控的普通用户，帮助你快速完成连接、配置和起飞。飞控已出厂预装 INAV 和 ELRS 固件，可直接按本章操作。

== 第一步：安装 INAV Configurator

INAV Configurator 是配置飞控的上位机软件，支持 Windows、macOS 和 Linux。

1. 访问官方下载页面：
   - *GitHub Releases*: #link("https://github.com/iNavFlight/inav-configurator/releases")[https://github.com/iNavFlight/inav-configurator/releases] // 优化这个链接的样式
   - 选择最新版本，下载对应操作系统的安装包（如 `INAV-Configurator_win64_x.x.x.exe`）。#todo[9.0.0发布了，是否适用？]
2. 安装并运行 INAV Configurator。
3. 首次运行时，Windows 可能提示安装驱动，按提示完成即可。

== 第二步：硬件连接

本节介绍飞控的电源、电机和串口接线方式。

=== 电源接线
飞控使用 1S 锂电池供电，通过 *MX1.25-2Pin* 接口连接：

#table(
  columns: (1fr, 1fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*接口引脚*], [*连接到*], [*说明*],
  [Pin 1 (VIN)], [电池正极], [1S 锂电池（3.0V-4.2V）],
  [Pin 2 (GND)], [电池负极], [电源地],
)

=== 电机接线
飞控提供 4 路 PWM 输出，其中 *PWM1/PWM2* 用于差速纸飞机的左右电机：

#table(
  columns: (1fr, 1.5fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*接口*], [*引脚定义*], [*连接说明*],
  [U14 (PWM1)], [Pin1: PWM1, Pin2: VBAT], [左电机：信号线接 Pin1，正极接 Pin2],
  [U15 (PWM2)], [Pin1: VBAT, Pin2: PWM2], [右电机：正极接 Pin1，信号线接 Pin2],
)

#tip[有刷电机通常只需连接 PWM 信号线和电源正极，电机负极由电机驱动电路内部连接到 GND。]

#figure(image("assets/annotation_01.png", width: 100%), caption: [飞控接线总览示意图])

=== 串口连接（用于配置）

==== 准备材料

#table(
  columns: 3,
  rows: 2,
  inset: 8pt,
  align: horizon + center,
  // stroke: none,

  // 这里添加表头，优化布局，使得表格更紧凑
  [#image("assets/usb-to-ttl.png", width: 80%)],
  [#image("assets/sh1.0-to-2.54.png", width: 80%)],
  [#image("assets/battery.png", width: 80%)],
  [USB-TTL 串口模块\ 需支持 3.3V TTL 电平],[SH1.0-4Pin 转杜邦线], [1S 锂电池], 
  
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

#figure(image("assets/annotation_03.png", width: 100%), caption: [USB-TTL 串口模块到飞控 UART1 接线示意图])

#caution[TX/RX 交叉连接！飞控的 RX 接串口模块的 TX，飞控的 TX 接串口模块的 RX。]

==== 连接步骤
1. 按上表接好线，将 USB-TTL 模块插入电脑。
// 2. 给飞控接上 1S 电池，拨动开关上电。
3. 打开 INAV Configurator，左上角选择正确的串口（如 `COM3` 或 `/dev/ttyUSB0`）。
4. 波特率保持默认 *115200*，点击 *Connect*。
5. 连接成功后进入配置界面。

#placeholder("INAV Configurator 连接成功界面", height: 10em) #todo[补充连接成功截图]


== 第三步：首次连接配置向导

首次连接飞控时，INAV Configurator 会弹出配置向导，帮助你快速完成基本设置。

#figure(image("assets/inav-config-default-values.png", width: 80%), caption: [INAV Configurator 首次连接配置向导 - 机型选择])

在配置向导中：
1. *Platform type*: 选择 *Airplane*
2. *Mixer preset*: 选择 *Airplane without a tail (Wing, Delta, etc)*

#figure(image("assets/inav-config-receiver-wizard.png", width: 80%), caption: [INAV Configurator 首次连接配置向导 - 接收机配置])

接收机配置：
1. *Serial Receiver Provider*: 选择 *CRSF*
2. *Receiver UART*: 选择 *UART7*

完成向导后点击 *Apply* 保存设置。

== 第四步：配置差速纸飞机

差速纸飞机使用左右两个电机的转速差实现转向，无需舵面。以下是更详细的配置说明：#todo[核实实际配置]

=== 确认传感器状态
进入 *Setup* 页面，确认传感器状态正常（加速度计、陀螺仪、磁力计、气压计均显示绿色）。

=== 配置电机输出
进入 *Outputs* 页面，设置混控：

#table(
  columns: (1fr, 2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*输出通道*], [*功能*], [*混控设置*],
  [Motor 1 (PWM1)], [左电机], [Throttle 100%, Yaw -50%],
  [Motor 2 (PWM2)], [右电机], [Throttle 100%, Yaw +50%],
)

#tip[Yaw 的正负号决定转向方向。如果飞机转向相反，交换两个电机的 Yaw 符号即可。]

=== 手动配置接收机（可选）
如果首次连接向导未正确配置接收机，可手动设置：

1. 进入 *Ports* 页面：
   - 找到 *UART7*，在 *Receiver* 列选择 *Serial Rx*。
   - 点击右下角 *Save and Reboot*。
2. 进入 *Receiver* 页面：
   - *Receiver type*: 选择 *Serial*
   - *Serial Receiver Provider*: 选择 *CRSF*
3. 保存并重启。

=== 设置解锁开关
1. 进入 *Modes* 页面。
2. 找到 *ARM* 模式，点击 *Add Range*。
3. 选择遥控器上的一个开关通道（如 AUX1），设置触发范围（如 1700-2100）。
4. 保存设置。

=== 校准与测试
1. *加速度计校准*：进入 *Setup* 页面，将飞控水平放置，点击 *Calibrate Accelerometer*。
2. *电机方向测试*：进入 *Outputs* 页面，*不要安装螺旋桨*，勾选 *Enable motor and servo output*，手动滑动电机滑块测试转向是否正确。

#caution[测试电机时务必卸下螺旋桨！高速旋转的螺旋桨可能造成伤害。]

== 第五步：遥控器对频

飞控板载 ELRS 接收机，需要与 ELRS 遥控器对频。

=== 对频前准备
- 确保遥控器已安装 ELRS 发射模块并刷入对应固件。
- 遥控器和飞控的 ELRS 固件版本应匹配（建议均使用 3.x 版本）。

=== 对频步骤
1. *飞控上电*，等待 ELRS LED 开始闪烁（表示未连接状态）。
2. *进入对频模式*（二选一）：
   - *方法一（推荐）*：飞控上电后 60 秒内，ELRS 会自动进入对频模式（LED 快闪）。
   - *方法二*：通过 ELRS Lua 脚本或 ELRS Web UI 手动触发对频。
3. *遥控器发起对频*：
   - 在遥控器上进入 ELRS Lua 脚本（OpenTX/EdgeTX：长按 SYS 键）。
   - 选择 *Bind* 选项，等待对频完成。
4. *对频成功*：飞控 ELRS LED 变为常亮或慢闪，INAV Configurator 的 *Receiver* 页面可看到遥控器输入。

#tip[如果对频失败，检查双方固件版本是否一致，以及是否在 60 秒内完成操作。]

=== 通过 WiFi 更新 ELRS 固件
出厂固件已预装，一般无需更新。如需升级：

1. 飞控上电，60 秒后 ELRS 自动开启 WiFi 热点（SSID 类似 `ExpressLRS RX`）。
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
// #placeholder("整机接线总览示意图", height: 12em) #todo[补充整机接线示意图]

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
- *ELRS/CRSF串口*：ELRS 通信使用，已连接AT32-UART7和ELRS-UART0，烧录ELRS时使用。

== 固件烧录流程

#caution[INAV 固件必须通过 SWD 有线方式烧录，需要使用 *6pin 1.25mm 烧录夹*夹在 PCB 底面的测试点焊盘上。请仔细确认线序后再连接！]

#figure(image("assets/debug-probe.png", width: 80%), caption: [烧录夹连接示意图])

#figure(image("assets/annotation_02.png", width: 100%, height: 10cm), caption: [PCB 底面调试焊盘示意图])

=== AT32 占位固件
目的：释放 CRSF/UART7 控制权，方便 ESP8285 串口烧录。

1. 通过 DAP Link 连接 SWDIO / SWCLK / GND / VBAT(5V)。
2. 下载 `at32-dummy.elf` #todo[补充下载链接]。
3. 烧录完成后：
   - UART7 被配置为数字输入。
   - 两颗 LED 交替闪烁。

=== ESP8285 ELRS 固件
1. 使用镊子短接 GPIO0 与 GND，使 ESP 进入 Bootloader。
2. 通过 USB-UART 连接 UART5（TP18/TP7）。
3. 复位 ESP（断电重上电或拉低 ESP_NRST）进入下载模式。
4. 打开 ELRS Configurator，选择与下图一致的配置并选择串口刷写。

#figure(image("assets/elrs-config1.png", width: 80%), caption: [ELRS Configurator 配置截图 1])
#figure(image("assets/elrs-config2.png", width: 80%), caption: [ELRS Configurator 配置截图 2])

=== AT32 INAV 固件
1. 通过 DAP Link 连接 SWDIO / SWCLK / GND / VBAT。
2. 两种方式：
   - 本地编译固件（选择目标：`NEUTRONRCF435MINI_FW`）并烧录；或
   - 下载 `NEUTRONRCF435MINI_FW.elf` #todo[补充下载链接]。

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
  [UART5], [ESP8285 串口烧录], [通过 TP7/TP18 测试点],
  [UART7], [ELRS/CRSF 内部链路], [板载 ELRS 使用，默认不外接],
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

=== ESP 烧录/调试测试点
#table(
  columns: (1fr, 1.6fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*测试点*], [*Net*], [*说明*],
  [TP18], [UART5_TX], [ESP 串口发送],
  [TP7], [UART5_RX], [ESP 串口接收],
  [TP15], [GPIO0], [Bootloader 拉低进入烧录],
  [TP1/TP9], [GND], [参考地],
)

= 调试建议与注意事项 <debug>

- *ELRS/CRSF 串口*：默认占用 UART7，避免与外设复用。
- *供电安全*：1S LiPo 供电，避免超过负载开关额定电压。
- *电机保护*：有刷电机调试时请勿安装螺旋桨，防止造成人身伤害。