#import "template.typ": *

#doc-config(
  header-title: "LightFin Nano 轻鳍自稳接收机用户手册",
  version: "v1.0",
)

#set heading(numbering: "1.1")
#show heading: set block(above: 1.2em, below: 0.6em)
#show outline.entry: set par(leading: 1.2em)

#let update-date = resolve_update_date(fallback: "2026年7月14日")

#cover-page(
  main-title: "LightFin Nano 用户手册",
  subtitle: "ELRS 接收、六通道混控与角速度自稳一体化方案",
  doc-version: "v1.0",
  update-date: update-date,
  hardware-info: "适用硬件：LightFin Nano 轻鳍自稳接收机",
  product-image-path: "assets/lightfin-nano-pcb-top.png",
)

= 产品概述 <intro>

*LightFin Nano*（轻鳍自稳接收机）是由 *座头鲸工作室 / HumpbackLab* 推出的
轻量化一体式接收与控制模块。它把 ELRS 接收、六通道输出、混控、角速度自稳、
电压回传和有刷电机驱动集中在一块小型 PCB 上，适合对体积、重量和布线有要求的
固定翼及其他轻量模型。

== 核心能力

#table(
  columns: (1.25fr, 2.8fr),
  inset: 8pt,
  align: horizon,

  [*功能*], [*说明*],
  [通道输出], [支持 6 通道微型舵机输出与通道混控。],
  [有刷驱动], [其中 4 个通道可驱动有刷电机，标称每路最大电流 5 A。],
  [无线链路], [支持与 ELRS 3.x 高频头配对。],
  [自稳控制], [支持角速度自稳，并可调整 PID 参数。],
  [遥测], [支持电池电压回传。],
  [配置方式], [支持遥控器端和配置器调参。],
  [固件维护], [支持通过 WiFi 在线升级固件。],
)

#tip[
  LightFin Nano 也可以作为常规 ELRS 接收机使用，并将接收数据提供给外部飞控。此项功能在硬件上是支持的，但是需要用户自行焊接uart rx/uart tx等信号线。
]

= 安全须知 <safety>

#caution[
  配置、升级或测试输出时，必须拆下螺旋桨，并断开可能突然动作的动力负载。
  有刷输出标称每路最大 5 A；这不是建议持续工作电流。实际可用电流还受供电、
  插接件、线材、散热和环境温度影响。
]

= 硬件概览及接口 <hardware>

#figure(
  image("assets/lightfin-nano-pcb-top-annotated.png", width: 88%),
  caption: [LightFin Nano PCB 顶面接口标注]
)

#figure(
  image("assets/lightfin-nano-pcb-bottom-annotated.png", width: 88%),
  caption: [LightFin Nano PCB 底面接口标注]
)


#caution[
  “六通道”表示可配置的输出数量，不表示所有通道都具备相同的功率驱动能力。
  只有前 4 路通道可直接驱动有刷电机。
]

= 快速上手 <getting-started>

#block(
  fill: rgb("#e8f5e9"),
  stroke: (left: 4pt + green),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *首次使用最短路径*：上电 → 连接配置器 -> 检查是否需要更新固件 -> 设置 ELRS 对频密码 → 配置PWM、混控和正方向 → 小幅度检查输出 → 拆桨完成地面测试。
]

== 连接配置器

1. 给 LightFin Nano 上电，接收端未连接发射机时，等待约 60 秒进入 WiFi 模式。
2. 强烈建议，在连接接收端热点前，先#link(<update>)[#text(fill: red)[*检查更新*]]。
3. 连接接收端热点，默认名称通常为 `ExpressLRS RX`，默认密码为 `expresslrs`。
4. 使用配置器连接 `http://10.0.0.1`


== 设置 ELRS 对频密码

建议为发射端与 LightFin Nano 设置相同且唯一的 *Binding Phrase*（绑定短语）。

在模型页面填写合适的绑定短语并保存
#image("assets/image-2.png")


#tip[
  UI 不会显示 Binding Phrase 的明文。输入新短语时，界面会把它转换并保存为
  UID；以后看到输入框为空不代表设置丢失。
]

== 验证链路

#table(
  columns: (1.4fr, 2.6fr),
  inset: 8pt,
  align: horizon,

  [*单色 LED 状态*], [*常见含义*],
  [慢闪（约 500 ms 亮/灭）], [等待发射机连接。],
  [双闪], [已进入传统对频模式。],
  [快闪（约 25 ms 亮/灭）], [WiFi 模式已启用。],
  [常亮], [已连接发射机],
)

= 功能配置 <configuration>

== PWM通道配置

#image("assets/image-pwm.png")
模式选择：
对于有刷电机输出，选择10KhzDuty模式
对于舵机输出，选择50hz-400hz，取决于舵机支持的频率范围。

来源选择：
RC: 直接使用遥控器通道信号控制
混控器：使用配置器设置的混控逻辑输出

失控保护：（加锁状态或者丢失连接情况下的行为）
建议对于电机，使用无脉冲
对于舵机，选择固定位置，然后设定一个中央的位置（如1500us）

#caution[
前四个通道是电机与舵机兼容的通道，因此如果要使用舵机功能，需要勾选*极性反转*。
]

== 模式设置
#image("assets/image-mode.png")
根据需要，设置解锁通道 和 Rate/Angle模式开启通道。

== PID设置
根据模式，配置对应的PID参数。对于Rate 模式，PID参数的量级大概在：

P:0~2

I:0-10

D:0-0.5

I_lim:0-10

简单自稳建议使用PD即可。

== 混控设置
根据需要，增加或者减少电机(舵机)的数量。
每个电机有四项值，分别代表这个电机的输出中，各个通道的贡献系数。

电机的输出 = 油门 x 油门系数 + Roll输出x Roll系数 + Pitch输出 x Pitch系数 + Yaw输出 x Yaw 系数

Roll/Pitch/Yaw输出为PID的输出值

== 飞控正方向设置
#image("assets/image.png")
将飞控安装在飞机上之后，将飞机保持水平，点击采集水平姿态。

采集完成后，将飞机竖直向上，点击采集竖直姿态。即可完成正方向设置。

完成后，保存设置。

== 电压、姿态回传

在遥控器遥测页面发现新传感器，确认电压项目会随电池状态合理变化，再设置低电压。

= 固件升级 <update>

由于配置器连接 LightFin Nano 时一般会没有互联网（除非使用AP模式）。
因此可以在未连接设备，有互联网时，先下载最新的固件到本地。等到连接设备后，再检查固件是否需要更新。

#image("assets/image-1.png")

= 原理图 <schematic>

#figure(
  image("SCH_LightFin_Nano.pdf", width: 100%),
  caption: [LightFin Nano 原理图]
)
