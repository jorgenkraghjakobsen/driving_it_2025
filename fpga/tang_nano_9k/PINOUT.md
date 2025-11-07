# Tang Nano 9K Pinout - Driving IT 2025

Complete pin assignment for the VGA/HDMI display project on Tang Nano 9K.

## Device Information

- **FPGA**: Gowin GW1NR-LV9QN88PC6/I5
- **Package**: QFN88
- **Family**: GW1N-9C

## Pin Assignments

### Clock Input

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| clk_27mhz | 52 | LVCMOS33 | 27 MHz onboard oscillator |

### Reset/Control

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| btn_rst | 4 | LVCMOS18 | Reset button S2 (active low) |

### HDMI Output (Differential Pairs)

#### TMDS Clock

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| tmds_clk_p | 69 | LVCMOS33D | HDMI clock positive |
| tmds_clk_n | 70 | LVCMOS33D | HDMI clock negative |

#### TMDS Data Channel 0 (Blue + Sync)

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| tmds_data_p[0] | 71 | LVCMOS33D | Blue channel positive (includes HSYNC/VSYNC) |
| tmds_data_n[0] | 72 | LVCMOS33D | Blue channel negative |

#### TMDS Data Channel 1 (Green)

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| tmds_data_p[1] | 73 | LVCMOS33D | Green channel positive |
| tmds_data_n[1] | 74 | LVCMOS33D | Green channel negative |

#### TMDS Data Channel 2 (Red)

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| tmds_data_p[2] | 75 | LVCMOS33D | Red channel positive |
| tmds_data_n[2] | 76 | LVCMOS33D | Red channel negative |

### Debug LEDs

| Signal | Pin | I/O Type | Description |
|--------|-----|----------|-------------|
| led[0] | 10 | LVCMOS18 | PLL lock indicator (always ON) |
| led[1] | 11 | LVCMOS18 | Reset released indicator |
| led[2] | 13 | LVCMOS18 | HSYNC signal (blinks rapidly) |
| led[3] | 14 | LVCMOS18 | VSYNC signal (blinks ~60Hz) |
| led[4] | 15 | LVCMOS18 | Display enable signal |
| led[5] | 16 | LVCMOS18 | Color active (ON when displaying text) |

## Pin Configuration Details

### I/O Standards

- **LVCMOS33**: 3.3V single-ended I/O
- **LVCMOS18**: 1.8V single-ended I/O
- **LVCMOS33D**: 3.3V differential pairs

### Drive Strength

- **HDMI Pins**: 8 mA drive strength
- **LED Pins**: 8 mA drive strength
- **Clock Input**: Pull-up enabled
- **Reset Button**: Pull-up enabled

### Pin Characteristics

**HDMI Differential Pairs:**
- No pull-up/pull-down resistors
- 8 mA drive for signal integrity
- Paired routing for differential signals

**LEDs:**
- Active high (LED on when signal = 1)
- Internal pull-up enabled
- 8 mA drive current

**Buttons:**
- Active low (pressed = 0)
- Internal pull-up enabled
- Debouncing handled in HDL

## Physical Connector Mapping

### HDMI Connector (J5)

The Tang Nano 9K has an HDMI connector with the following standard pinout:

```
Pin  1: TMDS Data2+  (Red+)    → tmds_data_p[2]
Pin  2: TMDS Data2-  (Red-)    → tmds_data_n[2]
Pin  3: TMDS Data2 Shield
Pin  4: TMDS Data1+  (Green+)  → tmds_data_p[1]
Pin  5: TMDS Data1-  (Green-)  → tmds_data_n[1]
Pin  6: TMDS Data1 Shield
Pin  7: TMDS Data0+  (Blue+)   → tmds_data_p[0]
Pin  8: TMDS Data0-  (Blue-)   → tmds_data_n[0]
Pin  9: TMDS Data0 Shield
Pin 10: TMDS Clock+            → tmds_clk_p
Pin 11: TMDS Clock-            → tmds_clk_n
Pin 12: TMDS Clock Shield
Pin 13: CEC (not used)
Pin 14: Reserved (not used)
Pin 15: SCL (not used)
Pin 16: SDA (not used)
Pin 17: GND
Pin 18: +5V Power
Pin 19: Hot Plug Detect (not used)
```

### LED Array

Located on the board, labeled LED0-LED5:

```
LED0 (Green)  → Pin 10  → PLL Lock
LED1 (Green)  → Pin 11  → Reset Status
LED2 (Green)  → Pin 13  → HSYNC
LED3 (Green)  → Pin 14  → VSYNC
LED4 (Green)  → Pin 15  → Display Enable
LED5 (Green)  → Pin 16  → Color Active
```

### Buttons

```
S2 (Reset) → Pin 4  → btn_rst
```

## Constraint File Reference

The complete pin assignments are defined in:
```
fpga/tang_nano_9k/constraints/tangnano9k.cst
```

## Signal Voltage Domains

| Domain | Pins | Voltage | Purpose |
|--------|------|---------|---------|
| Bank 0 | 10-16 | 1.8V | LEDs, on-board peripherals |
| Bank 1 | 4 | 1.8V | Button inputs |
| Bank 3 | 52 | 3.3V | Clock input |
| Bank 3 | 69-76 | 3.3V | HDMI differential outputs |

## Notes

1. **Clock Source**: The 27 MHz oscillator is built into the Tang Nano 9K board
2. **HDMI Cable**: Use a standard HDMI cable to connect to monitor
3. **Power**: Powered via USB-C connector (5V)
4. **Programming**: Use USB-C connector with openFPGALoader
5. **Voltage Levels**: Mixed 1.8V and 3.3V - ensure proper I/O standard settings

## Verification Checklist

Before programming:
- [ ] HDMI cable connected to monitor
- [ ] USB-C cable connected for power/programming
- [ ] Monitor powered on and set to correct input
- [ ] openFPGALoader installed and working
- [ ] Constraints file matches this pinout

## Troubleshooting

**No HDMI output:**
- Check LED0 is ON (system running)
- Check LEDs 2-5 are blinking (signals active)
- Try a different monitor or cable
- Verify pin assignments match hardware

**LEDs not lighting:**
- Check power connection
- Verify bitstream programmed correctly
- Check reset button (S2) not stuck

**Wrong colors/no sync:**
- Pins 69-76 must be differential pairs
- Check I/O type is LVCMOS33D for HDMI
- Verify drive strength is 8 mA

## References

- [Tang Nano 9K Schematic](https://dl.sipeed.com/shareURL/TANG/Nano%209K/2_Schematic)
- [Tang Nano 9K User Manual](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)
- [Gowin GW1NR-9C Datasheet](https://www.gowinsemi.com/en/support/database/)
