import '../../common/models/avtar_list.dart';

/// Service to store the selected deity information
/// This allows passing deity data between screens
class DeitySelectionService {
  static final DeitySelectionService _instance =
      DeitySelectionService._internal();
  factory DeitySelectionService() => _instance;
  DeitySelectionService._internal();

  Data? _selectedDeity;

  /// Get the currently selected deity object
  Data? get selectedDeity => _selectedDeity;

  /// Get the currently selected deity name
  String get selectedDeityName => _selectedDeity?.name ?? 'BI Rashmi';

  /// Set the selected deity
  void setSelectedDeity(Data? deity) {
    _selectedDeity = deity;
  }

  /// Clear the selected deity
  void clearDeity() {
    _selectedDeity = null;
  }

  /// Get the video path/URL for the selected deity
  String? getVideoPath() {
    if (_selectedDeity != null &&
        _selectedDeity!.videoUrl != null &&
        _selectedDeity!.videoUrl!.isNotEmpty) {
      return _selectedDeity!.videoUrl!;
    }

    // Default fallback - no local asset
    return null;
  }
}