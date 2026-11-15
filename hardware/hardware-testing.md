# Testing and Validation

Use this document to record repeatable hardware, firmware, backend, and application tests.

## Test record template

| Date | Layer | Test | Expected result | Observed result | Status |
|---|---|---|---|---|---|
| 2026-11-14 | Hardware/Firmware/App | The hardware woked well and the integration of both software and hardware also succeeded | Live location and speaker and mce also worked well with the fall detection | Varied data of the integrated sensors | All tests are passed |

## Test checklist

- [x] ESP32 boots reliably over USB.
- [ ] Battery power path and regulated rails measured under load.
- [x] MPU6050 identity and motion readings verified.
- [x] GPS obtains a valid fix outdoors; coordinates checked.
- [x] MAX30102 signal quality and repeatability assessed.
- [x] DHT22 readings compared with a reference instrument.
- [x] MQ-2 warm-up and response procedure documented.
- [ ] OLED and LCD tested.
- [x] Buzzer and LEDs tested.
- [ ] SIM800L network registration, SMS, and calls tested with stable power.
- [x] Full-system operation tested with modules active together.

A module LED lighting up is not sufficient evidence of a successful functional test. Include serial logs, measurements, test conditions, and limitations.
