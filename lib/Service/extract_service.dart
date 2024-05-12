import 'dart:io';

import 'package:file_picker/file_picker.dart';

class AABExtractService {
  /// Function to select the AAB file
  /// Returns the path of the selected AAB file
  /// If the file is not selected, it returns null
  /// If the file is not AAB, it throws an exception
  ///
  static Future<String?> selectAABFile() async {
    FilePickerResult? aabPath;
    try {
      aabPath = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['aab']);
    } catch (e) {
      aabPath = await FilePicker.platform.pickFiles();
    }
    return aabPath?.files.single.path;
  }

  /// @desc Function to select the output directory
  /// Returns the path of the selected output directory
  /// If the directory is not selected, it returns null
  ///
  static Future<String> getOutputDirectory() async {
    String? value = await FilePicker.platform.getDirectoryPath();
    return value!;
  }

  /// @desc Picking keystore path
  /// Returns the path of the selected keystore file
  /// If the file is not selected, it returns null
  /// If the file is not keystore, it throws an exception
  ///
  static Future<String?> selectKeyStoreFilePath() async {
    FilePickerResult? keyStorePath;
    try {
      keyStorePath = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['jks', 'keystore']);
    } catch (e) {
      keyStorePath = await FilePicker.platform.pickFiles();
    }
    return keyStorePath?.files.single.path;
  }

  /// @desc Function to extract the APK from the AAB file
  /// - aabPath: Path of the AAB file
  /// - fileName: Name of the output APK file
  /// - destPath: Path of the output directory
  /// - keystorePath: Path of the keystore file
  /// - keystorePassword: Password of the keystore file
  /// - keyAlias: Alias of the key
  /// - keyPassword: Password of the key
  /// - onLoading: Callback function to show loading
  /// - onSucess: Callback function on success
  /// - onError: Callback function on error
  /// - onFinally: Callback function on completion
  ///
  static Future<void> extractAAB({
    required String aabPath,
    String? fileName,
    String? destPath,
    // For release mode apk
    String? keystorePath,
    String? keystorePassword,
    String? keyAlias,
    String? keyPassword,

    // call back for loding, sucess, error
    Function(bool isLoading)? onLoading,
    Function()? onSucess,
    Function(String error)? onError,
    Function()? onFinally,
  }) async {
    onLoading?.call(true);
    try {
      String outputPath = "apps.apks";
      if (destPath != null) {
        if (fileName != null) {
          outputPath = "$destPath/$fileName.apks";
        } else {
          outputPath = "$destPath/apps.apks";
        }
      }

      // For Normal mode Apk
      List<String> args = [
        '-jar',
        "assets/files/bundletool.jar",
        'build-apks',
        '--bundle=$aabPath',
        '--output=$outputPath',
        '--mode=universal'
      ];

      // Add signing parameters if provided
      if (keystorePath != null &&
          keystorePassword != null &&
          keyAlias != null &&
          keyPassword != null) {
        args.addAll([
          '--ks=$keystorePath',
          '--ks-pass=pass:$keystorePassword',
          '--ks-key-alias=$keyAlias',
          '--key-pass=pass:$keyPassword',
        ]);
      }

      await Process.run('java', args).then((value) {
        if (value.exitCode == 0) {
          onSucess?.call();
        } else {
          onError?.call(value.stderr.toString());
        }
      });
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      onLoading?.call(false);
      onFinally?.call();
    }
  }
}
