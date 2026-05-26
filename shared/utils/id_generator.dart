import 'package:uuid/uuid.dart';

const uuid = Uuid();

String get getRandomId => uuid.v4();
