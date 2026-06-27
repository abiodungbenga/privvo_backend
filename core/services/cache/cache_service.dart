import 'redis/redis_service.dart';

class CacheService {
  static Future<T> remember<T>({
    required String key,
    required RedisService redis,
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

  static Future<void> forget(String key, RedisService redis) =>
      redis.redisClient.delete(key: key);

  static Future<void> forgetMany(List<String> keys, RedisService redis) async {
    await Future.wait(
      keys.map((key) => redis.redisClient.delete(key: key)),
    );
  }
}
