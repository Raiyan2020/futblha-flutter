import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'cache/cache_manager.dart';

/// Secure PDF downloader service that handles authenticated PDF downloads
/// and opens them locally to prevent unauthorized access
class SecurePdfDownloader {
  static final SecurePdfDownloader _instance = SecurePdfDownloader._internal();
  factory SecurePdfDownloader() => _instance;
  SecurePdfDownloader._internal();

  Future<bool> downloadAndOpenPdf({
    required String pdfUrl,
    required int fileId,
    String? fileName,
    required BuildContext context,
    bool useCache = true,
  }) async {
    try {
      final String cacheFileName = fileId.toString();

      if (useCache && await isPdfCached(cacheFileName)) {
        final String? cachedPath = await getCachedPdfPath(cacheFileName);
        if (cachedPath != null) {
          debugPrint('Using cached PDF: $cachedPath');
          if (!context.mounted) return false;
          return await _openLocalPdf(cachedPath, context);
        }
      }

      if (!context.mounted) return false;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Downloading PDF...'),
              ],
            ),
          );
        },
      );

      final File? downloadedFile = await _downloadPdfWithAuth(pdfUrl, cacheFileName);

      if (!context.mounted) return false;
      Navigator.of(context).pop();

      if (downloadedFile != null && await downloadedFile.exists()) {
        if (!context.mounted) return false;
        return await _openLocalPdf(downloadedFile.path, context);
      } else {
        if (!context.mounted) return false;
        _showErrorSnackBar(context, 'Failed to download PDF file');
        return false;
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        debugPrint('Error downloading PDF: $e');
        _showErrorSnackBar(context, 'Error downloading PDF: ${e.toString()}');
      }
      return false;
    }
  }

  Future<File?> _downloadPdfWithAuth(String pdfUrl, String? fileName) async {
    try {
      final String authToken = CacheManager.instance.getAuthToken();
      if (authToken.isEmpty) throw Exception('Authentication token not found');

      final Dio dio = Dio();
      final Map<String, String> headers = {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/pdf',
        'Accept-Language': CacheManager.instance.getLanguage() ?? 'en',
      };

      final Directory tempDir = await getTemporaryDirectory();
      final String fileNameWithExt = fileName != null
          ? '$fileName.pdf'
          : 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${tempDir.path}/$fileNameWithExt';

      final Response response = await dio.download(
        pdfUrl,
        filePath,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download progress: $progress%');
          }
        },
      );

      if (response.statusCode == 200) {
        final File file = File(filePath);
        if (await file.exists()) {
          debugPrint('PDF downloaded successfully to: $filePath');
          return file;
        }
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _downloadPdfWithAuth: $e');
      rethrow;
    }
    return null;
  }

  /// ✅ Updated to use open_filex
  Future<bool> _openLocalPdf(String filePath, BuildContext context) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        if (!context.mounted) return false;
        _showErrorSnackBar(context, 'PDF file not found');
        return false;
      }

      final result = await OpenFilex.open(filePath);

      if (!context.mounted) return false;
      if (!context.mounted) return false;
      if (result.type == ResultType.done) {
        _showSuccessSnackBar(context, 'PDF opened successfully');
        return true;
      } else {
        debugPrint('Could not open PDF: ${result.message}');
        _showErrorSnackBar(context, 'Could not open PDF: ${result.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error opening local PDF: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error opening PDF: ${e.toString()}');
      }
      return false;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> cleanupTempFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      for (final FileSystemEntity file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final DateTime fileTime = await file.lastModified();
          final DateTime now = DateTime.now();
          if (now.difference(fileTime).inHours > 24) {
            await file.delete();
            debugPrint('Deleted old PDF file: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }

  Future<bool> isPdfCached(String fileName) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName.pdf';
      return await File(filePath).exists();
    } catch (_) {
      return false;
    }
  }

  Future<String?> getCachedPdfPath(String fileName) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName.pdf';
      if (await File(filePath).exists()) return filePath;
      return null;
    } catch (_) {
      return null;
    }
  }

  bool isUserAuthenticated() {
    final String authToken = CacheManager.instance.getAuthToken();
    return authToken.isNotEmpty;
  }

  Future<bool> validatePdfUrl(String pdfUrl) async {
    try {
      final String authToken = CacheManager.instance.getAuthToken();
      if (authToken.isEmpty) return false;

      final Dio dio = Dio();
      final Response response = await dio.head(
        pdfUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $authToken', 'Accept': 'application/pdf'},
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error validating PDF URL: $e');
      return false;
    }
  }
}
