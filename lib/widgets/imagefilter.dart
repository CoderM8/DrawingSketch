import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'images.dart';

const double midBrightness = 0.627;
const double midContrast = 0.996;
const double midSaturation = 1.8;

/// A widget that allows users to apply color filters to an image.
@immutable
class PhotoFilter extends StatefulWidget {
  /// The image to which filters will be applied.
  final File image;

  /// The call back when tapping on the cancel icon.
  final VoidCallback? onCancel;

  /// The call back when isolate starts to apply filter and generate new Image.
  final VoidCallback? onStartApplyingFilter;

  /// The call back when applying filter is finished to apply filter and generate new Image.
  final void Function(File?)? onFinishApplyingFilter;

  /// The boolean if image has to be compressed when applying filter.
  final bool compressImage;

  /// The value of the quality for compressing the image.
  final int? compressQuality;

  const PhotoFilter({super.key, required this.image, this.onCancel, this.onStartApplyingFilter, this.onFinishApplyingFilter, this.compressImage = false, this.compressQuality});

  @override
  State<PhotoFilter> createState() => _PhotoFilterState();
}

class _PhotoFilterState extends State<PhotoFilter> {
  NamedColorFilter? _selectedFilter;
  NamedColorFilter? _previousSelectedFilter;
  bool _showPreset = true;
  bool _showSliders = false;
  bool _isApplying = false;
  Timer? _timer;
  double _brightness = midBrightness;
  double _contrast = midContrast;
  double _saturation = midSaturation;
  List<double>? _previousColorMatrix;

  List<double> _colorMatrix = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
  final List<NamedColorFilter> filters = [
    const NamedColorFilter(matrix: [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0], name: 'Original'),
    const NamedColorFilter(matrix: [0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0], name: 'Moon'),
    const NamedColorFilter(matrix: [0.5, 0.5, 0.5, 0, 20, 0.5, 0.5, 0.5, 0, 20, 0.5, 0.5, 0.5, 0, 20, 0, 0, 0, 1, 0], name: 'Willow'),
    const NamedColorFilter(matrix: [1, 1, 1, 0, -0.5, 1, 1, 1, 0, -0.5, 1, 1, 1, 0, -0.5, 0, 0, 0, 1, 0], name: 'High'),
    const NamedColorFilter(matrix: [0.5, 0.5, 0.5, 0, 0, 0.5, 0.5, 0.5, 0, 0, 0.5, 0.5, 0.5, 0, 0, 0, 0, 0, 1, 0], name: 'Low'),
    const NamedColorFilter(matrix: [0.393, 0.769, 0.189, 0, 0, 0.349, 0.686, 0.168, 0, 0, 0.272, 0.534, 0.131, 0, 0, 0, 0, 0, 1, 0], name: 'Toned'),
    const NamedColorFilter(matrix: [0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0], name: 'Grayscale'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = filters.first;
  }

  /// RESET
  void toggleReset() {
    setState(() {
      _selectedFilter = filters[0];
      _colorMatrix = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
      _previousColorMatrix = _colorMatrix;
      _previousSelectedFilter = filters[0];
      _brightness = midBrightness;
      _contrast = midContrast;
      _saturation = midSaturation;
      if (_showPreset) {
        _showSliders = false;
        _showPreset = true;
      }
      if (_showSliders) {
        _showPreset = true;
        _showSliders = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ConstSvg(
          "assets/svg/back.svg",
          height: 24.w,
          width: 24.w,
          fit: BoxFit.scaleDown,
          color: blackColor,
          onTap: () {
            widget.onCancel?.call();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            onPressed: toggleReset,
            icon: ConstSvg("assets/svg/reset.svg", height: 24.w, width: 24.w, color: blackColor, fit: BoxFit.scaleDown),
          ),
          IconButton(
              onPressed: () async {
                if (_selectedFilter!.name == 'None') {
                  widget.onFinishApplyingFilter?.call(null);
                  Get.back();
                  return;
                }
                widget.onStartApplyingFilter?.call();
                if (widget.onFinishApplyingFilter != null) {
                  Get.back();
                } else {
                  setState(() {
                    _isApplying = true;
                  });
                }
                Isolate? newIsolate;

                final ReceivePort receivePort = ReceivePort();
                newIsolate = await Isolate.spawn(
                    _applyFilter,
                    ApplyFilterParams(
                        shouldCompress: widget.compressImage,
                        compressQuality: widget.compressQuality,
                        rootIsolateToken: RootIsolateToken.instance!,
                        rawFile: widget.image,
                        colorMatrix: _selectedFilter!.matrix,
                        brightness: _brightness,
                        contrast: _contrast,
                        saturation: _saturation,
                        defaultMatrix: _colorMatrix,
                        sendPort: receivePort.sendPort));

                receivePort.listen((message) {
                  if (message != null) {
                    widget.onFinishApplyingFilter?.call(message);
                    if (context.mounted) {
                      Get.back(result: message);
                    }
                  }
                  newIsolate?.kill(priority: Isolate.immediate);
                  newIsolate = null;
                });
              },
              icon: Icon(Icons.done, size: 28.sp)),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(height: 20.h),
              _mainImage(),
              SizedBox(height: 20.h),
              if (_showSliders) ...[
                _buildSlider("Brightness", midBrightness - 0.4, midBrightness + 0.4, _brightness, (value) {
                  _brightness = value;
                }),
                _buildSlider("Contrast", midContrast - 0.0035, midContrast + 0.0035, _contrast, (value) {
                  _contrast = value;
                }),
                _buildSlider("Saturation", midSaturation - 2.0, midSaturation + 2.0, _saturation, (value) {
                  _saturation = value;
                }),
              ],
              if (_showPreset) ...[
                _presets(),
              ],
              SizedBox(height: 20.h),
              _bottomButtons(),
              SizedBox(height: 30.h),
            ],
          ),
          if (_isApplying) ...[
            SizedBox.fromSize(
              size: MediaQuery.sizeOf(context),
              child: Container(
                color: whiteColor.withOpacity(.6),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: blackColor),
              ),
            )
          ]
        ],
      ),
    );
  }

  Row _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ConstButton(
            onTap: () {
              if (_showPreset) {
                return;
              }
              setState(() {
                _showSliders = false;
                _showPreset = true;
              });
            },
            height: 40.h,
            color: _showPreset ? pinkColor : pinkColor.withOpacity(.7),
            icon: ConstText("Presets", fontFamily: "M", fontSize: 16.sp, color: whiteColor),
          ),
        ),
        Expanded(
          child: ConstButton(
            onTap: () {
              if (_showSliders) {
                return;
              }
              setState(() {
                _showSliders = true;
                _showPreset = false;
              });
            },
            height: 40.h,
            color: _showSliders ? pinkColor : pinkColor.withOpacity(.7),
            icon: ConstText("Manual", color: whiteColor, fontFamily: "M", fontSize: 16.sp),
          ),
        ),
      ],
    );
  }

  Widget _presets() {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemBuilder: (context, index) {
          return Column(
            children: [
              ConstText(
                filters[index].name,
                color: blackColor,
                fontSize: 14.sp,
                fontFamily: "M",
                padding: EdgeInsets.only(bottom: 5.h),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filters[index];
                    _previousSelectedFilter = filters[index];
                  });
                },
                child: ColorFiltered(
                  colorFilter: filters[index].matrix.isEmpty ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : ColorFilter.matrix(filters[index].matrix),
                  child: Image.file(widget.image, width: 72.w, height: 72.w, fit: BoxFit.cover),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
      ),
    );
  }

  Expanded _mainImage() {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) {
          _timer = Timer(
            const Duration(milliseconds: 350),
            () {
              setState(() {
                _selectedFilter = filters.first;
                _colorMatrix = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
              });
            },
          );
        },
        onTapUp: (_) {
          _timer?.cancel();
          setState(() {
            _selectedFilter = _previousSelectedFilter ?? filters[0];
            _colorMatrix = _previousColorMatrix ?? _colorMatrix;
          });
        },
        child: ColorFiltered(
          colorFilter: _selectedFilter!.matrix.isEmpty ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : ColorFilter.matrix(_selectedFilter!.matrix),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_colorMatrix),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: ClipRRect(borderRadius: BorderRadius.circular(15.r), child: Image.file(widget.image, fit: BoxFit.cover)),
            ),
          ),
        ),
      ),
    );
  }

  static void _applyFilter(ApplyFilterParams applyFilterParams) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(applyFilterParams.rootIsolateToken);
    File filteredImageFile = await FilterManager.applyFilter(applyFilterParams);
    applyFilterParams.sendPort.send(filteredImageFile);
  }

  List<double> _generateColorMatrix() {
    final double brightness = _brightness;
    final List<double> brightnessMatrix = [brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, 1, 0];
    final double contrast = 1.9949 - _contrast;

    final List<double> contrastMatrix = [contrast, 0, 0, 0, 128 * (1 - contrast), 0, contrast, 0, 0, 128 * (1 - contrast), 0, 0, contrast, 0, 128 * (1 - contrast), 0, 0, 0, 1, 0];

    final double saturation = _saturation;

    final List<double> saturationMatrix = [
      0.213 + 0.787 * saturation,
      0.715 - 0.715 * saturation,
      0.072 - 0.072 * saturation,
      0,
      0,
      0.213 - 0.213 * saturation,
      0.715 + 0.285 * saturation,
      0.072 - 0.072 * saturation,
      0,
      0,
      0.213 - 0.213 * saturation,
      0.715 - 0.715 * saturation,
      0.072 + 0.928 * saturation,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ];

    List<double> result = _multiplyMatrices(brightnessMatrix, contrastMatrix);
    result = _multiplyMatrices(result, saturationMatrix);
    return result;
  }

  List<double> _multiplyMatrices(List<double> a, List<double> b) {
    if (a.length != 20 || b.length != 20) {
      throw ArgumentError('Both matrices must be of size 20.');
    }

    final result = List<double>.filled(20, 0);

    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 5; x++) {
        double sum = 0.0;
        for (var z = 0; z < 4; z++) {
          sum += a[y * 5 + z] * b[z * 5 + x];
        }
        if (x < 4) {
          sum += a[y * 5 + 4];
        }
        result[y * 5 + x] = sum;
      }
    }

    return result;
  }

  Widget _buildSlider(String label, double min, double max, double value, Function onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  switch (label) {
                    case "Brightness":
                      _brightness = midBrightness;
                      break;
                    case "Contrast":
                      _contrast = midContrast;
                      break;
                    case "Saturation":
                      _saturation = midSaturation;
                      break;
                  }
                  _colorMatrix = _generateColorMatrix();
                  _previousColorMatrix = _colorMatrix;
                });
              },
              child: ConstText(label, fontSize: 14.sp, fontFamily: "M")),
          Expanded(
            child: Slider.adaptive(
              activeColor: pinkColor,
              value: value,
              onChanged: (value) {
                onChanged(value);
                setState(() {
                  _colorMatrix = _generateColorMatrix();
                  _previousColorMatrix = _colorMatrix;
                });
              },
              min: min,
              max: max,
            ),
          ),
        ],
      ),
    );
  }
}

class NamedColorFilter {
  final List<double> matrix;
  final String name;

  const NamedColorFilter({required this.matrix, required this.name});
}

class FilterManager {
  static Future<File> applyFilter(ApplyFilterParams applyFilterParams) async {
    final img.Image? image = await ImageProcessor.loadImage(applyFilterParams.rawFile);

    if (image == null) throw Exception("Failed to decode image");

    // Apply the color filter
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final img.Pixel pixel = image.getPixel(x, y);

        final num alpha = pixel.a;
        final num red = pixel.r;
        final num green = pixel.g;
        final num blue = pixel.b;

        final newColor = _multiplyByColorFilter([red, green, blue, alpha], applyFilterParams.colorMatrix);

        final color = img.ColorRgba8(newColor[0], newColor[1], newColor[2], newColor[3]);
        image.setPixel(x, y, color);
      }
    }

    if (applyFilterParams.brightness != midBrightness || applyFilterParams.contrast != midContrast || applyFilterParams.saturation != midSaturation) {
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final img.Pixel pixel = image.getPixel(x, y);

          final num alpha = pixel.a;
          final num red = pixel.r;
          final num green = pixel.g;
          final num blue = pixel.b;

          final newColor = _multiplyByColorFilter([red, green, blue, alpha], applyFilterParams.defaultMatrix);

          final color = img.ColorRgba8(newColor[0], newColor[1], newColor[2], newColor[3]);
          image.setPixel(x, y, color);
        }
      }
    }

    return await ImageProcessor.saveImage(image, applyFilterParams.shouldCompress, applyFilterParams.compressQuality);
  }

  static List<int> _multiplyByColorFilter(List<num> color, List<double> matrix) {
    final r = (color[0] * matrix[0] + color[1] * matrix[1] + color[2] * matrix[2] + color[3] * matrix[3] + matrix[4]).clamp(0, 255).toInt();
    final g = (color[0] * matrix[5] + color[1] * matrix[6] + color[2] * matrix[7] + color[3] * matrix[8] + matrix[9]).clamp(0, 255).toInt();
    final b = (color[0] * matrix[10] + color[1] * matrix[11] + color[2] * matrix[12] + color[3] * matrix[13] + matrix[14]).clamp(0, 255).toInt();
    final a = (color[0] * matrix[15] + color[1] * matrix[16] + color[2] * matrix[17] + color[3] * matrix[18] + matrix[19]).clamp(0, 255).toInt();

    return [r, g, b, a];
  }
}

class ImageProcessor {
  static Future<img.Image?> loadImage(File file) async {
    final List<int> bytes = await file.readAsBytes();
    return img.decodeImage(Uint8List.fromList(bytes));
  }

  static Future<File> saveImage(img.Image image, bool shouldCompress, int? compressQuality) async {
    image = shouldCompress ? compressImage(image, compressQuality ?? 75) : image;

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/${generateRandomString()}.png";
    final File file = File(path);
    file.writeAsBytesSync(img.encodePng(image));
    return file;
  }

  static img.Image compressImage(img.Image originalImage, int quality) {
    Uint8List? compressedBytes = img.encodeJpg(originalImage, quality: quality);
    return img.decodeImage(compressedBytes)!;
  }
}

String generateRandomString() {
  final random = Random();
  const availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(4, (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

class ApplyFilterParams {
  final File rawFile;
  final List<double> colorMatrix;
  final double brightness;
  final double contrast;
  final double saturation;
  final List<double> defaultMatrix;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;
  final bool shouldCompress;
  final int? compressQuality;

  const ApplyFilterParams(
      {required this.shouldCompress,
      this.compressQuality,
      required this.rootIsolateToken,
      required this.sendPort,
      required this.rawFile,
      required this.colorMatrix,
      required this.brightness,
      required this.contrast,
      required this.saturation,
      required this.defaultMatrix});
}
