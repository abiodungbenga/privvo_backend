import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

String get getRandomId => uuid.v4();

String generateEncyptionKey() {
  final random = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64Url.encode(random);
}
