# AlertXBand System Architecture

AlertXBand is organized into three cooperating layers:

1. **Wearable hardware** — microcontroller, sensors, local indicators, GPS, and optional GSM communication.
2. **Backend services** — authentication, storage, device data handling, and event/notification processing as implemented in the repository.
3. **Flutter application** — user-facing monitoring, location, emergency, and account interfaces.

## Intended data flow

```text
Sensors -> ESP32 -> Wi-Fi / GSM -> Backend -> Flutter application
                   |                         |
                   +-> local buzzer/display  +-> dashboards and alerts
```

This is a high-level design. It does not imply that every sensor, communication path, or alert workflow is fully integrated or validated. Refer to implementation and test records for current status.
