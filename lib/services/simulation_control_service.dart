import 'package:flutter/foundation.dart';

enum SimulationScenario { fall, lowSpo2, highGas, highTemperature }

class SimulationControlService extends ChangeNotifier {
  SimulationControlService._();

  static final SimulationControlService instance = SimulationControlService._();

  SimulationScenario? _pendingScenario;

  String _lastMessage = 'Ready to run simulation tests.';

  SimulationScenario? get pendingScenario => _pendingScenario;

  String get lastMessage => _lastMessage;

  bool get hasPendingScenario => _pendingScenario != null;

  // Queue a simulation test.
  void trigger(SimulationScenario scenario) {
    if (_pendingScenario != null) {
      _lastMessage = 'A simulation test is already waiting.';
      notifyListeners();
      return;
    }

    _pendingScenario = scenario;
    _lastMessage = 'Test queued: ${_scenarioName(scenario)}';

    notifyListeners();
  }

  // Called by SensorSimulatorService to consume the queued test.
  SimulationScenario? consumePendingScenario() {
    final scenario = _pendingScenario;

    if (scenario == null) {
      return null;
    }

    _pendingScenario = null;

    _lastMessage =
        'Injected ${_scenarioName(scenario)} into the sensor stream.';

    notifyListeners();

    return scenario;
  }

  // Clear the pending test and reset the status message.
  void resetMessage() {
    _pendingScenario = null;
    _lastMessage = 'Ready to run simulation tests.';

    notifyListeners();
  }

  // Convert the scenario enum into a readable name.
  String _scenarioName(SimulationScenario scenario) {
    switch (scenario) {
      case SimulationScenario.fall:
        return 'Fall Detection';

      case SimulationScenario.lowSpo2:
        return 'Low SpO₂';

      case SimulationScenario.highGas:
        return 'High Gas';

      case SimulationScenario.highTemperature:
        return 'High Temperature';
    }
  }
}
