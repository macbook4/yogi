import 'package:flutter/widgets.dart';

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
  Widget build(BuildContext context) => fallback;
}
