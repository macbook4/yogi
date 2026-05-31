import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'naver_map_config.dart';

Future<void> initializeNaverMapIfConfigured() async {
  if (!NaverMapConfig.hasClientId) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  await FlutterNaverMap().init(
    clientId: NaverMapConfig.clientId,
    onAuthFailed: (exception) {
      switch (exception) {
        case NQuotaExceededException(:final message):
          debugPrint('Naver Maps quota exceeded: $message');
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAnotherAuthFailedException():
          debugPrint('Naver Maps auth failed: $exception');
      }
    },
  );
  NaverMapRuntime.initialized = true;
}
