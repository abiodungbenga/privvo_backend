import 'package:shorebird_redis_client/shorebird_redis_client.dart';
import '../../../shared/constants/app_constants.dart';
import '../../exceptions/app_exceptions.dart';

class RedisService {
  RedisService._() {
    print('redis init');
  }
  static final instance = RedisService._();

  final RedisClient redisClient = RedisClient(
    socket: RedisSocketOptions(
      host: AppConstants.redisHost,
      port: AppConstants.redisPort,
      // password: AppConstants.redisPassword,
      // username: AppConstants.redisUsername,
    ),
    command: const RedisCommandOptions(),
  );

  bool _initialized = false;
  Future<void>? _initFuture;

  Future<void> init() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (_initialized) return;
      await redisClient.connect();
      _initialized = true;
    } on RedisException catch (e) {
      throw DataBaseException('redis error ${e.message}');
    }
  }

  Future<void> expire({
    required String key,
    required Duration ttl,
  }) {
    return redisClient.execute([
      'EXPIRE',
      key,
      ttl.inSeconds,
    ]);
  }
}
