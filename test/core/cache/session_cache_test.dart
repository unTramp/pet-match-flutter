import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/cache/session_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SessionCache', () {
    test('getOrCreateUid генерирует uid и кеширует между вызовами', () async {
      final cache = SessionCache();
      final first = await cache.getOrCreateUid();
      final second = await cache.getOrCreateUid();
      expect(first.isNotEmpty, isTrue);
      expect(first, second);
    });

    test('hasActiveSession=false когда user_id не сохранён', () async {
      final cache = SessionCache();
      expect(await cache.hasActiveSession(), isFalse);
    });

    test('saveUserId → hasActiveSession=true', () async {
      final cache = SessionCache();
      await cache.saveUserId(42);
      expect(await cache.hasActiveSession(), isTrue);
      expect(await cache.getSavedUserId(), 42);
    });

    test('clearSession обнуляет и uid, и user_id', () async {
      final cache = SessionCache();
      final originalUid = await cache.getOrCreateUid();
      await cache.saveUserId(7);
      await cache.clearSession();
      expect(await cache.getSavedUserId(), isNull);
      expect(await cache.hasActiveSession(), isFalse);
      // После clearSession следующий getOrCreateUid создаёт новый uid.
      final newUid = await cache.getOrCreateUid();
      expect(newUid.isNotEmpty, isTrue);
      expect(newUid, isNot(originalUid));
    });
  });
}
