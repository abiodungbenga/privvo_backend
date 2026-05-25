import 'package:mongo_dart/mongo_dart.dart';

import '../../../shared/constants/app_constants.dart';
import '../../exceptions/app_exceptions.dart';

class MongoService {
  MongoService._();
  static final instance = MongoService._();

  Db? _db;
  bool _initialized = false;

  Future<void> init() async {
    try {
      if ((_db?.isConnected ?? false) && _initialized) return;

      _db = await Db.create(AppConstants.DbUrl);
      await _db!.open();

      _initialized = true;
      // ignore: avoid_catching_errors
    } on MongoDartError catch (e) {
      throw DataBaseException('Mongo error ${e.message}');
    }
  }

  Db? get db => _db;
}
