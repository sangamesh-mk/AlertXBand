# AlertXBand Power Management

Development notes describe a single-cell 18650 Li-ion battery, TP4056 charging module, and 1S protection board. Confirm the actual final power circuit before relying on this description.

## Required documentation

- Battery make, capacity, chemistry, and protection status.
- TP4056 board variant and configured charge current.
- Protection board ratings and exact B+/B-/P+/P- wiring.
- Regulator/converter part numbers and output rails.
- Module current requirements, including GSM transmit bursts.
- Measured voltage at each rail during idle and peak load.
- Battery runtime under representative operation.

## Important distinctions

A TP4056 is a single-cell charger, not a system voltage regulator. A protection board does not replace correctly rated voltage regulation. SIM800L supply requirements are module-specific and include high current peaks; use a dedicated, suitably rated supply and verify its voltage under load.

Do not connect the battery or modules until polarity, charger wiring, protection, and regulator outputs have been checked.
