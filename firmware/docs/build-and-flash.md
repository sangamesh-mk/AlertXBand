# Firmware Build and Flash Guide

1. Install the ESP32 board package version used by the project.
2. Select the exact ESP32 board model and serial port.
3. Install libraries required by the actual source code.
4. Create a local `config.h` from `config.example.h`; set only verified GPIO values and local credentials.
5. Compile and upload the firmware.
6. Open Serial Monitor at the baud rate configured by the sketch.
7. Record board/core version, library versions, build result, and test output.

## Before publishing

- Confirm no credentials or personal data are included.
- Verify GPIO assignments against the hardware documentation.
- Build from a clean checkout.
- Record firmware version and source commit.
- Test sensor disconnection, invalid readings, GPS no-fix, and network loss.
