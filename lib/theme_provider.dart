import 'package:flutter/material.dart';

// ThemeProvider manages the application's theme mode (light, dark, system).
// It extends ChangeNotifier to notify listeners (widgets) when the theme changes.
class ThemeProvider with ChangeNotifier {
  // _themeMode stores the currently selected theme mode.
  // It defaults to ThemeMode.system, which respects the device's system settings.
  ThemeMode _themeMode = ThemeMode.system;

  // Getter for the current theme mode.
  ThemeMode get themeMode => _themeMode;

  // Toggles the theme between dark and light mode based on the `isDarkMode` boolean.
  // After updating the theme mode, it calls notifyListeners() to rebuild dependent widgets.
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Sets the theme mode based on the system's current brightness.
  // This is typically called once during app initialization to set the initial theme.
  void setSystemTheme(BuildContext context) {
    // Get the platform's current brightness setting.
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    // Set the theme mode to dark if system brightness is dark, otherwise light.
    _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners of the change.
  }
}
