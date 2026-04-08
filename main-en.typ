#import "template.typ": *

#doc-config(
  header-title: "LightFin INAV Flight Controller User Manual",
  version: "v1.0",
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
        [LightFin INAV Flight Controller User Manual],
        align(right)[Version: v1.0]
      )
      #v(-0.5em)
      #line(length: 100%, stroke: 0.5pt + gray)
    ]
  },
  footer: context [
    #align(center, text(9pt, gray)[Page #counter(page).display()])
  ],
)

#let update-date = resolve_update_date()

#cover-page(
  main-title: "LightFin INAV Flight Controller User Manual",
  subtitle: "An all-in-one INAV flight controller solution for lightweight fixed-wing and 1S platforms",
  doc-version: "v1.0",
  update-date: update-date,
  hardware-info: "Applicable hardware: LightFin Flight Controller (AT32F435mini hardware platform, custom INAV firmware)",
)

= Product Overview <intro>

*LightFin* is a lightweight fixed-wing flight controller product developed by *HumpbackLab*.

== Positioning and Intended Platforms
*LightFin* (hardware platform: AT32F435mini) is an ultra-compact flight controller built for *INAV*. It integrates an *AT32F435* MCU and an onboard *ELRS* (ExpressLRS, an open-source low-latency RF link). It is designed for 1S-powered lightweight fixed-wing and experimental platforms. The onboard IMU, barometer, and magnetometer provide the basic sensing needed for attitude stabilization, heading estimation, and altitude awareness.

== Key Hardware Features
#table(
  columns: (1.2fr, 2fr, 2.2fr),
  inset: 8pt,
  align: horizon + center,

  [*Module*], [*Part / Device*], [*Description*],

  [Main MCU], [AT32F435CGU7], [QFN48 package with onboard SWD debug access and multiple UART/PWM resources],
  [Radio link], [ESP8285 + SX1280], [Onboard ELRS RF link with SPI control of the RF chip; dual-antenna layout for Wi-Fi and ELRS],
  [IMU], [LSM6DSOWTR], [SPI1 bus for accelerometer and gyroscope data],
  [Magnetometer], [QMC5883P], [I2C2 bus, address 0x2C],
  [Barometer], [SPL06-001], [I2C2 bus, address 0x77],
  [Power management], [TPS22975 + TPS63001], [Load switch plus buck-boost power supply],
)

== Typical Use Cases and Advantages
- *Lightweight fixed-wing platforms*: Well suited to compact 1S fixed-wing builds with tight size and weight constraints.
- *1S power systems*: The onboard power architecture is designed for 1S LiPo input and reduces the need for external modules.
- *Integrated ELRS*: No external receiver is required, which reduces wiring complexity and total weight.

= Hardware Overview <hardware>

#figure(image("assets/annotation_01.aggressive-plus.jpg", width: 90%), caption: [Top-side PCB layout])
#figure(image("assets/annotation_02.aggressive-plus.jpg", width: 90%, height: 10cm), caption: [Bottom-side PCB layout])

== Board Orientation

When installing the flight controller, use the board direction marking as the reference. Make sure the forward direction of the FC matches the forward direction of the aircraft, and keep the mounting surface as level as possible.

#figure(image("assets/pcb-bottom-view-with-arrow.png", width: 90%), caption: [Flight controller orientation marking])

== LEDs and Switch
- *Status LEDs*: The board has three status LEDs. Two are driven by the MCU, and one is driven by the ESP (`ELRS_LED`).
- *Power / function switch*: An onboard slide switch is used for power control.

== Mechanical Dimensions
- *PCB size*: approximately 30.2 mm x 14.6 mm
- *Board thickness*: 0.8 mm
- *Mounting holes*: 4 x M2 screw holes

= Quick Start <getting-started>

This chapter is intended for end users who receive a finished LightFin flight controller and need to complete first-time connection, basic configuration, and functional checks. LightFin ships with INAV and ELRS firmware preinstalled.

#block(
  fill: rgb("#e8f5e9"),
  stroke: (left: 4pt + green),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  *Shortest path for first use*: If the seller has already preconfigured the FC parameters, you only need to complete power wiring, ELRS binding, and receiver response checks before installing it into the aircraft.

  You only need to connect the board to a computer when you want to calibrate sensors, change output settings, inspect the link, or reflash firmware.
]

== Step 1: Install INAV Configurator

INAV Configurator is the desktop application used to configure the flight controller. It is available for Windows, macOS, and Linux.

1. Visit the official download page:
   - *GitHub Releases*: #link("https://github.com/iNavFlight/inav-configurator/releases")[https://github.com/iNavFlight/inav-configurator/releases]
   - Download the latest release for your operating system, such as `INAV-Configurator_win64_9.0.0.exe`.
2. Install and launch INAV Configurator.
3. On first launch, Windows may prompt you to install a serial driver. Follow the prompts if needed.

== Step 2: Connect the Flight Controller

This section describes the two supported connection methods. Use wireless configuration when you only need basic setup. Use USB-to-TTL wired configuration when you need a stable serial link, deeper debugging, or flashing.

=== Option 1: Wireless Configuration

1. Power on the flight controller. After 60 seconds, ELRS will automatically start a Wi-Fi hotspot named `ExpressLRS RX`.
2. Connect your computer to that hotspot. The default password is `expresslrs`.
3. In INAV Configurator, connect via TCP using `10.0.0.1:5761`.
4. Once connected, you can proceed with configuration.

=== Option 2: Wired Configuration (USB-to-TTL Required)

#tip[Serial connection is only needed for advanced setup and debugging. If the FC is already preconfigured and you only need binding and basic checks, you can skip this method.]

Use the included SH1.0 4-pin cable to connect a USB-to-TTL adapter to your computer. Do not connect the battery during wired setup. If a battery is already connected, keep the flight controller power switch turned off.

#caution[If your computer cannot detect the serial port, make sure the USB-to-TTL adapter driver is installed correctly.]

==== Required Items

#table(
  columns: 3,
  rows: 2,
  inset: 8pt,
  align: horizon + center,

  [#image("assets/usb-to-ttl.aggressive-plus.jpg", width: 80%)],
  [#image("assets/sh1.0-to-2.54.aggressive-plus.jpg", width: 80%)],
  [#image("assets/battery.aggressive-plus.jpg", width: 80%)],
  [3.3V USB-to-TTL adapter], [SH1.0-4Pin to Dupont cable], [1S LiPo battery],
)

==== Wiring
The *UART1 connector* on the front side of the FC (SH1.0-4Pin) is used for connection to the configurator:

#table(
  columns: (1fr, 1fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*FC pin*], [*Connect to*], [*Description*],
  [Pin 1 (VBAT)], [Adapter 5V], [FC power input],
  [Pin 2 (GND)], [Adapter GND], [Ground],
  [Pin 3 (RX)], [Adapter TX], [FC receive line, connected to computer transmit],
  [Pin 4 (TX)], [Adapter RX], [FC transmit line, connected to computer receive],
)

#figure(image("assets/annotation_06.aggressive-plus.jpg", width: 100%, fit: "stretch"), caption: [USB-to-TTL wiring to FC UART1])

#caution[Cross TX and RX: connect the FC RX pin to the adapter TX pin, and the FC TX pin to the adapter RX pin.]

==== Connection Procedure

#figure(image("assets/inav-config-connect.aggressive-plus.png", width: 90%), caption: [Connection screen])
1. Wire the FC according to the table above, then plug the USB-to-TTL adapter into your computer.
2. Open INAV Configurator and select the correct serial port in the upper-left corner, such as `COM3` or `/dev/ttyUSB0`.
3. Leave the baud rate at the default value of *115200* and click *Connect*.
4. When the connection succeeds, you will enter the configuration interface.

#caution[Do not connect motors during the initial setup wizard. INAV may enable outputs under the default configuration, which can make connected motors spin unexpectedly and potentially trip USB protection or cause injury. Connect real loads only after output mode has been verified.]

== Step 3: Initial Setup Wizard

When you connect the FC for the first time, INAV Configurator opens a setup wizard to help you complete the basic configuration.

#figure(image("assets/inav-config-default-values.aggressive-plus.jpg", width: 80%), caption: [INAV Configurator initial wizard - airframe selection])

In the setup wizard:
1. Set *Platform type* to *Airplane*.
2. Choose a *Mixer preset* that matches your actual airframe. If you are only performing a basic connectivity test, you can keep the default preset for now and adjust it later.

#figure(image("assets/inav-config-receiver-wizard.aggressive-plus.jpg", width: 80%), caption: [INAV Configurator initial wizard - receiver setup])

Receiver configuration:
+ Set *Serial Receiver Provider* to *CRSF*.
+ Set *Receiver UART* to *UART7*.
+ Click `Next` in the lower-right corner.

#figure(image("assets/inav-config-platform-type-selection.aggressive-plus.jpg", width: 80%), caption: [INAV Configurator initial wizard - GPS page])

The wizard will apply settings according to the platform type you selected.
The flight controller will save the configuration and reboot automatically.

After the initial wizard completes, the *Status* page shows the overall state of the flight controller. Make sure the sensor indicators on the left (gyro, accelerometer, magnetometer, and barometer) are blue, which indicates that the hardware is detected correctly. At this point, the *Pre-arming checks* list on the right may still contain red X marks, for example because sensors are not calibrated yet or flight modes are not configured. That is normal. Those items will be addressed in the following steps.

#figure(image("assets/inav-config-status-page.aggressive-plus.jpg", width: 90%), caption: [Status page])

=== Sensor Calibration

Next, calibrate the accelerometer and magnetometer. These sensors provide attitude and heading information. In the left navigation bar of INAV Configurator, open the *Calibration* page.

First, calibrate the accelerometer by clicking the *Calibrate Accelerometer* button.

#figure(image("assets/inav-calibration-start.aggressive-plus.jpg", width: 90%), caption: [Start of accelerometer calibration])

Place the FC on a level surface in each of the six orientations: top side up, bottom side up, left side up, right side up, nose up, and tail up. After each orientation is stable, click the calibration button again until all gray squares in the UI are filled.

#figure(image("assets/inav-calibration-accel-done.aggressive-plus.jpg", width: 90%), caption: [Accelerometer calibration completed])

After the accelerometer has been calibrated, proceed with the magnetometer (*Compass*) calibration. Click *Calibrate Compass*, then for 30 seconds slowly rotate the FC in the air so that every face of the board points downward at some point. This allows the magnetometer to learn the magnetic field from all directions.

#tip[Keep the flight controller away from magnets and strong electromagnetic interference during calibration, or the result may be inaccurate.]

#figure(image("assets/inav-calibration-compass-done.aggressive-plus.jpg", width: 90%), caption: [Compass calibration completed])

When the magnetometer calibration is done, click *Save and Reboot* in the lower-right corner to store the calibration data and reboot the FC.

After rebooting, return to the *Status* page and verify that the sensors look healthy, the displayed attitude is reasonable, and the *Pre-arming checks* list contains no critical issues that would block arming.

#figure(image("assets/inav-prearm-green.aggressive-plus.jpg", width: 90%), caption: [Pre-arm checks passed])

=== Configure Output Mode

Before connecting any real load, check the INAV output mode to make sure it matches your hardware. This avoids accidental motion or incorrect output behavior under the default configuration.

#caution[
  Do not connect motors before completing this section.
]

If your LightFin build uses brushed motors, configure the outputs as follows:

1. Connect the FC in INAV Configurator.
2. Open the *Outputs* page from the left navigation bar.

#figure(
  image("assets/inav-outputs-page.aggressive-plus.jpg", width: 90%),
  caption: [Outputs page]
)
#tip[
  LightFin has no current-sense circuit. The current value shown on the Outputs page is meaningless and can be ignored. When a battery is connected, the voltage field should show the actual battery voltage.
]

3. Turn on *Enable motor and servo output*.
4. Set *ESC protocol* to *BRUSHED*.

#figure(
  image("assets/inav-outputs-enable-brushed.aggressive-plus.png", width: 90%),
  caption: [Enable outputs and set BRUSHED mode]
)

5. Click *Save and Reboot*. After the FC restarts, reconnect and verify that the setting has taken effect.

== Step 4: Receiver and Link Check

The LightFin FC includes an onboard ELRS receiver and must be bound to your ELRS transmitter. After binding, go back to INAV Configurator and verify receiver response on the *Receiver* page.

#block(
  fill: rgb("#fff8e1"),
  stroke: (left: 4pt + orange),
  inset: 12pt,
  radius: 4pt,
  width: 100%,
)[
  Set the same binding phrase on the transmitter side. After the FC is powered on, it will connect automatically. Once binding succeeds, the transmitter should report the connection and the ELRS LED on the FC should change from slow blinking to solid on.
]

=== Set the Binding Phrase on the Transmitter

*Use the Lua script to put the TX module into Wi-Fi mode*:
   - Long-press *SYS* to enter the system menu and open the *ELRS* Lua script.
   - Enter *WIFI Connectivity*.
   - Select *Enable WIFI*.
   - Use a phone or computer to connect to the hotspot created by the transmitter. The default SSID is `ExpressLRS TX`, and the default password is `expresslrs`.
   - Open `http://10.0.0.1` in a browser, enter the desired binding phrase, and save it.

=== Verify Successful Binding
1. Power on the FC and observe the ELRS LED:
   - *Slow blink (500 ms on/off)*: waiting for connection
   - *Fast blink (25 ms on/off)*: Wi-Fi mode
   - *Solid on*: connected
   - Official reference: #link("https://www.expresslrs.org/quick-start/led-status/#receivertransmitter-led-status")[ExpressLRS LED Status]
2. Power on the transmitter and wait a few seconds. The LED should become solid on.

#tip[
  If binding fails, check the following in order:
  + The binding phrase on the transmitter and receiver must match exactly, including letter case.
  + The major ELRS firmware version must match on both sides. Using ELRS 3.x on both sides is recommended.
]

=== Update ELRS Firmware over Wi-Fi
Factory firmware is already installed, so an update is usually unnecessary. If you do need to update ELRS:

1. Power on the FC. If no transmitter connects within 60 seconds, ELRS will automatically start a Wi-Fi hotspot named `ExpressLRS RX`.
2. Connect your computer to that hotspot. The default password is `expresslrs`.
3. Open `http://10.0.0.1` in a browser to enter the ELRS Web UI.
4. Upload the new `.bin` firmware file and wait for the reboot to complete.

#caution[Wi-Fi update applies only to the ELRS firmware. INAV firmware on the AT32 MCU must be flashed through the dedicated MCU update flow described later in this manual.]

== Step 5: Functional and Safety Checks

=== Configure an Arm Switch
+ Open the *Modes* page.
+ Find *ARM* and click *Add Range*.
+ Select a switch channel from the transmitter, such as CH5, and set an activation range such as 1800-2100.
  - Make sure the channel mapping on the transmitter side is already configured correctly, and verify in the *Receiver* page that channel values behave as expected.
+ Save the configuration.

#figure(
  image("assets/inav-modes-arm-range.aggressive-plus.jpg", width: 90%),
  caption: [ARM mode range setup]
)

=== Output and Sensor Checks

#figure(
  image("assets/inav-outputs-motor-enable-control.aggressive-plus.jpg", width: 90%),
  caption: [Outputs page with output control enabled]
)

#caution[
  Before performing any output test, remove propellers or any other dangerous load and make sure the aircraft cannot injure anyone if a motor starts turning.
]

Before installing the FC into a final airframe, complete at least the following checks:

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  align: horizon,

  [☐], [The accelerometer is calibrated and the Setup page shows level attitude when the FC is placed level],
  [☐], [The transmitter is bound and stick movement is visible on the Receiver page],
  [☐], [The output mode matches the actual hardware, for example BRUSHED mode for brushed motors],
  [☐], [The Outputs page can identify and drive the intended output channels correctly],
  [☐], [An ARM switch is configured and can arm / disarm as expected],
  [☐], [Battery voltage is normal and the FC power supply is stable],
  [☐], [The Status page shows no critical issues blocking arming],
)

#pagebreak()

= Advanced Setup and Firmware Flashing <quick-start>

This chapter is intended for users who need to reflash firmware or perform deeper debugging work.

== Unboxing Checks and Preparation
#caution[Before first power-on, inspect solder joints and connector orientation carefully and make sure there are no shorts, reversed connections, or cold joints.]

- Inspect the PCB, connectors, and switch for visible damage.
- Prepare the required tools: a DAP Link or compatible SWD debugger, a 3.3V USB-to-UART adapter, flashing clip, and a 1S LiPo battery.

== Key Interfaces
#figure(image("assets/annotation_01.aggressive-plus.jpg", width: 100%), caption: [Top-side connection reference])

=== Installation Orientation Requirements
- Follow the direction marking on the PCB and make sure the FC coordinate system matches the forward direction of the aircraft.
- Keep the mounting surface as level as possible and avoid obvious tilt.
- Soft mounting with foam or soft adhesive is recommended to reduce high-frequency vibration seen by the IMU.

=== Power Input (MX1.25-2Pin)
- *VIN*: battery positive input
- *GND*: battery negative input

=== Motor Outputs
- *PWM1 / PWM2 (2-pin)*: intended for brushed motors
- *PWM3 / PWM4 (3-pin)*: can be used for motor or servo wiring

=== UART Connections
- *UART1*: front-side SH1.0-4Pin connector for configurator access
- *ELRS / CRSF UART*: used for ELRS communication and internally connected between AT32 UART7 and ELRS UART0; also used for ESP8285 / ELRS flashing
- *UART5*: spare UART broken out to test pads

== Firmware Flashing

=== ESP8285 ELRS Firmware
1. Power on the FC. If no transmitter binds within 60 seconds, the ESP8285 automatically enters Wi-Fi mode and creates an `ExpressLRS RX` hotspot.
2. Connect your computer to the hotspot. The default password is `expresslrs`.
3. Open `10.0.0.1` in a browser to enter the ELRS Web UI and upload the corresponding firmware there.

=== AT32 INAV Firmware
1. Short the required pads with tweezers to enter MCU flashing mode, then power on the FC.
2. Two common methods can be used:
  - *Method 1*: Keep the pads shorted and immediately connect the USB-to-TTL adapter to the computer. No battery is needed. This is convenient when connecting to the computer is easy.
  - *Method 2*: Connect the battery first, keep the pads shorted, and immediately turn on the FC power switch. Then connect the USB-to-TTL adapter to the computer more slowly. In this mode, *do not* connect the USB-to-TTL power wire to the FC.
3. Check the LED behavior after power-on:
  - Under normal power-up, the two LEDs on the board blink.
  - If the two LEDs still blink after power-up with the pads shorted, the board did not enter flashing mode correctly. Power off and try again.
4. Once the board is in flashing mode, open #link("https://humpbacklab.github.io/AT32-WebISP/")[AT32-WebISP] in a browser.
5. Select the correct serial port and firmware file in the web tool, then follow the prompts to flash the AT32 MCU firmware.

= Detailed Technical Specifications <specs>

== Sensors and Bus Addresses
#table(
  columns: (1.3fr, 1.6fr, 1.2fr, 1.4fr),
  inset: 8pt,
  align: horizon + center,

  [*Sensor*], [*Model*], [*Bus*], [*Address / Chip Select*],

  [IMU], [LSM6DSOWTR], [SPI1], [SPI1_CS + IMU_INT],
  [Magnetometer], [QMC5883P], [I2C2], [0x2C],
  [Barometer], [SPL06-001], [I2C2], [0x77],
)

== Interfaces and Pin Definitions

=== UART Resource Allocation (Summary)
#table(
  columns: (1fr, 1.6fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*UART*], [*Usage*], [*Notes*],
  [UART1], [MSP / CLI configurator access], [Connected through U12],
  [UART5], [Spare UART], [Available on TP7 / TP18 test pads],
  [UART7], [Internal ELRS / CRSF link], [Used by onboard ELRS and also for ESP8285 flashing],
)

=== 3-Pin Power / Servo Connectors (CN1 / CN2, HC-1.25-3PWT)
#table(
  columns: (1fr, 1fr, 1.2fr, 2fr),
  inset: 8pt,
  align: horizon + center,

  [*Connector*], [*Pin*], [*Net*], [*Description*],
  [CN1], [1], [PWM3], [Signal output for motor / servo],
  [CN1], [2], [VBAT], [Positive supply],
  [CN1], [3], [GND], [Ground],
  [CN2], [1], [PWM4], [Signal output for motor / servo],
  [CN2], [2], [VBAT], [Positive supply],
  [CN2], [3], [GND], [Ground],
)

= Debugging Notes and Warnings <debug>

- *ELRS / CRSF serial link*: UART7 is occupied by default. Avoid reusing it for external peripherals.
- *Power safety*: The board is designed for 1S LiPo input. Do not exceed the rated voltage of the load switch.
- *Motor safety*: When debugging brushed motors, do not install propellers or other hazardous loads.

= Troubleshooting <troubleshooting>

== Connection Issues

*Q: INAV Configurator cannot connect to the FC*
- Make sure the USB-to-TTL adapter driver is installed correctly. On Windows, a COM port should appear in Device Manager.
- Confirm that TX and RX are crossed correctly: FC RX to adapter TX, FC TX to adapter RX.
- Try a different USB cable or USB port.
- Make sure the baud rate is set to 115200.

*Q: I get garbled text or no response after connecting*
- Verify that the adapter is using 3.3V TTL logic. Some adapters default to 5V and require a jumper change.
- Confirm that the FC is powered correctly and the LEDs are active.

== Binding Issues

*Q: The transmitter cannot bind to the FC*
- Confirm that both sides use compatible ELRS firmware versions. ELRS 3.x on both sides is recommended.
- Confirm that the binding phrase matches exactly on both sides.
- Use the ELRS Web UI over Wi-Fi to inspect the receiver state if needed.

*Q: Binding succeeds but the Receiver page shows no stick response*
- Check that UART7 is configured as *Serial Rx* in INAV.
- Check that *Serial Receiver Provider* is set to *CRSF* on the Receiver page.

== Motor Issues

*Q: Motors do not spin after arming*
- Verify motor wiring, including both the PWM signal side and the power side.
- Make sure the intended motor outputs are enabled on the Outputs page.
- Check that the throttle stick is at minimum. Some safety settings require zero throttle before arming.
- Check whether any safety lock is still active, for example due to missing accelerometer calibration.

*Q: Motor rotation direction is wrong*
- For brushed motors, reverse the direction by swapping the two motor wires.
- Verify that output channel mapping and wiring match the intended motor assignment.

== Sensor Issues

*Q: Accelerometer calibration fails*
- Make sure the FC is completely still and level during each calibration step.
- Avoid performing the calibration in a vibrating environment, for example on a desk affected by a computer fan.
- Reboot the FC and try again.

*Q: The magnetometer or barometer shows red status*
- Check for interference. Keep the board away from strong magnetic fields and avoid direct heating of the barometer.
- In some cases the sensors need a short warm-up period. Wait a few seconds and check again.

= Glossary <glossary>

#table(
  columns: (1fr, 3fr),
  inset: 10pt,
  align: horizon,

  [*Term*], [*Description*],
  [INAV], [An open-source flight-control firmware that supports fixed-wing, multirotor, and other vehicle types, with features such as stabilization and navigation.],
  [ELRS], [ExpressLRS, an open-source low-latency RF communication protocol used between transmitter and flight controller.],
  [CRSF], [Crossfire protocol, the serial protocol format used by ELRS.],
  [MSP], [MultiWii Serial Protocol, used for communication between the flight controller and configurator.],
  [CLI], [Command Line Interface, used for advanced configuration and debugging.],
  [SWD], [Serial Wire Debug, the ARM debugging and flashing interface.],
  [IMU], [Inertial Measurement Unit, a sensor package containing an accelerometer and gyroscope.],
  [Binding], [The pairing process that establishes a link between the transmitter and receiver.],
  [Arm / Disarm], [The action that enables or disables motor output from the flight controller.],
)
