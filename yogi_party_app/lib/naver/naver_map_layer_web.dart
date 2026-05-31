// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import 'naver_map_config.dart';

class YogiNaverMapLayer extends StatefulWidget {
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
  State<YogiNaverMapLayer> createState() => _YogiNaverMapLayerState();
}

class _YogiNaverMapLayerState extends State<YogiNaverMapLayer> {
  static bool _scriptLoading = false;
  static final _scriptReady = Completer<void>();

  late final String _viewType;
  late final String _callbackName;
  late final String _adminCallbackName;
  late final String _zoomCallbackName;
  html.DivElement? _mapElement;
  Object? _map;
  Object? _maps;
  final Map<String, Object> _markers = {};
  final Map<String, Object> _adminMarkers = {};
  final Map<String, Object> _adminBorders = {};
  String? _selectedAdminAreaId;
  Timer? _levelSyncTimer;
  StreamSubscription<html.WheelEvent>? _wheelSubscription;

  @override
  void initState() {
    super.initState();
    _viewType = 'yogi-naver-map-${DateTime.now().microsecondsSinceEpoch}';
    _callbackName = '__yogiNaverPoiTap${DateTime.now().microsecondsSinceEpoch}';
    _adminCallbackName =
        '__yogiNaverAdminTap${DateTime.now().microsecondsSinceEpoch}';
    _zoomCallbackName =
        '__yogiNaverZoom${DateTime.now().microsecondsSinceEpoch}';
    js_util.setProperty(
      html.window,
      _callbackName,
      js_util.allowInterop(_handleMarkerHtmlTap),
    );
    js_util.setProperty(
      html.window,
      _zoomCallbackName,
      js_util.allowInterop(_handleZoomHtmlTap),
    );
    js_util.setProperty(
      html.window,
      _adminCallbackName,
      js_util.allowInterop(_handleAdminHtmlTap),
    );
    _registerViewFactory();
    _loadScript().then((_) => _mountMap());
  }

  @override
  void dispose() {
    _levelSyncTimer?.cancel();
    _wheelSubscription?.cancel();
    js_util.setProperty(html.window, _callbackName, null);
    js_util.setProperty(html.window, _adminCallbackName, null);
    js_util.setProperty(html.window, _zoomCallbackName, null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant YogiNaverMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMarkerStyles();
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      _mapElement = html.DivElement()
        ..id = 'yogi-naver-map-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = '0'
        ..style.margin = '0'
        ..style.padding = '0';
      scheduleMicrotask(_mountMap);
      return _mapElement!;
    });
  }

  Future<void> _loadScript() {
    if (!NaverMapConfig.hasClientId) return Future.value();
    if (_hasNaverMapObject()) return Future.value();
    if (_scriptReady.isCompleted) return Future.value();
    if (_scriptLoading) return _scriptReady.future;

    _scriptLoading = true;
    final script = html.ScriptElement()
      ..src =
          'https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=${NaverMapConfig.clientId}'
      ..async = true;
    script.onLoad.first.then((_) {
      if (!_scriptReady.isCompleted) _scriptReady.complete();
    });
    script.onError.first.then((_) {
      if (!_scriptReady.isCompleted) {
        _scriptReady.completeError(StateError('Naver Maps JS failed to load'));
      }
    });
    html.document.head!.append(script);
    return _scriptReady.future;
  }

  bool _hasNaverMapObject() {
    final naver = js_util.getProperty<Object?>(html.window, 'naver');
    if (naver == null) return false;
    return js_util.getProperty<Object?>(naver, 'maps') != null;
  }

  void _mountMap() {
    if (!mounted || _mapElement == null || !NaverMapConfig.hasClientId) return;
    if (!_hasNaverMapObject()) return;

    final naver = js_util.getProperty<Object>(html.window, 'naver');
    final maps = js_util.getProperty<Object>(naver, 'maps');
    _maps = maps;
    final latLngConstructor = js_util.getProperty<Object>(maps, 'LatLng');
    final mapConstructor = js_util.getProperty<Object>(maps, 'Map');
    final markerConstructor = js_util.getProperty<Object>(maps, 'Marker');
    final polygonConstructor = js_util.getProperty<Object>(maps, 'Polygon');
    final event = js_util.getProperty<Object>(maps, 'Event');

    final center = js_util.callConstructor<Object>(latLngConstructor, [
      37.5446,
      127.0558,
    ]);
    final options = js_util.jsify({
      'center': center,
      'zoom': 15,
      'scaleControl': false,
      'logoControl': true,
      'mapDataControl': false,
      'zoomControl': false,
      'draggable': true,
      'pinchZoom': true,
      'scrollWheel': true,
      'keyboardShortcuts': true,
      'disableDoubleClickZoom': false,
      'disableDoubleTapZoom': false,
    });

    final map = js_util.callConstructor<Object>(mapConstructor, [
      _mapElement,
      options,
    ]);
    _map = map;
    _scheduleResize();
    _installZoomControls();
    _installWheelZoom();

    _createAdminOverlays(
      map: map,
      maps: maps,
      event: event,
      latLngConstructor: latLngConstructor,
      markerConstructor: markerConstructor,
      polygonConstructor: polygonConstructor,
    );

    for (final poi in widget.pois) {
      final position = js_util.callConstructor<Object>(latLngConstructor, [
        poi.lat,
        poi.lng,
      ]);
      final marker = js_util.callConstructor<Object>(markerConstructor, [
        js_util.jsify({
          'position': position,
          'map': map,
          'title': poi.name,
          'icon': _markerIcon(poi),
          'zIndex': _markerZIndex(poi),
        }),
      ]);
      _markers[poi.id as String] = marker;
      js_util.callMethod(event, 'addListener', [
        marker,
        'click',
        js_util.allowInterop(() => widget.onPoiTap(poi)),
      ]);
    }
    js_util.callMethod(event, 'addListener', [
      map,
      'idle',
      js_util.allowInterop(_scheduleLevelSync),
    ]);
    js_util.callMethod(event, 'addListener', [
      map,
      'zoom_changed',
      js_util.allowInterop(_scheduleLevelSync),
    ]);
    js_util.callMethod(event, 'addListener', [
      map,
      'bounds_changed',
      js_util.allowInterop(_scheduleLevelSync),
    ]);
    _syncVisibleLevel();
    _syncMarkerStyles();
  }

  void _createAdminOverlays({
    required Object map,
    required Object maps,
    required Object event,
    required Object latLngConstructor,
    required Object markerConstructor,
    required Object polygonConstructor,
  }) {
    for (final area in _adminAreas) {
      final center = js_util.callConstructor<Object>(latLngConstructor, [
        area.lat,
        area.lng,
      ]);
      final marker = js_util.callConstructor<Object>(markerConstructor, [
        js_util.jsify({
          'position': center,
          'map': map,
          'title': area.name,
          'icon': _adminMarkerIcon(area, visible: false),
          'zIndex': area.level == _AdminLevel.gu ? 120 : 140,
        }),
      ]);
      _adminMarkers[area.id] = marker;
      js_util.callMethod(event, 'addListener', [
        marker,
        'click',
        js_util.allowInterop(() => _selectAdminArea(area)),
      ]);

      final path = area.path
          .map(
            (point) => js_util.callConstructor<Object>(latLngConstructor, [
              point.lat,
              point.lng,
            ]),
          )
          .toList();
      final polygon = js_util.callConstructor<Object>(polygonConstructor, [
        js_util.jsify({
          'paths': path,
          'strokeColor': '#24323F',
          'strokeOpacity': 0.86,
          'strokeWeight': area.level == _AdminLevel.gu ? 3 : 2,
          'fillColor': '#3AC7A8',
          'fillOpacity': area.level == _AdminLevel.gu ? 0.09 : 0.13,
          'map': null,
          'zIndex': 20,
        }),
      ]);
      _adminBorders[area.id] = polygon;
    }
  }

  void _selectAdminArea(_AdminArea area) {
    _selectedAdminAreaId = area.id;
    _syncAdminBorders();

    final maps = _maps;
    final map = _map;
    if (maps == null || map == null) return;

    final latLngConstructor = js_util.getProperty<Object>(maps, 'LatLng');
    final center = js_util.callConstructor<Object>(latLngConstructor, [
      area.lat,
      area.lng,
    ]);
    final targetZoom = area.level == _AdminLevel.gu ? 13 : 15;
    js_util.callMethod(map, 'morph', [center, targetZoom]);
    Future<void>.delayed(const Duration(milliseconds: 420), _scheduleLevelSync);
  }

  void _scheduleLevelSync([Object? _]) {
    _levelSyncTimer?.cancel();
    _levelSyncTimer = Timer(
      const Duration(milliseconds: 180),
      _syncVisibleLevel,
    );
  }

  void _installZoomControls() {
    final element = _mapElement;
    if (element == null || element.querySelector('.yogi-map-zoom') != null) {
      return;
    }

    final controls = html.DivElement()
      ..className = 'yogi-map-zoom'
      ..style.position = 'absolute'
      ..style.left = '12px'
      ..style.top = '88px'
      ..style.zIndex = '200'
      ..style.display = 'flex'
      ..style.flexDirection = 'column'
      ..style.border = '1px solid rgba(36,50,63,.18)'
      ..style.borderRadius = '10px'
      ..style.overflow = 'hidden'
      ..style.boxShadow = '0 8px 18px rgba(36,50,63,.14)';

    html.ButtonElement zoomButton(String label, int delta) {
      final sign = delta > 0 ? '1' : '-1';
      return html.ButtonElement()
        ..text = label
        ..setAttribute('onclick', 'window.$_zoomCallbackName($sign)')
        ..style.width = '34px'
        ..style.height = '34px'
        ..style.border = '0'
        ..style.background = 'rgba(255,255,255,.94)'
        ..style.color = '#24323F'
        ..style.fontSize = '20px'
        ..style.fontWeight = '900'
        ..style.cursor = 'pointer';
    }

    controls
      ..append(zoomButton('+', 1))
      ..append(zoomButton('−', -1));
    element.append(controls);
  }

  void _installWheelZoom() {
    _wheelSubscription?.cancel();
    _wheelSubscription = _mapElement?.onWheel.listen((event) {
      final target = event.target;
      if (target is html.Element && target.closest('.yogi-map-zoom') != null) {
        return;
      }
      event.preventDefault();
      _changeZoom(event.deltaY < 0 ? 1 : -1);
    });
  }

  void _changeZoom(int delta) {
    final map = _map;
    if (map == null) return;

    final current = _readMapZoom();
    final next = (current + delta).clamp(6, 19).toInt();
    _mapElement
      ?..dataset['requestedZoom'] = next.toString()
      ..dataset['zoomBeforeRequest'] = current.toString();

    try {
      js_util.callMethod(map, 'zoomBy', [delta]);
    } catch (error) {
      _mapElement?.dataset['zoomByError'] = error.toString();
    }

    Future<void>.delayed(const Duration(milliseconds: 90), () {
      if (_readMapZoom() == current) {
        try {
          js_util.callMethod(map, 'setZoom', [next]);
        } catch (error) {
          _mapElement?.dataset['setZoomError'] = error.toString();
        }
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (_readMapZoom() == current) {
        try {
          js_util.callMethod(map, 'setOptions', ['zoom', next]);
        } catch (error) {
          _mapElement?.dataset['setOptionsZoomError'] = error.toString();
        }
      }
    });

    _scheduleLevelSync();
    Future<void>.delayed(const Duration(milliseconds: 320), _syncVisibleLevel);
  }

  void _handleZoomHtmlTap(Object delta) {
    final parsed = delta is num
        ? delta.toInt()
        : int.tryParse(delta.toString());
    if (parsed == null) return;
    _changeZoom(parsed);
  }

  void _syncVisibleLevel() {
    final map = _map;
    if (map == null) return;

    final zoom = _readMapZoom().toDouble();
    final activeLevel = zoom < 13
        ? _AdminLevel.gu
        : zoom < 15
        ? _AdminLevel.dong
        : _AdminLevel.place;
    _mapElement
      ?..dataset['zoom'] = zoom.toStringAsFixed(2)
      ..dataset['level'] = activeLevel.name;

    for (final area in _adminAreas) {
      final marker = _adminMarkers[area.id];
      if (marker == null) continue;
      final visible =
          activeLevel != _AdminLevel.place && area.level == activeLevel;
      js_util.callMethod(marker, 'setIcon', [
        _adminMarkerIcon(area, visible: visible),
      ]);
    }

    for (final poi in widget.pois) {
      final marker = _markers[poi.id];
      if (marker == null) continue;
      js_util.callMethod(marker, 'setIcon', [
        _markerIcon(poi, visible: activeLevel == _AdminLevel.place),
      ]);
    }

    _syncAdminBorders();
    _reviveMarkerPane();
    Future<void>.delayed(const Duration(milliseconds: 120), _reviveMarkerPane);
  }

  int _readMapZoom() {
    final map = _map;
    if (map == null) return 15;

    final rawZoom = js_util.callMethod<Object>(map, 'getZoom', const []);
    if (rawZoom is num) return rawZoom.round();
    return int.tryParse(rawZoom.toString()) ?? 15;
  }

  void _syncAdminBorders() {
    final map = _map;
    for (final entry in _adminBorders.entries) {
      js_util.callMethod(entry.value, 'setMap', [
        entry.key == _selectedAdminAreaId ? map : null,
      ]);
    }
  }

  void _reviveMarkerPane() {
    final element = _mapElement;
    if (element == null) return;

    for (final pane in element.querySelectorAll('div[style*="z-index: 103"]')) {
      final htmlElement = pane as html.HtmlElement;
      if ((htmlElement.text ?? '').trim().isNotEmpty) {
        htmlElement.style.display = 'block';
      }
    }
  }

  void _scheduleResize() {
    for (final delay in const [
      Duration(milliseconds: 0),
      Duration(milliseconds: 80),
      Duration(milliseconds: 240),
      Duration(milliseconds: 600),
    ]) {
      Future<void>.delayed(delay, _resizeMap);
    }
  }

  void _resizeMap() {
    final map = _map;
    final maps = _maps;
    final element = _mapElement;
    if (map == null || maps == null || element == null) return;

    final rect = element.getBoundingClientRect();
    if (rect.width <= 0 || rect.height <= 0) return;

    final sizeConstructor = js_util.getProperty<Object>(maps, 'Size');
    final size = js_util.callConstructor<Object>(sizeConstructor, [
      rect.width,
      rect.height,
    ]);
    js_util.callMethod(map, 'setSize', [size]);

    final event = js_util.getProperty<Object>(maps, 'Event');
    js_util.callMethod(event, 'trigger', [map, 'resize']);
  }

  void _syncMarkerStyles() {
    if (_map == null || _markers.isEmpty) return;
    _syncVisibleLevel();
  }

  Object _adminMarkerIcon(_AdminArea area, {required bool visible}) {
    if (!visible) return _hiddenMarkerIcon();

    final label = _escapeHtml(area.name);
    final subtitle = _escapeHtml(area.subtitle);
    final background = area.level == _AdminLevel.gu
        ? 'rgba(36,50,63,.88)'
        : '#8368FF';
    final width = area.level == _AdminLevel.gu ? 92 : 78;
    const height = 50;
    final id = _escapeJsString(area.id);
    return _htmlMarkerIcon(
      content:
          '''
        <button onclick="window.$_adminCallbackName('$id')" style="
          min-width:${width}px;padding:9px 11px;border:0;border-radius:8px;
          background:$background;color:white;font-weight:900;font-size:12px;
          box-shadow:0 8px 16px rgba(36,50,63,.22);
          transform:translate(-50%,-50%);
          white-space:nowrap;line-height:1.25;">
          <span style="display:block;">$label</span>
          <span style="display:block;opacity:.82;font-size:11px;">$subtitle</span>
        </button>
      ''',
      width: width.toDouble(),
      height: height.toDouble(),
      anchorX: width / 2,
      anchorY: 26,
    );
  }

  void _handleAdminHtmlTap(String areaId) {
    for (final area in _adminAreas) {
      if (area.id == areaId) {
        _selectAdminArea(area);
        return;
      }
    }
  }

  void _handleMarkerHtmlTap(String poiId) {
    for (final poi in widget.pois) {
      if (poi.id == poiId) {
        widget.onPoiTap(poi);
        return;
      }
    }
  }

  int _markerZIndex(dynamic poi) {
    if (widget.focusedPoiId == poi.id) return 300;
    if (widget.candidatePoiIds.contains(poi.id)) return 250;
    return 200;
  }

  Object _markerIcon(dynamic poi, {bool visible = true}) {
    if (!visible) return _hiddenMarkerIcon();

    final added = widget.candidatePoiIds.contains(poi.id);
    final focused = widget.focusedPoiId == poi.id;
    final background = added ? '#24323F' : poi.hexColor;
    final halo = focused ? '#FFD35A' : '#FFFFFF';
    final width = focused ? 112 : 98;
    final height = focused ? 48 : 42;
    final label = _escapeHtml(poi.name as String);
    final id = _escapeJsString(poi.id as String);
    return _htmlMarkerIcon(
      content:
          '''
        <button onclick="window.$_callbackName('$id')" style="
          min-width:${width}px;height:${height}px;padding:0 12px;
          border:3px solid $halo;border-radius:22px 22px 22px 7px;
          background:$background;color:white;font-weight:900;font-size:12px;
          box-shadow:0 10px 18px rgba(36,50,63,.22);
          transform:translate(-50%,-100%);
          white-space:nowrap;">$label${added ? ' ✓' : ''}</button>
      ''',
      width: width.toDouble(),
      height: height.toDouble(),
      anchorX: width / 2,
      anchorY: height.toDouble(),
    );
  }

  Object _htmlMarkerIcon({
    required String content,
    required double width,
    required double height,
    required double anchorX,
    required double anchorY,
  }) {
    final icon = js_util.newObject<Object>();
    js_util.setProperty(icon, 'content', content);

    final maps = _maps;
    if (maps == null) {
      js_util.setProperty(
        icon,
        'anchor',
        js_util.jsify({'x': anchorX, 'y': anchorY}),
      );
      return icon;
    }

    final sizeConstructor = js_util.getProperty<Object>(maps, 'Size');
    final pointConstructor = js_util.getProperty<Object>(maps, 'Point');
    js_util.setProperty(
      icon,
      'size',
      js_util.callConstructor<Object>(sizeConstructor, [width, height]),
    );
    js_util.setProperty(
      icon,
      'anchor',
      js_util.callConstructor<Object>(pointConstructor, [anchorX, anchorY]),
    );
    return icon;
  }

  Object _hiddenMarkerIcon() {
    return _htmlMarkerIcon(
      content:
          '<div style="width:1px;height:1px;opacity:0;pointer-events:none;"></div>',
      width: 1,
      height: 1,
      anchorX: 0.5,
      anchorY: 0.5,
    );
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _escapeJsString(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  }

  @override
  Widget build(BuildContext context) {
    if (!NaverMapConfig.hasClientId) return widget.fallback;
    return HtmlElementView(viewType: _viewType);
  }
}

enum _AdminLevel { gu, dong, place }

class _LatLngPoint {
  const _LatLngPoint(this.lat, this.lng);

  final double lat;
  final double lng;
}

class _AdminArea {
  const _AdminArea({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.level,
    required this.lat,
    required this.lng,
    required this.path,
  });

  final String id;
  final String name;
  final String subtitle;
  final _AdminLevel level;
  final double lat;
  final double lng;
  final List<_LatLngPoint> path;
}

const _adminAreas = [
  _AdminArea(
    id: 'gu-seongdong',
    name: '성동구',
    subtitle: '파티 24',
    level: _AdminLevel.gu,
    lat: 37.546,
    lng: 127.047,
    path: [
      _LatLngPoint(37.5596, 127.0255),
      _LatLngPoint(37.5612, 127.061),
      _LatLngPoint(37.5482, 127.0755),
      _LatLngPoint(37.5328, 127.0648),
      _LatLngPoint(37.5308, 127.0362),
      _LatLngPoint(37.5442, 127.0218),
    ],
  ),
  _AdminArea(
    id: 'gu-gwangjin',
    name: '광진구',
    subtitle: '파티 18',
    level: _AdminLevel.gu,
    lat: 37.544,
    lng: 127.083,
    path: [
      _LatLngPoint(37.5588, 127.0708),
      _LatLngPoint(37.5598, 127.103),
      _LatLngPoint(37.5415, 127.112),
      _LatLngPoint(37.5288, 127.092),
      _LatLngPoint(37.5332, 127.069),
    ],
  ),
  _AdminArea(
    id: 'dong-seongsu1',
    name: '성수1가',
    subtitle: '후보 7',
    level: _AdminLevel.dong,
    lat: 37.5444,
    lng: 127.0479,
    path: [
      _LatLngPoint(37.5512, 127.0394),
      _LatLngPoint(37.5512, 127.0565),
      _LatLngPoint(37.5413, 127.058),
      _LatLngPoint(37.5365, 127.049),
      _LatLngPoint(37.5408, 127.0374),
    ],
  ),
  _AdminArea(
    id: 'dong-seongsu2',
    name: '성수2가',
    subtitle: '후보 9',
    level: _AdminLevel.dong,
    lat: 37.5419,
    lng: 127.0571,
    path: [
      _LatLngPoint(37.5495, 127.0536),
      _LatLngPoint(37.548, 127.0678),
      _LatLngPoint(37.5375, 127.0703),
      _LatLngPoint(37.5328, 127.0607),
      _LatLngPoint(37.5388, 127.0524),
    ],
  ),
  _AdminArea(
    id: 'dong-tteukseom',
    name: '뚝섬',
    subtitle: '후보 5',
    level: _AdminLevel.dong,
    lat: 37.5488,
    lng: 127.0422,
    path: [
      _LatLngPoint(37.5552, 127.0344),
      _LatLngPoint(37.5562, 127.0482),
      _LatLngPoint(37.5492, 127.052),
      _LatLngPoint(37.5425, 127.0445),
      _LatLngPoint(37.545, 127.0328),
    ],
  ),
];
