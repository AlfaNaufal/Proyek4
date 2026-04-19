import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageProcessingView extends StatefulWidget {
  final File? initialImage;
  const ImageProcessingView({super.key, this.initialImage});

  @override
  State<ImageProcessingView> createState() => _ImageProcessingViewState();
}

class _ImageProcessingViewState extends State<ImageProcessingView> {
  File? _originalImageFile;
  Uint8List? _processedImageBytes;
  bool _isProcessing = false;

  final ImagePicker _picker = ImagePicker();

  // 1. Fungsi Ambil Gambar dari Galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _originalImageFile = File(pickedFile.path);
        _processedImageBytes = null; // Reset hasil sebelumnya
      });
    }
  }

  // 2. ALGORITMA 1: Operasi Dasar - Inverse (Negatif)
  Future<void> _applyInverse() async {
    if (_originalImageFile == null) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 100)); 

    // a. Baca byte gambar asli
    final bytes = await _originalImageFile!.readAsBytes();
    
    // b. Decode menjadi matrix piksel (format image Dart)
    img.Image? decodedImage = img.decodeImage(bytes);
    
    if (decodedImage != null) {
      // c. MANIPULASI MATEMATIKA PIKSEL (Inverse: 255 - nilai piksel)
      for (var pixel in decodedImage) {
        pixel.r = 255 - pixel.r; // Red
        pixel.g = 255 - pixel.g; // Green
        pixel.b = 255 - pixel.b; // Blue
      }

      // d. Encode kembali menjadi JPG untuk ditampilkan di layar
      _processedImageBytes = img.encodeJpg(decodedImage);
    }

    setState(() => _isProcessing = false);
  }

  // ALGORITMA 2: Histogram Equalization
  Future<void> _applyHistogramEq() async {
    if (_originalImageFile == null) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _originalImageFile!.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      if (image.width > 800) image = img.copyResize(image, width: 800);

      // List untuk menyimpan H dan S agar bentuk warnanya tidak berubah
      List<List<double>> hsvPixels = [];
      List<int> histV = List.filled(256, 0);

      for (var p in image) {
        double r = p.r / 255.0;
        double g = p.g / 255.0;
        double b = p.b / 255.0;

        double cMax = math.max(r, math.max(g, b));
        double cMin = math.min(r, math.min(g, b));
        double delta = cMax - cMin;

        // Hitung Hue (Warna)
        double h = 0;
        if (delta == 0) {
          h = 0;
        } else if (cMax == r) {
          h = 60 * (((g - b) / delta) % 6);
        } else if (cMax == g) {
          h = 60 * (((b - r) / delta) + 2);
        } else {
          h = 60 * (((r - g) / delta) + 4);
        }
        if (h < 0) h += 360;

        // Hitung Saturation (Kepekatan)
        double s = cMax == 0 ? 0 : delta / cMax;

        // Hitung Value (Kecerahan aktual 0-255)
        int vInt = (cMax * 255).round().clamp(0, 255);

        hsvPixels.add([h, s]); // Simpan memori warna asli
        histV[vInt]++;         // Masukkan kecerahan ke histogram
      }

      List<int> cdfV = List.filled(256, 0);
      cdfV[0] = histV[0];
      for (int i = 1; i < 256; i++) {
        cdfV[i] = cdfV[i - 1] + histV[i];
      }

      int cdfMin = cdfV.firstWhere((val) => val > 0, orElse: () => 1);
      int totalPixels = image.width * image.height;

      int pixelIndex = 0;
      for (var p in image) {
        double h = hsvPixels[pixelIndex][0];
        double s = hsvPixels[pixelIndex][1];
        
        int oldV = (math.max(p.r/255.0, math.max(p.g/255.0, p.b/255.0)) * 255).round().clamp(0, 255);
        int newVInt = ((cdfV[oldV] - cdfMin) / (totalPixels - cdfMin) * 255).round().clamp(0, 255);
        double v = newVInt / 255.0;

        double c = v * s;
        double x = c * (1 - ((h / 60) % 2 - 1).abs());
        double m = v - c;

        double rPrime = 0, gPrime = 0, bPrime = 0;
        if (h >= 0 && h < 60) { rPrime = c; gPrime = x; bPrime = 0; }
        else if (h >= 60 && h < 120) { rPrime = x; gPrime = c; bPrime = 0; }
        else if (h >= 120 && h < 180) { rPrime = 0; gPrime = c; bPrime = x; }
        else if (h >= 180 && h < 240) { rPrime = 0; gPrime = x; bPrime = c; }
        else if (h >= 240 && h < 300) { rPrime = x; gPrime = 0; bPrime = c; }
        else if (h >= 300 && h < 360) { rPrime = c; gPrime = 0; bPrime = x; }

        p.r = ((rPrime + m) * 255).round().clamp(0, 255);
        p.g = ((gPrime + m) * 255).round().clamp(0, 255);
        p.b = ((bPrime + m) * 255).round().clamp(0, 255);

        pixelIndex++;
      }

      _processedImageBytes = img.encodeJpg(image);
    }
    setState(() => _isProcessing = false);
  }

  // ALGORITMA 3: Konvolusi Spasial (Lowpass / Highpass)
  Future<void> _applyConvolution(List<double> kernel) async {
    if (_originalImageFile == null) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _originalImageFile!.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      if (image.width > 800) image = img.copyResize(image, width: 800);
      img.Image output = img.Image.from(image);

      // Matriks Konvolusi 3x3 Manual
      for (int y = 1; y < image.height - 1; y++) {
        for (int x = 1; x < image.width - 1; x++) {
          double r = 0, g = 0, b = 0;
          int kIndex = 0;

          // Kalikan pixel tetangga dengan kernel matriks
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              final pixel = image.getPixel(x + kx, y + ky);
              final weight = kernel[kIndex++];
              r += pixel.r * weight;
              g += pixel.g * weight;
              b += pixel.b * weight;
            }
          }
          // Batasi nilai agar tetap di rentang 0-255
          output.setPixelRgba(x, y, r.clamp(0, 255).toInt(), g.clamp(0, 255).toInt(), b.clamp(0, 255).toInt(), 255);
        }
      }
      _processedImageBytes = img.encodeJpg(output);
    }
    setState(() => _isProcessing = false);
  }

  // ALGORITMA 4: Median Filter
  Future<void> _applyMedianFilter() async {
    if (_originalImageFile == null) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _originalImageFile!.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      if (image.width > 800) image = img.copyResize(image, width: 800);
      img.Image output = img.Image.from(image);

      // Looping piksel untuk mencari nilai tengah (Median) dari 9 tetangga (3x3)
      for (int y = 1; y < image.height - 1; y++) {
        for (int x = 1; x < image.width - 1; x++) {
          List<int> rValues = [];
          List<int> gValues = [];
          List<int> bValues = [];

          // Ambil piksel 3x3 di sekitar titik saat ini
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              final p = image.getPixel(x + kx, y + ky);
              rValues.add(p.r.toInt());
              gValues.add(p.g.toInt());
              bValues.add(p.b.toInt());
            }
          }

          // Urutkan (Sorting) dari kecil ke besar
          rValues.sort();
          gValues.sort();
          bValues.sort();

          // Ambil nilai tengah (index ke-4 dari 9 elemen)
          output.setPixelRgba(x, y, rValues[4], gValues[4], bValues[4], 255);
        }
      }
      _processedImageBytes = img.encodeJpg(output);
    }
    setState(() => _isProcessing = false);
  }

  // ALGORITMA 5: Operasi Dasar - Thresholding / Binerisasi
  Future<void> _applyThreshold() async {
    if (_originalImageFile == null) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _originalImageFile!.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      if (image.width > 800) image = img.copyResize(image, width: 800);

      for (var p in image) {
        // Cari nilai rata-rata (Grayscale)
        int luminance = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
        
        // Operasi Logika: Jika lebih terang dari 128, jadikan putih. Jika tidak, hitam.
        int bw = luminance > 128 ? 255 : 0;
        
        p.r = bw;
        p.g = bw;
        p.b = bw;
      }
      _processedImageBytes = img.encodeJpg(image);
    }
    setState(() => _isProcessing = false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _originalImageFile = widget.initialImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCV Alternative (Pure Dart)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Original", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: _originalImageFile != null
                            ? Image.file(_originalImageFile!, fit: BoxFit.contain)
                            : const Center(child: Text("No Image")),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Gambar Hasil Proses
                Expanded(
                  child: Column(
                    children: [
                      const Text("Processed", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: _isProcessing 
                            ? const Center(child: CircularProgressIndicator())
                            : _processedImageBytes != null
                                ? Image.memory(_processedImageBytes!, fit: BoxFit.contain)
                                : const Center(child: Text("Result")),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tombol Upload
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Gambar"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const Text("Pilih Operasi Citra", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  label: const Text("1. Inverse (Negatif)"),
                  onPressed: _originalImageFile == null ? null : _applyInverse,
                  backgroundColor: Colors.blue[100],
                ),
                ActionChip(
                  label: const Text("2. Histogram Equalization"),
                  onPressed: _originalImageFile == null ? null : _applyHistogramEq,
                  backgroundColor: Colors.green[100],
                ),
                ActionChip(
                  label: const Text("3. Lowpass (Blur)"),
                  onPressed: _originalImageFile == null ? null : () {
                    // Kernel Mean Filter 3x3
                    _applyConvolution([
                      1/9, 1/9, 1/9,
                      1/9, 1/9, 1/9,
                      1/9, 1/9, 1/9
                    ]);
                  },
                  backgroundColor: Colors.orange[100],
                ),
                ActionChip(
                  label: const Text("4. Highpass (Edge Detection)"),
                  onPressed: _originalImageFile == null ? null : () {
                    // Kernel Laplacian 3x3
                    _applyConvolution([
                      0, -1,  0,
                     -1,  4, -1,
                      0, -1,  0
                    ]);
                  },
                  backgroundColor: Colors.red[100],
                ),
                ActionChip(
                  label: const Text("5. Median Filter (Reduksi Derau)"),
                  onPressed: _originalImageFile == null ? null : _applyMedianFilter,
                  backgroundColor: Colors.teal[100],
                ),
                ActionChip(
                  label: const Text("6. Threshold (Binerisasi)"),
                  onPressed: _originalImageFile == null ? null : _applyThreshold,
                  backgroundColor: Colors.purple[100],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}