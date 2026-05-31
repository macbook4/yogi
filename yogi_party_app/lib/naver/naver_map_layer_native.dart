import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'naver_map_config.dart';

class YogiNaverMapLayer extends StatelessWidget {
  const YogiNaverMapLayer({
    super.key,
    required this.fallback,
    required this.pois,
    required this.focusedPoiId,
    required this.candidatePoiIds,
    required this.onPoiTap,
    required this.onMapLongPress,
  });

  final Widget fallback;
  final List<dynamic> pois;
  final String? focusedPoiId;
  final Set<String> candidatePoiIds;
  final ValueChanged<dynamic> onPoiTap;
  final void Function({
    required double lat,
    required double lng,
    required String name,
    required String address,
  })
  onMapLongPress;

  @override
  Widget build(BuildContext context) {
    if (!NaverMapConfig.hasClientId ||
        !NaverMapRuntime.initialized ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return fallback;
    }

    return const NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(37.5446, 127.0558),
          zoom: 15,
        ),
      ),
    );
  }
}
