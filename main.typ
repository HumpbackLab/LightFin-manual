#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  numbering: "1",
)

// 设置字体，优先使用开源字体，回退到常见系统字体
#set text(
  font: ("Source Han Sans SC", "SimHei", "Microsoft YaHei", "PingFang SC"),
  lang: "zh",
  size: 11pt,
  region: "cn"
)

#show heading: set text(weight: "bold")
#show heading.where(level: 1): it => [
  #set align(center)
  #set text(size: 18pt)
  #block(below: 1em)[#it]
]
#show heading.where(level: 2): it => [
  #set text(size: 14pt)
  #block(above: 1.5em, below: 0.8em)[#it]
]

// 定义警告块样式
#let caution(body) = {
  block(
    fill: rgb("#ffe6e6"),
    stroke: (left: 4pt + red),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    [*注意：* #body]
  )
}

// 定义提示块样式
#let tip(body) = {
  block(
    fill: rgb("#e6f7ff"),
    stroke: (left: 4pt + blue),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    [*提示：* #body]
  )
}

// --- 文档开始 ---

= 基于 iNav 与 ELRS 的差速纸飞机新手制作指南
#align(center)[版本: 1.0 | 适用固件: iNav Custom / 1S AIO]

== 1. 项目简介与准备工作

本项目将指导你制作一架拥有“大脑”的纸飞机。不同于普通纸飞机，它可以通过遥控器控制双电机的转速差（差速）来实现转向和爬升。

=== 1.1 硬件清单 (BOM)

请确保你拥有以下硬件：

- *飞控 (Flight Controller):* 推荐 F411 或 F405 1S AIO (一体板)。
  - _要求：_ 需集成 1S 供电接口，至少 2 个 UART 串口。
- *动力系统:*
  - 电机: 0802 无刷电机 或 8520 空心杯电机 (x2)。
  - 螺旋桨: 40mm 或 65mm 桨叶 (需区分正反桨 CW/CCW)。
- *接收机 (Receiver):* ELRS Nano/EP1/EP2 接收机 (陶瓷天线版最适合纸飞机)。
- *电源:* 1S LiPo 电池 (300mAh - 500mAh)，PH2.0 接口。
- *机身:* 硬卡纸、KT板或折纸模型。
- *辅助工具:* 电烙铁、焊锡、热熔胶、Type-C 数据线。

=== 1.2 软件准备

请在电脑上下载并安装：
1. *iNav Configurator:* 用于设置飞控参数。
2. *STM32 VCP Drivers:* 飞控驱动程序。
3. *ImpulseRC Driver Fixer:* 如果电脑无法识别飞控，使用此工具修复。

---

== 2. 硬件组装与焊接

#caution[焊接时请务必拔掉电池！电烙铁高温，请注意安全。]

=== 2.1 飞控板方向确认
飞控板上通常印有一个 *白色箭头*。
- *安装原则：* 箭头的指向必须与飞机的 *机头方向* 一致。
- *固定：* 使用双面胶或热熔胶将飞控固定在机身重心附近（通常在机翼前缘后方约 1/3 处）。

=== 2.2 电机接线 (差速布局)
你需要将两个电机分别连接到飞控的电机焊盘。
- *左电机 (Left Motor):* 焊接到飞控的 *M1* 焊盘 (信号/正/负)。
- *右电机 (Right Motor):* 焊接到飞控的 *M2* 焊盘 (信号/正/负)。

_注：如果是空心杯电机，注意正负极（红蓝线或黑白线）；如果是无刷电机，三根线任意焊，后续可通过软件调整转向。_

=== 2.3 ELRS 接收机接线
ELRS 接收机通常有 4 根线，需要连接到飞控的一个空闲串口（例如 UART1 或 UART2）。假设使用 UART1：

#table(
  columns: (1fr, 1fr, 2fr),
  inset: 8pt,
  align: horizon,
  [*接收机 (ELRS)*], [*飞控 (FC)*], [*说明*],
  [5V], [5V / 4V5], [供电正极],
  [GND], [GND], [供电地线],
  [TX], [*RX1*], [*关键：TX 接 RX*],
  [RX], [*TX1*], [*关键：RX 接 TX*],
)

---

== 3. 固件烧录 (Flashing)

我们需要将自定义的 iNav 固件写入飞控。

1. 打开 *iNav Configurator*。
2. 将飞控按住 *Boot 按键* (通常是板上唯一的按钮) 不放，插入 USB 线连接电脑。
   - 此时软件右上角应显示 `DFU` 字样。
3. 点击左侧菜单的 *Firmware Flasher*。
4. *加载固件：*
   - 如果是官方支持的板子，在下拉菜单选择型号。
   - *如果是自定义固件：* 点击右下角的 `Load Firmware [Local]`，选择你下载好的 `.hex` 文件。
5. 开启 `Full Chip Erase` (全片擦除)。
6. 点击 *Flash Firmware*。等待进度条走完，飞控会自动重启。

---

== 4. 基础参数配置

点击右上角 `Connect` 连接飞控。

=== 4.1 传感器校准 (Calibration)
将飞机水平放置在桌面上，点击 *Calibration* 标签页，点击 `Calibrate Accelerometer`。确保 3D 模型是平的。

=== 4.2 混控设置 (Mixer) - *核心步骤*
这是差速飞机最关键的一步。

1. 进入 *Mixer* 标签页。
2. 在 Platform Configuration 中选择 *Airplane* (固定翼)。
3. 由于我们没有舵机，依靠电机差速，我们需要自定义混控（或选择 Flying Wing 预设并修改）：
   - *Motor 1 (左电机):* Throttle (油门) 100%, Yaw (偏航) -50%, Roll (横滚) 0%。
   - *Motor 2 (右电机):* Throttle (油门) 100%, Yaw (偏航) +50%, Roll (横滚) 0%。
   
#tip[对于简单的纸飞机，通常只需要控制油门和方向（Yaw）。当你想左转时，右电机转速>左电机。你可以根据实际飞行效果调整 Yaw 的权重。]

=== 4.3 端口与接收机设置
1. 进入 *Ports* 标签页。
   - 找到你焊接接收机的端口（如 UART1），在 *Serial Rx* 开关上打勾。
   - 点击右下角 Save and Reboot。
2. 进入 *Receiver* 标签页。
   - Receiver Type 选择: `Serial (via UART)`。
   - Serial Receiver Provider 选择: `CRSF` (ELRS 使用 CRSF 协议)。
   - 打开遥控器，如果接线正确，你应该能看到通道条在跳动。

=== 4.4 飞行模式 (Modes)
1. 进入 *Modes* 标签页。
2. 设置 *ARM* (解锁)：分配给一个拨杆（如 AUX1）。
3. 设置 *ANGLE* (自稳模式)：分配给一个拨杆（如 AUX2）。
   - *强烈建议新手全程使用 Angle 模式起飞。*

---

== 5. 起飞前检查 (Pre-flight Check)

=== 5.1 电机转向检查
1. 此时 *不要* 安装螺旋桨。
2. 在 Outputs 标签页开启 `I understand the risks`。
3. 单独推 M1 推杆，触摸电机外壳确认转向。
   - 此时安装螺旋桨，确保风是 *向后吹* 的。
   - 如果风向前吹，需要更换正反桨，或者在电机配置里反转电机方向（如果是 DSHOT 电调）。

=== 5.2 重心 (CG) 检查
用手指支起机翼下方约 1/3 处。
- 飞机应该轻微低头或保持水平。
- *严禁屁股沉（重心靠后）*，否则飞机起飞后会无法控制地抬头并失速坠毁。

=== 5.3 故障排查 (OSD/状态)
在 Setup 页面，查看右侧的 *Arming Flags*。
- 只有显示 `MSP` (连接了电脑) 是正常的。
- 如果有 `CALIB`，请重新校准。
- 如果有 `RX`，请检查接收机是否连接。

#block(
  fill: luma(240),
  inset: 15pt,
  radius: 5pt,
  [*最后一步：* 拔掉 USB，插上电池，带上遥控器，去户外草坪进行首飞！起飞时油门推至 60% 左右，手掷起飞。]
)