export 'naver_map_layer_stub.dart'
    if (dart.library.html) 'naver_map_layer_web.dart'
    if (dart.library.io) 'naver_map_layer_native.dart';
