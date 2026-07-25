#import "template.typ": *

#doc-config(
  header-title: "LightFin Nano Stabilized Receiver User Manual",
  version: "v1.1",
)

#set text(lang: "en", region: "us")
#set heading(numbering: "1.1")
#show heading: set block(above: 1.2em, below: 0.6em)
#show outline.entry: set par(leading: 1.2em)
#set page(
  header: context {
    if counter(page).get().first() > 1 [
      #set text(8pt, gray)
      #grid(
        columns: (1fr, 1fr),
        [LightFin Nano Stabilized Receiver User Manual],
        align(right)[Version: v1.1]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt + gray)
    ]
  },
  footer: context [
    #align(center, text(9pt, gray)[Page #counter(page).display()])
  ],
)

#let en-caution(body) = block(
  fill: rgb("#fff5f5"),
  stroke: (left: 4pt + red),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
  [*Caution:* #body],
)

#let en-tip(body) = block(
  fill: rgb("#f0f8ff"),
  stroke: (left: 4pt + blue),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
  [*Tip:* #body],
)

#let update-date = resolve_update_date(fallback: "July 14, 2026")

#align(center + horizon)[
  #block(inset: 3em)[
    #text(28pt, weight: "bold", fill: navy)[LightFin] \
    #v(0.4em)
    #text(18pt, weight: "medium")[LightFin Nano User Manual] \
    #v(1.2em)
    #text(11pt, gray)[ELRS receiver, six-channel mixing, and rate stabilization in one board]
  ]

  #placeholder(
    "LightFin Nano product and connector overview",
    img_path: "assets/lightfin-nano-pcb-top.png",
    height: 15em,
  )

  #v(1fr)
  #text(10pt, gray)[Document version: v1.1 | Last updated: #update-date] \
  #text(10pt, gray)[Applicable hardware: LightFin Nano stabilized receiver; firmware: v0.9.3_e364]
]

#pagebreak()
#outline(indent: 2em, depth: 2)
#pagebreak()

= Product Overview <intro>

*LightFin Nano*, developed by *HumpbackLab*, is a lightweight integrated receiver and control
module. It combines an ELRS receiver, six output channels, channel mixing, rate stabilization,
voltage telemetry, and brushed-motor drivers on a compact PCB. It is intended for fixed-wing and
other lightweight models where size, weight, and wiring must be kept to a minimum.

== Key Capabilities

#table(
  columns: (1.25fr, 2.8fr),
  inset: 8pt,
  align: horizon,

  [*Feature*], [*Description*],
  [Channel outputs], [Six channels of micro-servo output with configurable channel mixing.],
  [Brushed motor drivers], [Four channels can drive brushed motors, with a rated maximum current
    of 5 A per channel.],
  [Radio link], [Binds to ELRS 3.x transmitter modules.],
  [Stabilization], [Manual, Rate, and Angle modes with adjustable PID and input-filter settings.],
  [Output setup], [Configurable servo minimum, center, and maximum travel, plus output testing in
    Wi-Fi mode.],
  [Telemetry], [Battery voltage, roll attitude, and pitch attitude telemetry.],
  [Configuration], [Settings can be adjusted from the transmitter or the configurator.],
  [Firmware maintenance], [Firmware can be updated over Wi-Fi.],
)

#en-tip[
  LightFin Nano can also be used as a conventional ELRS receiver that supplies received data to an
  external flight controller. The hardware supports this use case, but you must solder the UART RX,
  UART TX, and other required signal wires yourself.
]

= Safety Information <safety>

#en-caution[
  Always remove the propeller and disconnect any powered load that could move unexpectedly before
  configuration, firmware updates, or output testing. The brushed outputs are rated for a maximum
  of 5 A per channel; this is not a recommended continuous operating current. Actual usable current
  also depends on the power supply, connectors, wire gauge, cooling, and ambient temperature.
]

= Hardware Overview and Connectors <hardware>

#figure(
  image("assets/lightfin-nano-pcb-top-annotated.png", width: 88%),
  caption: [LightFin Nano top-side connector labels]
)

#figure(
  image("assets/lightfin-nano-pcb-bottom-annotated.png", width: 88%),
  caption: [LightFin Nano bottom-side connector labels]
)

#en-caution[
  Connect brushed motors to the `PWMx` and `VBAT` pins of the first four channels (`M1`-`M4`).
  If you need to solder motor wires directly, use the metal pad strips on both sides of the
  `M1`-`M4` connectors.
]

= Quick Start <getting-started>

#block(
  fill: rgb("#e8f5e9"),
  stroke: (left: 4pt + green),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *Shortest path for first use*: Power on -> connect the configurator -> check for firmware updates
  -> set the ELRS binding phrase -> configure PWM, mixing, and board orientation -> check outputs
  at low power -> remove the propeller and complete the ground test.
]

== Connect the Configurator

1. Power on LightFin Nano. If it does not connect to a transmitter, wait approximately 60 seconds
   for it to enter Wi-Fi mode.
2. Before connecting to the receiver hotspot, it is strongly recommended that you
   #link(<update>)[#text(fill: red)[*check for updates*]] while you still have internet access.
3. Connect to the receiver hotspot. Its default name is usually `ExpressLRS RX`, and its default
   password is `expresslrs`.
4. Open `http://10.0.0.1` in the configurator.

== Set the ELRS Binding Phrase

Set the same unique *Binding Phrase* on the transmitter and LightFin Nano.

Enter a suitable binding phrase on the model page and save it.

#image("assets/image-2.png")

#en-tip[
  The UI does not display the binding phrase in plain text. When you enter a new phrase, the UI
  converts it to a UID and saves it. An empty input field on a later visit does not mean that the
  setting has been lost.
]

== Verify the Link

#table(
  columns: (1.4fr, 2.6fr),
  inset: 8pt,
  align: horizon,

  [*Single-color LED state*], [*Typical meaning*],
  [Slow blink (about 500 ms on/off)], [Waiting for a transmitter connection.],
  [Double blink], [Traditional binding mode is active.],
  [Fast blink (about 25 ms on/off)], [Wi-Fi mode is active.],
  [Solid], [Connected to the transmitter.],
)

= Configuration <configuration>

== PWM Channel Configuration

#image("assets/image-pwm.png")

Output mode:

- For brushed-motor output, select `10KhzDuty`.
- For servo output, select a frequency from 50 Hz to 400 Hz according to the servo specification.

Source:

- `RC`: Control the output directly from a transmitter channel.
- `Mixer`: Use the mixing logic configured in the configurator.

Failsafe behavior when the receiver is locked or the link is lost:

- For motors, `No pulses` is recommended.
- For servos, select a fixed position and set it to a neutral value such as 1500 us.

#en-caution[
  The first four channels support both motors and servos. When using them for servos, enable
  *Polarity inversion*.
]

=== Set Servo Travel

#image("assets/image-pwm-range.png", width: 100%)

For servo outputs from 50 Hz to 400 Hz, you can set the minimum, center, and maximum pulse widths
individually. The defaults are 1000 us, 1500 us, and 2000 us. The allowed range is
500 us-2500 us, and the values must satisfy minimum < center < maximum.

1. Confirm that the output uses a PWM frequency supported by the servo.
2. Make sure the servo arm and linkage can move freely, then adjust the center from its default.
3. Slowly adjust the minimum and maximum. Do not let the servo stall or drive the linkage beyond
   its mechanical limits.
4. Save the settings, then recheck the center and both endpoints.

#en-tip[
  Servo travel settings do not apply to `10KhzDuty` brushed-motor outputs.
]

=== Wi-Fi Output Test

#image("assets/image-pwm-wifi-test.png", width: 100%)

In Wi-Fi mode, you can enable output testing and directly specify the pulse width for each servo.
The test value is constrained by the minimum and maximum already configured for that output. Use
this feature to check servo center, direction, and mechanical travel.

#en-caution[
  The servo moves immediately when output testing is enabled. Remove the propeller and disconnect
  motors or other powered loads before testing. Disable output testing when finished; disabling it
  stops the servo PWM output.
]

== Flight Mode Configuration

#image("assets/image-mode.png")

Configure the arming channel and the activation channels and ranges for Rate and Angle modes.
Mode channels can be selected from CH5 through CH16. A mode becomes active when its channel value
falls within the configured range.

#table(
  columns: (1fr, 2.8fr),
  inset: 8pt,
  align: horizon,

  [*Mode*], [*Behavior*],
  [Manual], [No attitude correction. Stick inputs are sent directly to the mixer.],
  [Rate], [Controls roll, pitch, and yaw angular rates. Returning the sticks to center suppresses
    continued rotation.],
  [Angle], [Controls roll and pitch angles and returns the aircraft to level when the sticks are
    centered. Yaw remains rate-controlled.],
)

If neither the Rate nor Angle activation range is active, the system returns to Manual mode.
Do not overlap the two ranges. If they overlap, Angle mode has priority. During ground testing,
move the switch through each position and verify that each position activates only one mode.

== PID Settings

Configure the PID parameters for the selected mode. Typical parameter magnitudes for Rate mode are:

- `P`: 0-2
- `I`: 0-10
- `D`: 0-0.5
- `I_lim`: 0-10

For basic stabilization, PD control is usually sufficient.

=== Input Filters

Firmware v0.9.3_e364 adds two low-pass filter settings:

#image("assets/image-input-filters.png", width: 100%)

#block(breakable: false)[
  #table(
    columns: (1.2fr, 1fr, 2.2fr),
    inset: 8pt,
    align: horizon,

    [*Setting*], [*Default*], [*Purpose*],
    [Gyro LPF], [30 Hz], [Filters gyroscope angular-rate input to reduce vibration and noise
      entering the control loop.],
    [D-term LPF], [20 Hz], [Filters the PID D-term input to reduce servo jitter and
      high-frequency output.],
  )
]

Both settings accept values from 5 Hz to 100 Hz; 0 disables the filter. A lower cutoff frequency
provides stronger filtering but adds control latency. Keep the defaults for initial use. Reduce the
cutoff frequency gradually only after confirming significant sensor noise or servo jitter.

== Mixer Configuration

Add or remove motor or servo outputs as needed. Each output has four values representing the
contribution of each control axis:

#align(center)[
  Output = Throttle × throttle coefficient + Roll × roll coefficient \
  + Pitch × pitch coefficient + Yaw × yaw coefficient
]

The roll, pitch, and yaw values are the PID controller outputs.

Starting with v0.9.3_e364, each mixer output can be independently set to *Motor* or *Servo*:

#image("assets/image-mixer-output-type.png", width: 100%)

- A motor output is based on minimum throttle and is controlled by the arming state.
- A servo output is centered at 1500 us and is not disabled by the motor arming state. It can still
  respond to mixer input while disarmed.

#en-caution[
  Mixer outputs marked as servos may move while the system is disarmed. Before adjusting mixer
  coefficients or servo travel, keep people clear of the mechanism and make sure no control surface
  is obstructed.
]

== Set Flight Controller Orientation

#image("assets/image.png")

After installing LightFin Nano in the aircraft, hold the aircraft level and select the command to
capture the level attitude.

When capture is complete, point the aircraft vertically upward and select the command to capture
the vertical attitude. This completes the orientation setup.

Save the settings when finished.

== Voltage and Attitude Telemetry

Discover new sensors from the transmitter telemetry page. Confirm that the voltage reading changes
reasonably with battery state before configuring the low-voltage alarm.

The firmware reports roll and pitch through CRSF attitude telemetry at approximately 10 Hz.
Rediscover the sensors, then view the values on the transmitter telemetry page or in a widget that
supports attitude display. The current yaw value is fixed at 0 and must not be used for heading.

= Firmware Update <update>

The computer or phone normally has no internet access while connected to LightFin Nano, unless AP
mode is used. While disconnected from the receiver and connected to the internet, first download
the latest firmware locally. After reconnecting to the receiver, check whether an update is needed.

#image("assets/image-1.png")

= Schematic <schematic>

#figure(
  image("SCH_LightFin_Nano.pdf", width: 100%),
  caption: [LightFin Nano schematic]
)
