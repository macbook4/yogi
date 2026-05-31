import 'package:flutter/material.dart';

import 'naver/naver_map_bootstrap.dart';
import 'naver/naver_map_config.dart';
import 'naver/naver_map_layer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNaverMapIfConfigured();
  runApp(const YogiPartyApp());
}

class YogiPartyApp extends StatelessWidget {
  const YogiPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '요기 파티',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: YogiColors.surface,
        fontFamily: 'Apple SD Gothic Neo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: YogiColors.mint,
          surface: YogiColors.surface,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class YogiColors {
  static const ink = Color(0xFF24323F);
  static const muted = Color(0xFF71808F);
  static const line = Color(0xFFE8EDF2);
  static const surface = Color(0xFFFFFAF3);
  static const paper = Color(0xFFFFFFFF);
  static const peach = Color(0xFFFF735C);
  static const peachSoft = Color(0xFFFFE0D7);
  static const mint = Color(0xFF3AC7A8);
  static const mintSoft = Color(0xFFD7F7EF);
  static const yellow = Color(0xFFFFD35A);
  static const blue = Color(0xFF66A6FF);
  static const violet = Color(0xFF8368FF);
}

class PartyPoi {
  const PartyPoi({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.position,
    required this.lat,
    required this.lng,
    required this.tint,
    required this.hexColor,
    this.anchorSource = 'poi',
  });

  final String id;
  final String name;
  final String address;
  final String category;
  final Offset position;
  final double lat;
  final double lng;
  final Color tint;
  final String hexColor;
  final String anchorSource;
}

class PartyCandidate {
  PartyCandidate({
    required this.poi,
    this.agree = 1,
    this.disagree = 0,
    this.selected = false,
  });

  final PartyPoi poi;
  int agree;
  int disagree;
  bool selected;
  final List<String> comments = ['나: 일단 후보로 올려볼게요.'];
}

class LiveParty {
  LiveParty({
    required this.id,
    required this.poi,
    required this.title,
    required this.host,
    required this.profileIcon,
    required this.visibility,
    required this.joinPolicy,
    required this.accessLabel,
    required this.meetupStatus,
    required this.createdAgo,
    required this.memberCount,
    required this.onlineCount,
    required this.pendingCount,
    required this.lastMessage,
    this.mapVisible = true,
    this.joined = false,
    this.requested = false,
  });

  final String id;
  final PartyPoi poi;
  final String title;
  final String host;
  final IconData profileIcon;
  final String visibility;
  final String joinPolicy;
  final String accessLabel;
  String meetupStatus;
  final String createdAgo;
  int memberCount;
  int onlineCount;
  int pendingCount;
  String lastMessage;
  bool mapVisible;
  bool joined;
  bool requested;
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.title,
    required this.profileIcon,
    required this.anchorLabel,
    required this.anchorAddress,
    required this.meetupStatus,
    required this.visibility,
    required this.lastMessage,
    required this.time,
    required this.memberCount,
    required this.onlineCount,
    required this.unreadCount,
    required this.active,
    this.notificationsEnabled = true,
  });

  final String id;
  final String title;
  final IconData profileIcon;
  final String anchorLabel;
  final String anchorAddress;
  final String meetupStatus;
  final String visibility;
  final String lastMessage;
  final String time;
  final int memberCount;
  final int onlineCount;
  final int unreadCount;
  final bool active;
  final bool notificationsEnabled;
}

const samplePois = [
  PartyPoi(
    id: 'poi-1',
    name: '라멘트리 성수',
    address: '서울 성동구 연무장길 12',
    category: '맛집',
    position: Offset(.26, .34),
    lat: 37.544,
    lng: 127.0541,
    tint: YogiColors.peach,
    hexColor: '#FF735C',
  ),
  PartyPoi(
    id: 'poi-2',
    name: '무브커피',
    address: '서울 성동구 아차산로 9길 18',
    category: '카페',
    position: Offset(.65, .28),
    lat: 37.5462,
    lng: 127.058,
    tint: YogiColors.mint,
    hexColor: '#3AC7A8',
  ),
  PartyPoi(
    id: 'poi-3',
    name: '플라자홀',
    address: '서울 성동구 왕십리로 88',
    category: '공연',
    position: Offset(.48, .58),
    lat: 37.5426,
    lng: 127.056,
    tint: YogiColors.blue,
    hexColor: '#66A6FF',
  ),
  PartyPoi(
    id: 'poi-4',
    name: '브릿지카페',
    address: '서울 성동구 둘레길 25',
    category: '카페',
    position: Offset(.27, .72),
    lat: 37.5408,
    lng: 127.0536,
    tint: YogiColors.mint,
    hexColor: '#3AC7A8',
  ),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  PartyPoi? _focusedPoi;
  late final List<LiveParty> _parties = [
    LiveParty(
      id: 'party-1',
      poi: samplePois[0],
      title: '맛커 탐방 지금 같이 갈 사람',
      host: '민지',
      profileIcon: Icons.ramen_dining,
      visibility: 'public',
      joinPolicy: 'instant',
      accessLabel: '제한 없음',
      meetupStatus: '모집 중',
      createdAgo: '방금 열림',
      memberCount: 4,
      onlineCount: 3,
      pendingCount: 0,
      joined: true,
      lastMessage: '민지: 성수역 근처면 다들 오기 편할 것 같아요.',
    ),
    LiveParty(
      id: 'party-2',
      poi: samplePois[2],
      title: '코르티스 공연 보러갈 코어 3명 구해요',
      host: '준호',
      profileIcon: Icons.music_note,
      visibility: 'private',
      joinPolicy: 'approval_required',
      accessLabel: '대학교 인증',
      meetupStatus: '지금 논의 중',
      createdAgo: '12분 전',
      memberCount: 3,
      onlineCount: 1,
      pendingCount: 2,
      lastMessage: '준호: 공연 전 플라자홀에서 모여요.',
    ),
    LiveParty(
      id: 'party-3',
      poi: samplePois[1],
      title: '샤이니 콘서트 2명 커피 마시고 출발',
      host: '하린',
      profileIcon: Icons.local_cafe,
      visibility: 'public',
      joinPolicy: 'instant',
      accessLabel: '제한 없음',
      meetupStatus: '집결 중',
      createdAgo: '28분 전',
      memberCount: 2,
      onlineCount: 2,
      pendingCount: 0,
      lastMessage: '하린: 무브커피 앞에서 기다릴게요.',
    ),
  ];

  final Map<String, List<String>> _messagesByParty = {
    'party-1': [
      '요기: 파티방이 열렸어요. 기준 위치는 라멘트리 성수입니다.',
      '민지: 성수역 근처면 다들 오기 편할 것 같아요.',
    ],
    'party-2': ['요기: 비공개 파티가 열렸어요. 입장 요청이 필요합니다.', '준호: 공연 전 플라자홀에서 모여요.'],
    'party-3': ['요기: 파티방이 열렸어요. 기준 위치는 무브커피입니다.', '하린: 무브커피 앞에서 기다릴게요.'],
  };

  List<ChatRoom> get _rooms => _parties
      .where((party) => party.joined)
      .map(
        (party) => ChatRoom(
          id: party.id,
          title: party.title,
          profileIcon: party.profileIcon,
          anchorLabel: party.poi.name,
          anchorAddress: party.poi.address,
          meetupStatus: party.meetupStatus,
          visibility: party.visibility,
          lastMessage: party.lastMessage,
          time: party.createdAgo,
          memberCount: party.memberCount,
          onlineCount: party.onlineCount,
          unreadCount: _tabIndex == 1 ? 0 : 1,
          active: party.meetupStatus != '종료',
        ),
      )
      .toList();

  List<LiveParty> _partiesAt(PartyPoi poi) {
    return _parties.where((party) => party.poi.id == poi.id).toList();
  }

  void _selectCoordinateAnchor({
    required double lat,
    required double lng,
    required String name,
    required String address,
  }) {
    final id = 'coord-${lat.toStringAsFixed(5)}-${lng.toStringAsFixed(5)}';
    setState(() {
      _focusedPoi = PartyPoi(
        id: id,
        name: name,
        address: address,
        category: '좌표',
        position: const Offset(.5, .5),
        lat: lat,
        lng: lng,
        tint: YogiColors.violet,
        hexColor: '#8368FF',
        anchorSource: 'coordinate',
      );
    });
  }

  void _moveToCurrentLocation() {
    setState(() {
      _focusedPoi = const PartyPoi(
        id: 'current-location',
        name: '내 위치 주변',
        address: '서울 성동구 성수동 현재 위치 기준',
        category: '현재 위치',
        position: Offset(.5, .5),
        lat: 37.5446,
        lng: 127.0558,
        tint: YogiColors.mint,
        hexColor: '#3AC7A8',
        anchorSource: 'coordinate',
      );
    });
  }

  LiveParty _createPartyAt(
    PartyPoi poi, {
    required String title,
    required String visibility,
    required String joinPolicy,
    required String accessLabel,
    required String displayName,
    required IconData profileIcon,
  }) {
    final id = 'party-${_parties.length + 1}';
    final party = LiveParty(
      id: id,
      poi: poi,
      title: title,
      host: displayName,
      profileIcon: profileIcon,
      visibility: visibility,
      joinPolicy: joinPolicy,
      accessLabel: accessLabel,
      meetupStatus: '모집 중',
      createdAgo: '방금 열림',
      memberCount: 1,
      onlineCount: 1,
      pendingCount: 0,
      joined: true,
      lastMessage: '요기: 파티방이 열렸어요. 초대 URL을 공유할 수 있습니다.',
    );
    setState(() {
      _parties.insert(0, party);
      _messagesByParty[id] = [
        '요기: 파티방이 열렸어요. 기준 위치는 ${poi.name}입니다.',
        '나: 여기에서 파티 열었어요.',
      ];
    });
    return party;
  }

  void _openCreatedParty(LiveParty party) {
    _openLiveParty(party);
  }

  void _joinParty(LiveParty party) {
    if (party.visibility == 'private' &&
        party.joinPolicy == 'approval_required') {
      setState(() {
        party.requested = true;
        party.pendingCount += 1;
      });
      return;
    }

    setState(() {
      if (!party.joined) {
        party.joined = true;
        party.memberCount += 1;
        _messagesByParty.putIfAbsent(party.id, () => []);
        _messagesByParty[party.id]!.add('요기: 요기러님이 파티에 입장했습니다.');
      }
    });
    _openLiveParty(party);
  }

  void _openChatRoom(ChatRoom room) {
    final party = _parties.firstWhere((item) => item.id == room.id);
    _openLiveParty(party);
  }

  void _openLiveParty(LiveParty party) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          room: ChatRoom(
            id: party.id,
            title: party.title,
            profileIcon: party.profileIcon,
            anchorLabel: party.poi.name,
            anchorAddress: party.poi.address,
            meetupStatus: party.meetupStatus,
            visibility: party.visibility,
            lastMessage: party.lastMessage,
            time: party.createdAgo,
            memberCount: party.memberCount,
            onlineCount: party.onlineCount,
            unreadCount: 0,
            active: true,
          ),
          messages: _messagesByParty[party.id] ?? const [],
          onSend: (message) {
            setState(() {
              _messagesByParty.putIfAbsent(party.id, () => []);
              _messagesByParty[party.id]!.add('나: $message');
              party.lastMessage = '나: $message';
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeMapPage(
        focusedPoi: _focusedPoi,
        partiesAtFocusedPoi: _focusedPoi == null
            ? const []
            : _partiesAt(_focusedPoi!),
        onPoiTap: (poi) => setState(() => _focusedPoi = poi),
        onMapLongPress: _selectCoordinateAnchor,
        onCurrentLocationTap: _moveToCurrentLocation,
        onCreateParty: _createPartyAt,
        onOpenCreatedParty: _openCreatedParty,
        onJoinParty: _joinParty,
      ),
      TalkListPage(rooms: _rooms, onOpenRoom: _openChatRoom),
      const MyPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _tabIndex,
        indicatorColor: YogiColors.peachSoft,
        backgroundColor: YogiColors.paper,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '톡',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

class HomeMapPage extends StatelessWidget {
  const HomeMapPage({
    super.key,
    required this.focusedPoi,
    required this.partiesAtFocusedPoi,
    required this.onPoiTap,
    required this.onMapLongPress,
    required this.onCurrentLocationTap,
    required this.onCreateParty,
    required this.onOpenCreatedParty,
    required this.onJoinParty,
  });

  final PartyPoi? focusedPoi;
  final List<LiveParty> partiesAtFocusedPoi;
  final ValueChanged<PartyPoi> onPoiTap;
  final void Function({
    required double lat,
    required double lng,
    required String name,
    required String address,
  })
  onMapLongPress;
  final VoidCallback onCurrentLocationTap;
  final LiveParty Function(
    PartyPoi poi, {
    required String title,
    required String visibility,
    required String joinPolicy,
    required String accessLabel,
    required String displayName,
    required IconData profileIcon,
  })
  onCreateParty;
  final ValueChanged<LiveParty> onOpenCreatedParty;
  final ValueChanged<LiveParty> onJoinParty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PrototypeMap(
          pois: samplePois,
          focusedPoi: focusedPoi,
          onPoiTap: onPoiTap,
          onMapLongPress: onMapLongPress,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                AppTopBar(livePartyCount: partiesAtFocusedPoi.length),
                const SizedBox(height: 10),
                const LivePartyCapsule(),
                const Spacer(),
                if (focusedPoi != null)
                  LocationPartySheet(
                    poi: focusedPoi!,
                    parties: partiesAtFocusedPoi,
                    onCreateParty: onCreateParty,
                    onOpenCreatedParty: onOpenCreatedParty,
                    onJoinParty: onJoinParty,
                  )
                else
                  const HomeLivePartySheet(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 142,
          left: 0,
          right: 0,
          child: Center(
            child: SearchMapAreaButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('현재 지도 영역의 파티를 다시 불러왔어요.')),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: focusedPoi == null ? 246 : 348,
          child: CurrentLocationMapButton(
            onPressed: () {
              onCurrentLocationTap();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('내 위치 주변으로 이동했어요.')));
            },
          ),
        ),
      ],
    );
  }
}

class SearchMapAreaButton extends StatelessWidget {
  const SearchMapAreaButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '현 위치로 검색',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: YogiColors.line),
              borderRadius: BorderRadius.circular(999),
              boxShadow: softShadow(),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 17, color: YogiColors.mint),
                SizedBox(width: 6),
                Text(
                  '현 위치로 검색',
                  style: TextStyle(
                    color: YogiColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CurrentLocationMapButton extends StatelessWidget {
  const CurrentLocationMapButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '내 위치로 이동',
      child: Semantics(
        button: true,
        label: '내 위치로 이동',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Ink(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: YogiColors.line),
                borderRadius: BorderRadius.circular(18),
                boxShadow: softShadow(),
              ),
              child: const Icon(Icons.my_location, color: YogiColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.livePartyCount});

  final int livePartyCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: softCardDecoration(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.search, color: YogiColors.mint),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '지도에서 열린 라이브 파티 찾기',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: YogiColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        CircleIconButton(icon: Icons.add, label: '파티 만들기'),
        const SizedBox(width: 8),
        StatusPill(label: livePartyCount == 0 ? '주변' : '$livePartyCount개'),
      ],
    );
  }
}

class PrototypeMap extends StatelessWidget {
  const PrototypeMap({
    super.key,
    required this.pois,
    required this.focusedPoi,
    required this.onPoiTap,
    required this.onMapLongPress,
  });

  final List<PartyPoi> pois;
  final PartyPoi? focusedPoi;
  final ValueChanged<PartyPoi> onPoiTap;
  final void Function({
    required double lat,
    required double lng,
    required String name,
    required String address,
  })
  onMapLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: YogiNaverMapLayer(
                fallback: CustomPaint(
                  painter: MapPainter(),
                  child: const SizedBox.expand(),
                ),
                pois: pois,
                focusedPoiId: focusedPoi?.id,
                candidatePoiIds: const {},
                onPoiTap: (poi) => onPoiTap(poi as PartyPoi),
                onMapLongPress: onMapLongPress,
              ),
            ),
            if (!NaverMapConfig.hasClientId) ...[
              const Positioned(
                left: 28,
                top: 86,
                child: MapEventBadge(icon: Icons.my_location, label: '카메라 이동'),
              ),
              const Positioned(
                right: 22,
                top: 116,
                child: MapEventBadge(icon: Icons.layers_outlined, label: '레이어'),
              ),
              for (final poi in pois)
                Positioned(
                  left: constraints.maxWidth * poi.position.dx - 44,
                  top: constraints.maxHeight * poi.position.dy - 22,
                  child: MapPin(
                    poi: poi,
                    focused: focusedPoi?.id == poi.id,
                    added: false,
                    onTap: () => onPoiTap(poi),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD9F3EA), Color(0xFFFFF0D3), Color(0xFFE2F0FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .64)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 54) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 54) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: .88)
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-40, size.height * .48),
      Offset(size.width + 40, size.height * .33),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * .42, -50),
      Offset(size.width * .58, size.height + 50),
      roadPaint,
    );
    canvas.drawLine(
      Offset(-30, size.height * .78),
      Offset(size.width + 30, size.height * .66),
      roadPaint,
    );

    final stationPaint = Paint()..color = YogiColors.blue;
    final stationCenter = Offset(size.width * .5, size.height * .46);
    canvas.drawCircle(stationCenter, 24, Paint()..color = Colors.white);
    canvas.drawCircle(stationCenter, 19, stationPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.poi,
    required this.focused,
    required this.added,
    required this.onTap,
  });

  final PartyPoi poi;
  final bool focused;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: focused ? 1.08 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 82),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: added ? YogiColors.ink : poi.tint,
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                    bottomLeft: Radius.circular(7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: YogiColors.ink.withValues(alpha: .16),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  poi.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (added)
                const Positioned(
                  right: -6,
                  top: -8,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: YogiColors.yellow,
                    child: Icon(Icons.check, size: 14, color: YogiColors.ink),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapEventBadge extends StatelessWidget {
  const MapEventBadge({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: YogiColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: YogiColors.mint),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class LivePartyCapsule extends StatelessWidget {
  const LivePartyCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: YogiColors.ink,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Icon(Icons.dynamic_feed, color: YogiColors.mint, size: 19),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Live Activity · 주변 파티가 지금 열려 있어요',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            StatusPill(label: '모집 중'),
          ],
        ),
      ),
    );
  }
}

class HomeLivePartySheet extends StatelessWidget {
  const HomeLivePartySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: softCardDecoration(),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHandle(),
            Eyebrow('지도 기반 라이브 파티'),
            SizedBox(height: 4),
            Text(
              '지도에서 위치를 눌러 열린 파티를 확인하세요',
              style: TextStyle(
                fontSize: 21,
                height: 1.16,
                fontWeight: FontWeight.w900,
                color: YogiColors.ink,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'MVP에서는 장소 후보 투표가 아니라, 특정 좌표/POI에 열린 파티를 발견하고 채팅에 합류하는 흐름을 검증합니다.',
              style: TextStyle(
                color: YogiColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                StatusPill(label: '공개/비공개'),
                SizedBox(width: 8),
                StatusPill(label: '즉시 입장'),
                SizedBox(width: 8),
                StatusPill(label: '승인 요청'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPartySheet extends StatefulWidget {
  const LocationPartySheet({
    super.key,
    required this.poi,
    required this.parties,
    required this.onCreateParty,
    required this.onOpenCreatedParty,
    required this.onJoinParty,
  });

  final PartyPoi poi;
  final List<LiveParty> parties;
  final LiveParty Function(
    PartyPoi poi, {
    required String title,
    required String visibility,
    required String joinPolicy,
    required String accessLabel,
    required String displayName,
    required IconData profileIcon,
  })
  onCreateParty;
  final ValueChanged<LiveParty> onOpenCreatedParty;
  final ValueChanged<LiveParty> onJoinParty;

  @override
  State<LocationPartySheet> createState() => _LocationPartySheetState();
}

class _LocationPartySheetState extends State<LocationPartySheet> {
  double _dragOffset = 0;

  void _openFullPage() {
    setState(() => _dragOffset = 0);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => LocationPartyFullPage(
          poi: widget.poi,
          parties: widget.parties,
          onCreateParty: widget.onCreateParty,
          onOpenCreatedParty: widget.onOpenCreatedParty,
          onJoinParty: widget.onJoinParty,
        ),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta == null) return;
        final next = (_dragOffset - details.primaryDelta!).clamp(0.0, 72.0);
        setState(() => _dragOffset = next);
      },
      onVerticalDragEnd: (details) {
        final fastUp = (details.primaryVelocity ?? 0) < -420;
        if (fastUp || _dragOffset > 34) {
          _openFullPage();
          return;
        }
        setState(() => _dragOffset = 0);
      },
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: Offset(0, -_dragOffset / 620),
        child: DecoratedBox(
          decoration: softCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SheetHandle(),
                Eyebrow(
                  '${widget.poi.category} · 현재 열린 파티 ${widget.parties.length}개',
                ),
                const SizedBox(height: 4),
                Text(
                  widget.poi.name,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.16,
                    fontWeight: FontWeight.w900,
                    color: YogiColors.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.poi.address,
                  style: const TextStyle(
                    color: YogiColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (widget.parties.isEmpty)
                  const Text(
                    '아직 이 위치에 열린 파티가 없습니다.',
                    style: TextStyle(
                      color: YogiColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (widget.parties.isNotEmpty)
                  ...widget.parties.map(
                    (party) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LivePartyCard(
                        party: party,
                        onJoin: widget.onJoinParty,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: YogiColors.ink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PartyCreateModal(
                        poi: widget.poi,
                        onCreateParty: widget.onCreateParty,
                        onOpenCreatedParty: widget.onOpenCreatedParty,
                      ),
                    ),
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('이 위치에 파티 만들기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LivePartyCard extends StatelessWidget {
  const LivePartyCard({super.key, required this.party, required this.onJoin});

  final LiveParty party;
  final ValueChanged<LiveParty> onJoin;

  @override
  Widget build(BuildContext context) {
    final isPrivate = party.visibility == 'private';
    final actionLabel = party.joined
        ? '열기'
        : party.requested
        ? '대기 중'
        : isPrivate
        ? '입장 요청'
        : '입장';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: YogiColors.surface,
        border: Border.all(color: YogiColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PartyProfileImage(icon: party.profileIcon, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  party.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: YogiColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PartyMetaIcon(
                icon: isPrivate ? Icons.lock_outline : Icons.lock_open_outlined,
                label: isPrivate ? '비공개파티' : '공개파티',
              ),
              if (party.accessLabel != '제한 없음') ...[
                const SizedBox(width: 6),
                PartyMetaIcon(
                  icon: party.accessLabel.contains('직장')
                      ? Icons.work_outline
                      : Icons.school_outlined,
                  label: party.accessLabel.contains('직장')
                      ? '직장 인증 사용자만 허용'
                      : '내가 인증한 대학교만 허용',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              StatusPill(label: party.meetupStatus),
              StatusPill(label: '${party.memberCount}명'),
              if (party.pendingCount > 0)
                StatusPill(label: '요청 ${party.pendingCount}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${party.createdAgo} · ${party.host} · ${party.lastMessage}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: YogiColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: party.requested
                      ? YogiColors.line
                      : YogiColors.mint,
                  foregroundColor: party.requested
                      ? YogiColors.muted
                      : YogiColors.ink,
                  minimumSize: const Size(76, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: party.requested ? null : () => onJoin(party),
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PartyMetaIcon extends StatelessWidget {
  const PartyMetaIcon({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: YogiColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: YogiColors.ink),
        ),
      ),
    );
  }
}

class PartyProfileImage extends StatelessWidget {
  const PartyProfileImage({super.key, required this.icon, this.size = 44});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: YogiColors.mintSoft,
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(size * .32),
        boxShadow: [
          BoxShadow(
            color: YogiColors.ink.withValues(alpha: .1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: YogiColors.mint, size: size * .5),
    );
  }
}

class PartyProfileChoice extends StatelessWidget {
  const PartyProfileChoice({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '파티 프로필 사진',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: selected ? YogiColors.ink : Colors.white,
            border: Border.all(
              color: selected ? YogiColors.ink : YogiColors.line,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: selected ? Colors.white : YogiColors.muted,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class LocationPartyFullPage extends StatelessWidget {
  const LocationPartyFullPage({
    super.key,
    required this.poi,
    required this.parties,
    required this.onCreateParty,
    required this.onOpenCreatedParty,
    required this.onJoinParty,
  });

  final PartyPoi poi;
  final List<LiveParty> parties;
  final LiveParty Function(
    PartyPoi poi, {
    required String title,
    required String visibility,
    required String joinPolicy,
    required String accessLabel,
    required String displayName,
    required IconData profileIcon,
  })
  onCreateParty;
  final ValueChanged<LiveParty> onOpenCreatedParty;
  final ValueChanged<LiveParty> onJoinParty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YogiColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '뒤로가기',
        ),
        title: Text(poi.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: '닫기',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
        children: [
          PartyCreateLocationPreview(poi: poi),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusPill(label: '오늘 활동 중 우선'),
              const SizedBox(width: 8),
              StatusPill(label: '${parties.length}개'),
              const SizedBox(width: 8),
              const StatusPill(label: '공개/비공개'),
            ],
          ),
          const SizedBox(height: 14),
          for (final party in parties)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LivePartyCard(party: party, onJoin: onJoinParty),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: YogiColors.ink,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => PartyCreateModal(
                poi: poi,
                onCreateParty: onCreateParty,
                onOpenCreatedParty: onOpenCreatedParty,
              ),
            ),
            icon: const Icon(Icons.add_location_alt),
            label: const Text('이 위치에 파티 만들기'),
          ),
        ),
      ),
    );
  }
}

class PartyCreateModal extends StatefulWidget {
  const PartyCreateModal({
    super.key,
    required this.poi,
    required this.onCreateParty,
    required this.onOpenCreatedParty,
  });

  final PartyPoi poi;
  final LiveParty Function(
    PartyPoi poi, {
    required String title,
    required String visibility,
    required String joinPolicy,
    required String accessLabel,
    required String displayName,
    required IconData profileIcon,
  })
  onCreateParty;
  final ValueChanged<LiveParty> onOpenCreatedParty;

  @override
  State<PartyCreateModal> createState() => _PartyCreateModalState();
}

class _PartyCreateModalState extends State<PartyCreateModal> {
  late final TextEditingController _titleController;
  final _profileController = TextEditingController(text: '요기러');
  String _visibility = 'public';
  String _joinPolicy = 'instant';
  String _accessLabel = '제한 없음';
  IconData _partyProfileIcon = Icons.celebration;
  LiveParty? _createdParty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: '${widget.poi.name}에서 지금 같이 갈 사람',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _create() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final party = widget.onCreateParty(
      widget.poi,
      title: title,
      visibility: _visibility,
      joinPolicy: _visibility == 'public' ? 'instant' : _joinPolicy,
      accessLabel: _accessLabel,
      displayName: _profileController.text.trim().isEmpty
          ? '요기러'
          : _profileController.text.trim(),
      profileIcon: _partyProfileIcon,
    );
    setState(() => _createdParty = party);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 760),
        decoration: const BoxDecoration(
          color: YogiColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: _createdParty == null
              ? _buildForm(context)
              : _buildComplete(context, _createdParty!),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final titleLength = _titleController.text.characters.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(child: SheetHandle()),
        const Eyebrow('파티 만들기'),
        const SizedBox(height: 4),
        const Text(
          '이 위치에 라이브 파티를 엽니다',
          style: TextStyle(
            color: YogiColors.ink,
            fontSize: 22,
            height: 1.16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        _CreateSection(
          step: '1',
          title: '기준 위치',
          child: PartyCreateLocationPreview(poi: widget.poi),
        ),
        _CreateSection(
          step: '2',
          title: '파티명',
          trailing: '$titleLength/40',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                maxLength: 40,
                decoration: inputDecoration('예: 샤이니 콘서트 2명'),
                onChanged: (_) => setState(() {}),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('맛커 탐방'),
                    onPressed: () => setState(
                      () => _titleController.text = '맛커 탐방 지금 같이 갈 사람',
                    ),
                  ),
                  ActionChip(
                    label: const Text('같이 가평 놀러가실분'),
                    onPressed: () =>
                        setState(() => _titleController.text = '같이 가평 놀러가실분'),
                  ),
                  ActionChip(
                    label: const Text('여의도 불꽃축제 2명'),
                    onPressed: () =>
                        setState(() => _titleController.text = '여의도 불꽃축제 2명'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  PartyProfileImage(icon: _partyProfileIcon, size: 52),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PartyProfileChoice(
                          icon: Icons.celebration,
                          selected: _partyProfileIcon == Icons.celebration,
                          onTap: () => setState(
                            () => _partyProfileIcon = Icons.celebration,
                          ),
                        ),
                        PartyProfileChoice(
                          icon: Icons.music_note,
                          selected: _partyProfileIcon == Icons.music_note,
                          onTap: () => setState(
                            () => _partyProfileIcon = Icons.music_note,
                          ),
                        ),
                        PartyProfileChoice(
                          icon: Icons.local_cafe,
                          selected: _partyProfileIcon == Icons.local_cafe,
                          onTap: () => setState(
                            () => _partyProfileIcon = Icons.local_cafe,
                          ),
                        ),
                        PartyProfileChoice(
                          icon: Icons.hiking,
                          selected: _partyProfileIcon == Icons.hiking,
                          onTap: () =>
                              setState(() => _partyProfileIcon = Icons.hiking),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '파티 프로필 사진은 선택 입력입니다.',
                style: TextStyle(
                  color: YogiColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _CreateSection(
          step: '3',
          title: '공개/비공개',
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'public', label: Text('공개파티')),
                  ButtonSegment(value: 'private', label: Text('비공개파티')),
                ],
                selected: {_visibility},
                onSelectionChanged: (value) =>
                    setState(() => _visibility = value.first),
              ),
              if (_visibility == 'private') ...[
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'approval_required',
                      label: Text('승인'),
                    ),
                    ButtonSegment(value: 'password', label: Text('비밀번호')),
                    ButtonSegment(
                      value: 'instant_invite',
                      label: Text('초대 URL'),
                    ),
                  ],
                  selected: {_joinPolicy},
                  onSelectionChanged: (value) =>
                      setState(() => _joinPolicy = value.first),
                ),
              ],
            ],
          ),
        ),
        _CreateSection(
          step: '4',
          title: '접근 조건',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('제한 없음'),
                selected: _accessLabel == '제한 없음',
                onSelected: (_) => setState(() => _accessLabel = '제한 없음'),
              ),
              ChoiceChip(
                label: const Text('대학교 인증'),
                selected: _accessLabel == '대학교 인증',
                onSelected: (_) => setState(() => _accessLabel = '대학교 인증'),
              ),
              ChoiceChip(
                label: const Text('직장 인증'),
                selected: _accessLabel == '직장 인증',
                onSelected: (_) => setState(() => _accessLabel = '직장 인증'),
              ),
            ],
          ),
        ),
        _CreateSection(
          step: '5',
          title: '파티용 프로필',
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: YogiColors.yellow,
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: YogiColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _profileController,
                  decoration: inputDecoration('파티용 닉네임'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: YogiColors.ink,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _titleController.text.trim().isEmpty ? null : _create,
            icon: const Icon(Icons.rocket_launch),
            label: const Text('파티 만들기'),
          ),
        ),
      ],
    );
  }

  Widget _buildComplete(BuildContext context, LiveParty party) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(child: SheetHandle()),
        const Eyebrow('생성 완료'),
        const SizedBox(height: 4),
        Row(
          children: [
            PartyProfileImage(icon: party.profileIcon, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                party.title,
                style: const TextStyle(
                  color: YogiColors.ink,
                  fontSize: 22,
                  height: 1.16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PartyCreateLocationPreview(poi: widget.poi),
        const SizedBox(height: 12),
        NeighborhoodInviteList(
          compact: true,
          empty: party.accessLabel == '직장 인증',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: YogiColors.surface,
            border: Border.all(color: YogiColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.link, color: YogiColors.mint),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'https://yogi.party/invite/live-0429',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: YogiColors.ink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onOpenCreatedParty(party);
                },
                icon: const Icon(Icons.chat_bubble),
                label: const Text('채팅 열기'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () {},
              icon: const Icon(Icons.ios_share),
              tooltip: '초대 URL 공유',
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('지도 목록으로 돌아가기'),
          ),
        ),
      ],
    );
  }
}

class NeighborhoodInviteList extends StatefulWidget {
  const NeighborhoodInviteList({
    super.key,
    this.compact = false,
    this.empty = false,
  });

  final bool compact;
  final bool empty;

  @override
  State<NeighborhoodInviteList> createState() => _NeighborhoodInviteListState();
}

class _NeighborhoodInviteListState extends State<NeighborhoodInviteList> {
  final Set<String> _invited = {};

  static const _candidates = [
    _InviteCandidate(name: '수빈', area: '성수2가 · 최근 온라인', online: true),
    _InviteCandidate(name: '도윤', area: '뚝섬 생활권 · 800m', online: false),
    _InviteCandidate(name: '예린', area: '성수1가 · 초대 피로도 낮음', online: true),
  ];

  @override
  Widget build(BuildContext context) {
    final candidates = widget.empty ? const <_InviteCandidate>[] : _candidates;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: YogiColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_add_alt_1,
                color: YogiColors.mint,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  widget.compact ? '동네 초대 가능 사용자' : '초대할 수 있는 동네 사용자',
                  style: const TextStyle(
                    color: YogiColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (candidates.isEmpty)
            const Text(
              '지금 초대할 수 있는 동네 사용자가 없어요',
              style: TextStyle(
                color: YogiColors.muted,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            for (final candidate in candidates.take(widget.compact ? 2 : 3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: YogiColors.mintSoft,
                          child: Text(
                            candidate.name.characters.first,
                            style: const TextStyle(
                              color: YogiColors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (candidate.online)
                          Positioned(
                            right: -1,
                            bottom: -1,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: YogiColors.mint,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            candidate.area,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: YogiColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _invited.contains(candidate.name)
                          ? null
                          : () => setState(() => _invited.add(candidate.name)),
                      child: Text(
                        _invited.contains(candidate.name) ? '완료' : '초대',
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _InviteCandidate {
  const _InviteCandidate({
    required this.name,
    required this.area,
    required this.online,
  });

  final String name;
  final String area;
  final bool online;
}

class PartyCreateLocationPreview extends StatelessWidget {
  const PartyCreateLocationPreview({super.key, required this.poi});

  final PartyPoi poi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: YogiColors.surface,
        border: Border.all(color: YogiColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: YogiColors.mintSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.map, color: YogiColors.mint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poi.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: YogiColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  poi.address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: YogiColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateSection extends StatelessWidget {
  const _CreateSection({
    required this.step,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String step;
  final String title;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: YogiColors.mintSoft,
                child: Text(
                  step,
                  style: const TextStyle(
                    color: YogiColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: YogiColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    color: YogiColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    counterText: '',
    filled: true,
    fillColor: YogiColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  );
}

class CandidateStrip extends StatelessWidget {
  const CandidateStrip({
    super.key,
    required this.candidates,
    required this.onSelect,
  });

  final List<PartyCandidate> candidates;
  final ValueChanged<PartyCandidate> onSelect;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: candidates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final candidate = candidates[index];
          return SizedBox(
            width: 260,
            child: DecoratedBox(
              decoration: softCardDecoration(
                borderColor: candidate.selected
                    ? YogiColors.ink
                    : YogiColors.line,
                color: candidate.selected
                    ? YogiColors.mintSoft
                    : YogiColors.paper,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.poi.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        StatusPill(label: candidate.selected ? '확정' : '후보'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '찬성 ${candidate.agree} · 반대 ${candidate.disagree}',
                      style: const TextStyle(
                        color: YogiColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: YogiColors.ink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => onSelect(candidate),
                        child: const Text('호스트 확정'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SelectedPlaceBanner extends StatelessWidget {
  const SelectedPlaceBanner({super.key, required this.candidate});

  final PartyCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: YogiColors.ink,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: YogiColors.mint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '장소 확정됨',
                    style: TextStyle(
                      color: YogiColors.mint,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    candidate.poi.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TalkListPage extends StatelessWidget {
  const TalkListPage({
    super.key,
    required this.rooms,
    required this.onOpenRoom,
  });

  final List<ChatRoom> rooms;
  final ValueChanged<ChatRoom> onOpenRoom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const PageHeader(title: '톡', subtitle: '파티를 통해 참여한 그룹채팅'),
          const SizedBox(height: 18),
          for (final room in rooms)
            ChatRoomSwipeActions(
              room: room,
              child: ChatRoomTile(room: room, onTap: () => onOpenRoom(room)),
            ),
        ],
      ),
    );
  }
}

class ChatRoomSwipeActions extends StatelessWidget {
  const ChatRoomSwipeActions({
    super.key,
    required this.room,
    required this.child,
  });

  final ChatRoom room;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('room-${room.id}'),
      confirmDismiss: (direction) async {
        final message = direction == DismissDirection.startToEnd
            ? '이 채팅방 알림을 껐어요.'
            : '호스트는 파티 종료 후 나갈 수 있어요.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
          ),
        );
        return false;
      },
      background: const ChatSwipeBackground(
        alignment: Alignment.centerLeft,
        icon: Icons.notifications_off,
        label: '알림 끄기',
        color: YogiColors.mint,
      ),
      secondaryBackground: const ChatSwipeBackground(
        alignment: Alignment.centerRight,
        icon: Icons.logout,
        label: '나가기',
        color: YogiColors.peach,
      ),
      child: child,
    );
  }
}

class ChatSwipeBackground extends StatelessWidget {
  const ChatSwipeBackground({
    super.key,
    required this.alignment,
    required this.icon,
    required this.label,
    required this.color,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  const ChatRoomTile({super.key, required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: softCardDecoration(),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    PartyProfileImage(icon: room.profileIcon, size: 54),
                    if (room.active)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: YogiColors.mint,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: YogiColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${room.memberCount}',
                            style: const TextStyle(
                              color: YogiColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            room.notificationsEnabled
                                ? Icons.notifications_none
                                : Icons.notifications_off_outlined,
                            color: YogiColors.muted,
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            room.time,
                            style: const TextStyle(
                              color: YogiColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: YogiColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (room.unreadCount > 0)
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: YogiColors.peach,
                              child: Text(
                                '${room.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          StatusPill(label: '${room.onlineCount}명 온라인'),
                          StatusPill(label: room.meetupStatus),
                          StatusPill(label: room.anchorLabel),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.room,
    required this.messages,
    required this.onSend,
  });

  final ChatRoom room;
  final List<String> messages;
  final ValueChanged<String> onSend;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _controller = TextEditingController();
  final Set<int> _hiddenMessageIndexes = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    setState(() => _controller.clear());
  }

  List<String> get _participants {
    final names = <String>{'나'};
    for (final message in widget.messages) {
      final parsed = ParsedChatMessage.from(message);
      if (!parsed.system && parsed.sender.isNotEmpty) {
        names.add(parsed.sender);
      }
    }
    return names.toList();
  }

  void _showProfile(String sender) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ParticipantProfileSheet(
        name: sender,
        role: sender == '나' ? '파티장' : '참가자',
        online: sender != '요기',
        hostMode: true,
        onRemove: sender == '나'
            ? null
            : () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$sender님을 파티에서 내보냈습니다.')),
                );
              },
        onTransferHost: sender == '나'
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('방장 넘기기'),
                    content: Text('$sender님에게 방장 권한을 넘길까요?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('취소'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('넘기기'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$sender님이 방장이 되었습니다.')));
              },
      ),
    );
  }

  void _showMembers() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          MembersSheet(members: _participants, onOpenProfile: _showProfile),
    );
  }

  void _showInviteCandidates() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SheetHandle(), NeighborhoodInviteList()],
        ),
      ),
    );
  }

  void _showMessageActions(int index, ParsedChatMessage message) {
    if (message.mine ||
        message.system ||
        _hiddenMessageIndexes.contains(index)) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MessageModerationSheet(
        sender: message.sender,
        onHide: () {
          Navigator.of(context).pop();
          setState(() => _hiddenMessageIndexes.add(index));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('방장이 메시지를 가렸습니다.')));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: ChatRoomHeader(
          room: widget.room,
          onInvite: _showInviteCandidates,
          onMembers: _showMembers,
        ),
      ),
      body: Column(
        children: [
          PartyAnchorCard(room: widget.room),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                final parsed = ParsedChatMessage.from(message);
                return ChatMessageRow(
                  message: message,
                  hidden: _hiddenMessageIndexes.contains(index),
                  onProfileTap: parsed.system
                      ? null
                      : () => _showProfile(parsed.sender),
                  onLongPress: () => _showMessageActions(index, parsed),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '메시지 입력',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward),
                    style: IconButton.styleFrom(
                      backgroundColor: YogiColors.ink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PartyAnchorCard extends StatelessWidget {
  const PartyAnchorCard({super.key, required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: YogiColors.line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: softShadow(),
      ),
      child: Row(
        children: [
          PartyProfileImage(icon: room.profileIcon, size: 44),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.anchorLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: YogiColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  room.anchorAddress,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: YogiColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(label: room.meetupStatus),
          const SizedBox(width: 6),
          StatusPill(label: '${room.onlineCount}명 온라인'),
        ],
      ),
    );
  }
}

class ChatRoomHeader extends StatelessWidget {
  const ChatRoomHeader({
    super.key,
    required this.room,
    required this.onInvite,
    required this.onMembers,
  });

  final ChatRoom room;
  final VoidCallback onInvite;
  final VoidCallback onMembers;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 58,
        color: const Color(0xFFEFF8F5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left),
                tooltip: '뒤로가기',
              ),
            ),
            Positioned(
              left: 86,
              right: 86,
              child: Center(
                child: Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: YogiColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${room.memberCount}',
                    style: const TextStyle(
                      color: YogiColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: '채팅방 메뉴',
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'invite') onInvite();
                      if (value == 'members') onMembers();
                      if (value == 'settings') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('파티 설정은 준비 중입니다.')),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'members', child: Text('멤버 목록')),
                      PopupMenuItem(value: 'invite', child: Text('동네 사용자 초대')),
                      PopupMenuItem(value: 'settings', child: Text('파티 설정')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    super.key,
    required this.message,
    this.hidden = false,
    this.onProfileTap,
    this.onLongPress,
  });

  final String message;
  final bool hidden;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final parsed = ParsedChatMessage.from(message);
    if (parsed.system) {
      return SystemChatMessage(text: parsed.body);
    }

    if (parsed.mine) {
      return Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: ChatBubble(
            text: hidden ? '방장이 가린 메시지입니다.' : parsed.body,
            color: hidden ? YogiColors.line : YogiColors.yellow,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatProfileAvatar(sender: parsed.sender, onTap: onProfileTap),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 4),
                  child: Text(
                    parsed.sender,
                    style: const TextStyle(
                      color: YogiColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                GestureDetector(
                  onLongPress: onLongPress,
                  child: ChatBubble(
                    text: hidden ? '방장이 가린 메시지입니다.' : parsed.body,
                    color: hidden
                        ? YogiColors.line
                        : parsed.sender == '요기'
                        ? YogiColors.mintSoft
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SystemChatMessage extends StatelessWidget {
  const SystemChatMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: YogiColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class ParsedChatMessage {
  const ParsedChatMessage({
    required this.sender,
    required this.body,
    required this.mine,
    required this.system,
  });

  final String sender;
  final String body;
  final bool mine;
  final bool system;

  factory ParsedChatMessage.from(String raw) {
    final separator = raw.indexOf(':');
    if (separator < 0) {
      return ParsedChatMessage(
        sender: 'system',
        body: raw,
        mine: false,
        system: true,
      );
    }

    final sender = raw.substring(0, separator).trim();
    final body = raw.substring(separator + 1).trim();
    final system = sender == '요기';
    return ParsedChatMessage(
      sender: sender.isEmpty ? '요기' : sender,
      body: body.isEmpty ? raw : body,
      mine: sender == '나',
      system: system,
    );
  }
}

class ChatProfileAvatar extends StatelessWidget {
  const ChatProfileAvatar({super.key, required this.sender, this.onTap});

  final String sender;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isYogi = sender == '요기';
    final isHost = sender == '호스트';
    final background = isYogi
        ? YogiColors.mint
        : isHost
        ? YogiColors.ink
        : YogiColors.peachSoft;
    final foreground = isYogi || isHost ? Colors.white : YogiColors.peach;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: background,
            child: isYogi
                ? const Icon(Icons.location_on, size: 18, color: Colors.white)
                : Text(
                    sender.characters.first,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
          ),
          if (!isYogi)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: YogiColors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.color,
    required this.borderRadius,
  });

  final String text;
  final Color color;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 292),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      child: Text(
        text,
        style: const TextStyle(
          color: YogiColors.ink,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class MembersSheet extends StatelessWidget {
  const MembersSheet({
    super.key,
    required this.members,
    required this.onOpenProfile,
  });

  final List<String> members;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          const Text(
            '참가자',
            style: TextStyle(
              color: YogiColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final member in members)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ChatProfileAvatar(sender: member),
              title: Text(
                member,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(member == '나' ? '파티장 · 온라인' : '참가자 · 온라인'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenProfile(member),
            ),
        ],
      ),
    );
  }
}

class ParticipantProfileSheet extends StatelessWidget {
  const ParticipantProfileSheet({
    super.key,
    required this.name,
    required this.role,
    required this.online,
    required this.hostMode,
    this.onRemove,
    this.onTransferHost,
  });

  final String name;
  final String role;
  final bool online;
  final bool hostMode;
  final VoidCallback? onRemove;
  final VoidCallback? onTransferHost;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          Row(
            children: [
              ChatProfileAvatar(sender: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: YogiColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      role,
                      style: const TextStyle(
                        color: YogiColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: online ? YogiColors.mint : YogiColors.line,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                online ? '온라인' : '오프라인',
                style: const TextStyle(
                  color: YogiColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (hostMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.person_remove_outlined),
                    label: const Text('강퇴'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTransferHost,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('방장 넘기기'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class MessageModerationSheet extends StatelessWidget {
  const MessageModerationSheet({
    super.key,
    required this.sender,
    required this.onHide,
  });

  final String sender;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          Text(
            '$sender님의 메시지',
            style: const TextStyle(
              color: YogiColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onHide,
              icon: const Icon(Icons.visibility_off_outlined),
              label: const Text('방장이 메시지 가리기'),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: const [
          PageHeader(title: '마이', subtitle: '회원, 계정, 앱 설정'),
          SizedBox(height: 18),
          ProfileCard(),
          SizedBox(height: 12),
          SettingsGroup(
            title: '계정',
            items: [
              SettingsItem(
                icon: Icons.verified_user_outlined,
                title: '학교 이메일 인증',
                value: '완료',
              ),
              SettingsItem(
                icon: Icons.person_outline,
                title: '파티용 프로필',
                value: '요기러',
              ),
              SettingsItem(icon: Icons.link, title: '초대 링크 관리', value: ''),
            ],
          ),
          SizedBox(height: 12),
          SettingsGroup(
            title: '앱 설정',
            items: [
              SettingsItem(
                icon: Icons.notifications_none,
                title: '채팅 알림',
                value: '켜짐',
              ),
              SettingsItem(
                icon: Icons.location_on_outlined,
                title: '위치 권한',
                value: '앱 사용 중',
              ),
              SettingsItem(
                icon: Icons.security_outlined,
                title: '개인정보와 안전',
                value: '',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: softCardDecoration(color: YogiColors.ink),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: YogiColors.yellow,
              child: Text(
                'Y',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: YogiColors.ink,
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '요기러',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '성수대 인증 멤버 · 초대 전용 파티 3개 참여',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.items});

  final String title;
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: softCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: YogiColors.mint),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                color: YogiColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: YogiColors.muted),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: YogiColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: YogiColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const CircleIconButton(icon: Icons.notifications_none, label: '알림'),
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 44,
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: YogiColors.peach,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD94C39).withValues(alpha: .72),
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: YogiColors.muted,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: YogiColors.mintSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: YogiColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 46,
        height: 5,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: YogiColors.line,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class SheetContainer extends StatelessWidget {
  const SheetContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: softCardDecoration(),
        child: child,
      ),
    );
  }
}

BoxDecoration softCardDecoration({
  Color color = YogiColors.paper,
  Color borderColor = YogiColors.line,
}) {
  return BoxDecoration(
    color: color,
    border: Border.all(color: borderColor),
    borderRadius: BorderRadius.circular(20),
    boxShadow: softShadow(),
  );
}

List<BoxShadow> softShadow() {
  return [
    BoxShadow(
      color: YogiColors.ink.withValues(alpha: .1),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
