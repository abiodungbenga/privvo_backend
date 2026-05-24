import 'dart:convert';
import 'package:crypto/crypto.dart';

extension HashStringExtension on String {
  // hasehes the string with sha256
  String get hashedValue {
    return sha256.convert(utf8.encode(this)).toString();
  }
}
