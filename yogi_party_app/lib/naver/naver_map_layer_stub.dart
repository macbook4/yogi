import 'package:flutter/widgets.dart';

class YogiNaverMapLayer extends StatelessWidget {
  const YogiNaverMapLayer({
    super.key,
    required this.fallback,
    required this.pois,
    required this.focusedPoiId,
    required this.candidatePoiIds,
    required this.onPoiTap,
  });

  final Widget fallback;
  final List<dynamic> pois;
  final String? focusedPoiId;
  final Set<String> candidatePoiIds;
  final ValueChanged<dynamic> onPoiTap;

  @override
  Widget build(BuildContext context) => fallback;
}
