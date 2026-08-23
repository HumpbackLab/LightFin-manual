#import "template.typ": *

#doc-config(
  header-title: "LightFin Nano 轻鳍自稳接收机用户手册",
  version: "v1.1",
)

#set heading(numbering: "1.1")
#show heading: set block(above: 1.2em, below: 0.6em)
#show outline.entry: set par(leading: 1.2em)

#let update-date = resolve_update_date(fallback: "2026年7月14日")

#cover-page(
  main-title: "LightFin Nano 用户手册",
  subtitle: "ELRS 接收、六通道混控与角速度自稳一体化方案",
  doc-version: "v1.1",
  update-date: update-date,
  hardware-info: "适用硬件：LightFin Nano 轻鳍自稳接收机；适用固件：v0.9.3_e364",
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
  [自稳控制], [支持手动、角速度（Rate）和自稳（Angle）模式，并可调整 PID
    与输入滤波参数。],
  [输出配置], [支持设置舵机最小、中位、最大行程，并可在 WiFi 模式下测试输出。],
  [遥测], [支持电池电压及横滚、俯仰姿态回传。],
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
注意，有刷电机应该接在前 4 个通道（M1-M4）的PWMx和VBAT这两个引脚上。如果需要焊电机线
，可以直接使用M1-M4接口两边的金属片焊盘。
]

= 模式解释
由于在航模/无人机领域，各种控制模式的名称和定义不统一，LightFin Nano 的模式设置中使用了 *Manual*、*Rate* 和 *Angle* 三个模式名称。为了避免混淆，下面给出这些模式的定义。

Manual（手动模式）: 不进行姿态修正，摇杆输入直接进入混控器。
Rate（增稳、角速度模式）: 控制横滚、俯仰和偏航角速度；松杆后抑制继续旋转。 
Angle(自稳、角度模式): 控制横滚和俯仰角度，松杆后自动恢复水平；偏航仍按角速度控制。

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

=== 设置舵机行程

#image("assets/image-pwm-range.png", width: 100%)

对于 50 Hz—400 Hz 的舵机输出，可以分别设置最小、中位和最大脉宽。默认值为
1000 us、1500 us 和 2000 us；可设置范围为 500 us—2500 us，并且必须满足
最小值小于中位值、中位值小于最大值。

1. 先确认该输出已选择舵机支持的 PWM 频率。
2. 保持舵机摇臂与连杆可自由运动，从默认值开始调整中位。
3. 分别缓慢调整最小值和最大值，确保舵机不会顶死或带动机构过行程。
4. 保存后，重新检查中位和两端位置。

#tip[
  舵机行程设置不会作用于 10KhzDuty 有刷电机输出。
]

=== WiFi 输出测试

#image("assets/image-pwm-wifi-test.png", width: 100%)

进入 WiFi 模式后，可以启用输出测试，并为每一路舵机直接指定脉宽。测试值会被限制在
该路已经设置的最小值与最大值之间，适合检查舵机中位、方向和机械行程。

#caution[
  启用输出测试后，舵机会立即运动。测试前必须拆下螺旋桨，并断开电机或其他动力负载。
  调整完成后关闭输出测试；关闭时舵机 PWM 输出会停止。
]

== 模式设置

#image("assets/image-mode.png")

根据需要，设置解锁通道和 Rate/Angle 模式的开启通道及激活区间。模式通道可选择
CH5—CH16；通道值进入设置的区间时，对应模式生效。

#table(
  columns: (1fr, 2.8fr),
  inset: 8pt,
  align: horizon,

  [*模式*], [*作用*],
  [Manual], [不进行姿态修正，摇杆输入直接进入混控器。],
  [Rate], [控制横滚、俯仰和偏航角速度；松杆后抑制继续旋转。],
  [Angle], [控制横滚和俯仰角度，松杆后自动恢复水平；偏航仍按角速度控制。],
)

如果 Rate 和 Angle 都未进入激活区间，系统自动回到 Manual。不要让两个区间重叠；
如果发生重叠，Angle 的优先级更高。建议先在地面逐一拨动开关，确认每个档位只对应
一个模式。

== PID设置

根据模式，配置对应的PID参数。对于Rate 模式，PID参数的量级大概在：

P:0~10

I:0-10

D:0-0.5

I_lim:0-10

简单自稳建议使用PD即可。

=== 输入滤波

v0.9.3_e364 增加了两项低通滤波设置：

#image("assets/image-input-filters.png", width: 100%)

#block(breakable: false)[
  #table(
    columns: (1.2fr, 1fr, 2.2fr),
    inset: 8pt,
    align: horizon,

    [*参数*], [*默认值*], [*作用*],
    [Gyro LPF], [30 Hz], [过滤陀螺仪角速度输入，减少振动和噪声进入控制环。],
    [D-term LPF], [20 Hz], [过滤 PID 的 D 项输入，减少舵机抖动和高频输出。],
  )
]

两项参数均可在 5 Hz—100 Hz 范围内设置，设为 0 表示关闭。截止频率越低，滤波越强，
但控制延迟也会增加。首次使用建议保留默认值；只有在确认传感器噪声或舵机抖动明显时，
再逐步降低截止频率。

== 混控设置

根据需要，增加或者减少电机(舵机)的数量。
每个电机有四项值，分别代表这个电机的输出中，各个通道的贡献系数。

电机的输出 = 油门 x 油门系数 + Roll输出x Roll系数 + Pitch输出 x Pitch系数 + Yaw输出 x Yaw 系数

Roll/Pitch/Yaw输出为PID的输出值

v0.9.3_e364 起，每一路混控输出可以单独选择 *电机* 或 *舵机*：

#image("assets/image-mixer-output-type.png", width: 100%)

- 电机输出以最小油门为基准，并受解锁条件控制。
- 舵机输出以 1500 us 中位为基准，不受电机解锁条件限制；加锁时仍可响应混控。

#caution[
  标记为舵机的混控输出在未解锁时也可能动作。调整混控系数或舵机行程前，应确保机构
  周围无人、舵面不受阻。
]

== 飞控正方向设置

#image("assets/image.png")
将飞控安装在飞机上之后，将飞机保持水平，点击采集水平姿态。

采集完成后，将飞机竖直向上，点击采集竖直姿态。即可完成正方向设置。

完成后，保存设置。

== 电压、姿态回传

在遥控器遥测页面发现新传感器，确认电压项目会随电池状态合理变化，再设置低电压。

固件会通过 CRSF 姿态遥测回传横滚和俯仰角，更新频率约为 10 Hz。重新发现传感器后，
可以在遥控器的遥测页面或支持姿态显示的部件中查看。当前偏航值固定为 0，不要将其用于
航向判断。

= 固件升级 <update>

由于配置器连接 LightFin Nano 时一般会没有互联网（除非使用AP模式）。
因此可以在未连接设备，有互联网时，先下载最新的固件到本地。等到连接设备后，再检查固件是否需要更新。

#image("assets/image-1.png")

= 电压回传修复
在早期的版本中，默认的电压回传使用2位小数的精度，与遥控器端的精度不匹配，遥控器显示电压会显示为10倍。
如需正常显示电压，需要在配置器中，进入 硬件JSON配置，修改 vbat_scale的值 从91 改为 #text(fill: red)[*910*]

#image("assets/vbat.png")


= 原理图 <schematic>

#figure(
  image("SCH_LightFin_Nano.pdf", width: 100%),
  caption: [LightFin Nano 原理图]
)
