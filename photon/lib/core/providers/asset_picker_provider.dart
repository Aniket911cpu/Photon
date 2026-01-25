import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetPickerProvider extends ChangeNotifier {
  // Sets of absolute paths
  final Set<String> _selectedPaths = {};
  
  // Categorized counts for UI badges
  int get totalSelected => _selectedPaths.length;
  
  Set<String> get selectedPaths => _selectedPaths;

  bool isSelected(String path) => _selectedPaths.contains(path);

  void toggleSelection(String path) {
    if (_selectedPaths.contains(path)) {
      _selectedPaths.remove(path);
    } else {
      _selectedPaths.add(path);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedPaths.clear();
    notifyListeners();
  }
}
