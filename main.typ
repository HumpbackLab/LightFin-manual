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
  [无线链路], [ESP8285 + SX1280], [板载 ELRS 射频链路，SPI 控制射频芯片],
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

#figure(image("assets/pcb-top-view.png", width: 100%), caption: [PCB Top View 布局图])
#figure(image("assets/pcb-bottom-view.png", width: 100%), caption: [PCB Bottom View 布局图])
#figure(image("assets/SCH_AT32F435mini飞控-重制版_2026-01-29.pdf", width: 100%), caption: [原理图])

== 接口分布（大体位置）
- *左侧区域*：VIN 电源输入（U13）、PWM1/PWM2 电机接口（U14/U15）、电源滑动开关（SW1）。
- *右侧区域*：PWM3/PWM4 三针接口（CN1/CN2）、UART1（U12）。
- *中心区域*：MCU、IMU、气压计与磁力计。
#todo[以量产丝印与实物复核接口分布]

== 关键器件与总线连接
- *IMU（LSM6DSOWTR）*：SPI1（SPI1_SCK/MISO/MOSI/CS），提供 IMU_INT 中断。
- *磁力计（QMC5883P）*：I2C2（IIC2_SCL/SDA），地址 *0x2C*。
- *气压计（SPL06-001）*：I2C2（IIC2_SCL/SDA），地址 *0x77*。
- *ELRS 无线链路*：ESP8285 通过 SPI 控制 SX1280（RADIO_SCK/MISO/MOSI/NSS、BUSY、DIO1、NRST）。

== 指示灯与按键
- *LED 状态灯*：板载 3 颗状态灯（红/绿/蓝），其中 2 颗由 MCU 控制、1 颗由 ESP（ELRS_LED）控制，具体行为由固件定义。
- *电源/功能按键*：板载滑动开关（MSK12CO2），用于电源控制（连接负载开关使能）。

== 机械部分
- *PCB 尺寸*：约 30.2 mm × 14.6 mm
- *板厚*：0.8 mm
- *安装孔*：4 × M2 螺丝孔

= 快速入门 <quick-start>

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

== 上位机连接与基础配置

#placeholder("INAV Configurator 连接示意图", height: 10em) #todo[补充 INAV Configurator 界面图]

1. 使用 USB-UART 连接 UART1（正面SH1.0-4Pin连接器VBAT/GND/RX/TX）。
2. 打开 *INAV Configurator*，选择正确的串口设备点击 *Connect*。
3. 完成以下关键设置：
   - *Ports*：启用 UART1 的 MSP。
   - *Receiver*：选择 CRSF（板载 ELRS）。
   - *校准*：Accelerometer 校准。

=== 差速固定翼混控建议
- 平台选择 *Airplane*。
- 输出设置：
  - 左电机：Throttle 100% + Yaw -50%（可按效果微调）。
  - 右电机：Throttle 100% + Yaw +50%。

#tip[差速固定翼通常只需要油门与偏航；横滚可通过差速加强或保持为 0。]

== 首飞流程（差速固定翼）
1. *起飞前检查*：IMU 校准、方向正确、螺旋桨推力向后。
2. *解锁*：设置 ARM 模式，确保油门最低解锁。
3. *起飞*：手掷或滑跑，油门 60% 左右。
4. *空中调整*：根据转向响应调整差速权重。
5. *降落*：逐步收油，保持轻微仰角滑翔落地。

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

  [IMU], [ICM-42688-P], [SPI1], [SPI1_CS + IMU_INT],
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
