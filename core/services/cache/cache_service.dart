import 'redis/redis_service.dart';

class CacheService {
  CacheService({required this.redis});

  final RedisService redis;

  Future<T> remember<T>({
    required String key,
    Duration ttl = const Duration(seconds: 5),
    required Future<T> Function() callback,
    required T Function(String json) fromJson,
    required String Function(T value) toJson,
  }) async {
    final cached = await redis.redisClient.get(key: key);

    if (cached != null) {
      return fromJson(cached);
    }

    final result = await callback();

    await redis.redisClient.set(
      key: key,
      value: toJson(result),
      ttl: ttl,
    );

    return result;
  }

  Future<void> forget(String key) => redis.redisClient.delete(key: key);

  Future<void> forgetMany(List<String> keys) async {
    await Future.wait(
      keys.map((key) => redis.redisClient.delete(key: key)),
    );
  }
}
