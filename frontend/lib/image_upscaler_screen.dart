import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'image_service.dart';

// Class helper untuk memotong gambar (tidak ada perubahan)
class _ImageClipper extends CustomClipper<Rect> {
  final double clipFactor;
  _ImageClipper({required this.clipFactor});
  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width * clipFactor, size.height);
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class ImageUpscalerScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const ImageUpscalerScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  ImageUpscalerScreenState createState() => ImageUpscalerScreenState();
}

class ImageUpscalerScreenState extends State<ImageUpscalerScreen> {
  final ImageService _imageService = ImageService();

  File? _image;
  File? _upscaledImage;
  bool _isUpscaling = false;
  String _selectedScale = '2x';
  String _selectedFormat = 'AUTO';
  String _originalResolution = '';
  String _targetResolution = '';
  bool _faceEnhanceEnabled = true;
  double _sliderPosition = 0.5;
  final Map<String, int> _scaleFactors = {'2x': 2, '4x': 4, '6x': 6};
  int _originalWidth = 0;
  int _originalHeight = 0;
  String _originalFormat = '';
  String _originalFileName = '';

  // State dan fungsi untuk notifikasi kustom
  bool _isNotificationVisible = false;
  String _notificationMessage = '';
  IconData _notificationIcon = Icons.check_circle;
  Color _notificationColor = Colors.green;
  Timer? _notificationTimer;

  void _showNotification({required String message, required IconData icon, required Color color}) {
    _notificationTimer?.cancel();
    if (mounted) {
      setState(() {
        _notificationMessage = message;
        _notificationIcon = icon;
        _notificationColor = color;
        _isNotificationVisible = true;
      });
    }
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isNotificationVisible = false;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imageService.pickImage();
    if (pickedFile != null) {
      final dimensions = await _imageService.getImageDimensions(pickedFile);
      if (!mounted) return;
      setState(() {
        _image = pickedFile;
        _upscaledImage = null;
        _originalWidth = dimensions['width'] ?? 0;
        _originalHeight = dimensions['height'] ?? 0;
        _originalFormat = pickedFile.path.split('.').last.toUpperCase();
        _originalFileName = pickedFile.path.split('/').last;
        _updateResolutionText();
      });
      _showNotification(
        message: 'Gambar berhasil dipilih',
        icon: Icons.check_circle_outline,
        color: Colors.green.shade600
      );
    }
  }

  void _updateResolutionText() {
    if (_originalWidth == 0) {
      setState(() { _originalResolution = ''; _targetResolution = ''; });
      return;
    }
    _originalResolution = '${_originalWidth}x$_originalHeight $_originalFormat';
    int targetWidth = _originalWidth;
    int targetHeight = _originalHeight;
    bool isPortrait = _originalHeight > _originalWidth;

    if (_selectedScale == '2k' && _originalWidth > 0) {
      if(isPortrait) {
        double scaleFactor = 2048 / _originalHeight;
        targetHeight = 2048;
        targetWidth = (_originalWidth * scaleFactor).round();
      } else {
        double scaleFactor = 2048 / _originalWidth;
        targetWidth = 2048;
        targetHeight = (_originalHeight * scaleFactor).round();
      }
    } else if (_selectedScale == '4k' && _originalWidth > 0) {
       if(isPortrait) {
        double scaleFactor = 3840 / _originalHeight;
        targetHeight = 3840;
        targetWidth = (_originalWidth * scaleFactor).round();
      } else {
        double scaleFactor = 3840 / _originalWidth;
        targetWidth = 3840;
        targetHeight = (_originalHeight * scaleFactor).round();
      }
    } else {
      int scaleFactor = _scaleFactors[_selectedScale] ?? 1;
      targetWidth = _originalWidth * scaleFactor;
      targetHeight = _originalHeight * scaleFactor;
    }
    final displayFormat = _selectedFormat == 'AUTO' ? _originalFormat : _selectedFormat;
    setState(() {
      _targetResolution = '${targetWidth}x$targetHeight ${displayFormat.toUpperCase()}';
    });
  }

  Future<void> _upscaleImage() async {
    if (_image == null) return;
    setState(() { _isUpscaling = true; });
    try {
      final upscaledFile = await _imageService.upscaleImage(
        imageFile: _image!,
        scaleOption: _selectedScale,
        format: _selectedFormat,
        useFaceEnhance: _faceEnhanceEnabled,
      );
      if (!mounted) return;
      setState(() {
        _upscaledImage = upscaledFile;
        _sliderPosition = 0.5;
      });
      if (upscaledFile != null) {
        _showNotification(
          message: 'Gambar berhasil di-upscale!',
          icon: Icons.rocket_launch_outlined,
          color: Colors.deepPurple,
        );
      } else {
         _showNotification(
          message: 'Gagal melakukan upscale',
          icon: Icons.error_outline,
          color: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showNotification(
          message: 'Terjadi Error: ${e.toString().split(':').last.trim()}',
          icon: Icons.error_outline,
          color: Colors.red,
        );
    } finally {
      if (!mounted) return;
      setState(() { _isUpscaling = false; });
    }
  }

  Future<void> _saveImage() async {
    File? imageToSave = _upscaledImage;
    if (imageToSave == null) {
      _showNotification(message: 'Tidak ada gambar untuk disimpan', icon: Icons.warning_amber_rounded, color: Colors.orange);
      return;
    }
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Pilih folder untuk menyimpan gambar',
    );
    if (!mounted) return;
    if (selectedDirectory != null) {
      final finalFormat = _selectedFormat == 'AUTO' ? _originalFormat : _selectedFormat;
      final success = await _imageService.saveImageToCustomPath(imageToSave, selectedDirectory, _originalFileName, _selectedScale, finalFormat, _faceEnhanceEnabled);
      if (!mounted) return;
      if (success) {
        _showNotification(message: 'Gambar berhasil disimpan', icon: Icons.save_alt_outlined, color: Colors.green.shade600);
      } else {
         _showNotification(message: 'Gagal menyimpan gambar', icon: Icons.error_outline, color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: isDarkMode ? 0 : 1,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        title: Text('RealScale AI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isDarkMode,
              onChanged: (value) {
                widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
              },
              thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Icon(Icons.nightlight_round, color: Colors.white);
                  }
                  return const Icon(Icons.wb_sunny, color: Colors.orange);
                },
              ),
              thumbColor: MaterialStateProperty.all(Colors.transparent),
              trackColor: MaterialStateProperty.all(Colors.transparent),
              trackOutlineColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageView(isDarkMode),
                const SizedBox(height: 16),
                _buildActionButtons(isDarkMode),
                const SizedBox(height: 16),
                _buildScaleAndFormatContainer(isDarkMode),
                const SizedBox(height: 12),
                _buildFaceEnhanceToggle(isDarkMode),
              ],
            ),
          ),
          if (_isUpscaling) _buildUpscalingDialog(),
          _buildNotificationBanner(),
        ],
      ),
    );
  }

  Widget _buildImageView(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 2 : 4,
      shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AspectRatio(
        aspectRatio: 1,
        child: _image == null
            ? Center(child: Text('Pilih gambar untuk memulai', style: TextStyle(color: Colors.grey[600]!)))
            : _upscaledImage == null
                ? Image.file(_image!, fit: BoxFit.contain)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            final newPosition = details.localPosition.dx / constraints.maxWidth;
                            _sliderPosition = newPosition.clamp(0.0, 1.0);
                          });
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_image!, fit: BoxFit.cover),
                            ClipRect(
                              clipper: _ImageClipper(clipFactor: _sliderPosition),
                              child: Image.file(_upscaledImage!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              left: constraints.maxWidth * _sliderPosition - 2,
                              child: Container(width: 4, height: constraints.maxHeight, color: Colors.white70),
                            ),
                            Positioned(
                              top: (constraints.maxHeight / 2) - 20,
                              left: constraints.maxWidth * _sliderPosition - 20,
                              child: Container(
                                width: 40, height: 40,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                child: const Icon(Icons.unfold_more, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildActionButton('Pilih Gambar', _pickImage, isDarkMode: isDarkMode),
        _buildActionButton('Upscale', _image == null || _isUpscaling ? null : _upscaleImage, primary: true, isDarkMode: isDarkMode),
        _buildActionButton('Simpan', (_upscaledImage == null) ? null : _saveImage, isDarkMode: isDarkMode),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback? onPressed, {bool primary = false, required bool isDarkMode}) {
    final bgColor = primary ? Colors.deepPurple : Theme.of(context).cardColor;
    final fgColor = primary ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;
    return ElevatedButton.icon(
      icon: Icon(label == 'Pilih Gambar' ? Icons.photo_library : label == 'Upscale' ? Icons.rocket_launch : Icons.save_alt, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: primary ? 2 : 1,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  Widget _buildScaleAndFormatContainer(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Wrap(alignment: WrapAlignment.center, spacing: 8.0, children: ['2x', '4x', '6x', '2k', '4k'].map((s) => _buildChoiceChip(s, _selectedScale, (selected) { setState(() { _selectedScale = s; _updateResolutionText(); }); })).toList()),
            const Divider(height: 16, indent: 20, endIndent: 20, thickness: 0.5),
            Wrap(alignment: WrapAlignment.center, spacing: 8.0, children: ['AUTO', 'PNG', 'JPG'].map((f) => _buildChoiceChip(f, _selectedFormat, (selected) { setState(() { _selectedFormat = f; _updateResolutionText(); }); })).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceEnhanceToggle(bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 1 : 2,
      shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
            title: const Text('Perbaikan Wajah', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Tingkatkan kualitas wajah pada gambar', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            value: _faceEnhanceEnabled,
            onChanged: (bool value) { setState(() { _faceEnhanceEnabled = value; }); },
            activeColor: Colors.deepPurple,
          ),
          if (_originalResolution.isNotEmpty)
            const Divider(height: 1, indent: 16, endIndent: 16),
          if (_originalResolution.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_originalResolution, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward_rounded, color: Colors.deepPurple, size: 16),
                  ),
                  Text(_targetResolution, style: const TextStyle(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String groupValue, Function(bool) onSelected) {
    final bool isSelected = label == groupValue;
    return ChoiceChip(
      label: Text(label),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.deepPurple.shade100,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      labelStyle: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepPurple.shade900 : Theme.of(context).textTheme.bodyLarge?.color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300)),
    );
  }
  
  Widget _buildUpscalingDialog() {
    return Container(
      color: Colors.black54, 
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(16)
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text("Memproses...", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_originalResolution.isNotEmpty)
                Text("Target: $_targetResolution", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationBanner() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      top: _isNotificationVisible ? 20.0 : -100.0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(_notificationIcon, color: _notificationColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _notificationMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}