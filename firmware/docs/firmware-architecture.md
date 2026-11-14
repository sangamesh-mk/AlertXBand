# Firmware Architecture

## High-level processing flow

```text
Boot
 -> Initialize GPIO, I2C, and UART
 -> Initialize sensors and communication modules
 -> Acquire sensor samples
 -> Validate and timestamp samples
 -> Evaluate configured event rules
 -> Update local display and indicators
 -> Transmit telemetry or emergency events
 -> Monitor faults and repeat
```

## Design requirements

- Keep sensor acquisition independent from network operations.
- Represent unavailable readings explicitly; do not publish invalid values as valid measurements.
- Include device identity, timestamps, and documented units in telemetry.
- Use bounded-time or non-blocking operations for time-sensitive tasks.
- Add retry/backoff and offline handling where appropriate.
- Validate fall-detection logic against recorded test cases; do not rely on one raw acceleration threshold.
- Treat emergency delivery as best-effort until end-to-end reliability has been demonstrated.

Document the exact payload schema shared with the mobile app and backend, including field names, units, nullability, and event semantics.
