import 'package:flutter/foundation.dart';

customPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[37m$message\x1B[0m"); //white
  }
}

void successPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[32m$message\x1B[0m"); //Green
  }
}

void errorPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[31m$message\x1B[0m"); //red
  }
}

void warningPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[33m$message\x1B[0m"); //yellow
  }
}

void alertPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[38;5;214m$message\x1B[0m"); // Orange
  }
}

void encryptionPrint(String message) {
  if (!kReleaseMode) {
    debugPrint("\x1B[36m$message\x1B[0m"); // Cyan
  }
}

void decryptionPrint(String message) {
  if (!kReleaseMode) {
    debugPrint("\x1B[96m$message\x1B[0m"); // Light Cyan
  }
}

void storeDataPrint(String message) {
  if (!kReleaseMode) {
    debugPrint("\x1B[35m$message\x1B[0m"); // Magenta
  }
}

void retrieveDataPrint(String message) {
  if (!kReleaseMode) {
    debugPrint("\x1B[92m$message\x1B[0m"); // Light Green
  }
}

void retrieveDataErrorPrint(String message) {
  if (!kReleaseMode) {
    debugPrint("\x1B[91m$message\x1B[0m"); // Light Red
  }
}
