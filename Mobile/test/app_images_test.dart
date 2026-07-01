import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_user/core/constants/app_images.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppImages bundle', () {
    for (final path in AppImages.bundled) {
      test('loads $path', () async {
        await rootBundle.load(path);
      });
    }
  });
}
