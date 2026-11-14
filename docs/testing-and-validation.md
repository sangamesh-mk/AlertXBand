# Testing and Validation

Use this document to record repeatable hardware, firmware, backend, and application tests.

## Test record template

| Date | Layer | Test | Expected result | Observed result | Status |
|---|---|---|---|---|---|
| YYYY-MM-DD | Hardware/Firmware/App | Describe test | Describe expected result | Record measured output | Pass/Fail/Blocked |

## Validation areas

- Sensor readings and invalid/disconnected sensor behavior.
- GPS fix acquisition and coordinate plausibility.
- GSM registration, SMS/call behavior, and supply stability.
- Wi-Fi/backend connectivity and reconnection.
- Firestore/database access controls.
- App display of real hardware data versus simulated/demo data.
- Emergency event creation, delivery, and history.
- Battery runtime and full-system operation.

Do not mark a feature as passed based only on a screen existing or a module indicator LED turning on. Record setup, logs, measurements, and limitations.
