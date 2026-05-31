import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yogi_party_app/main.dart';

void main() {
  testWidgets('renders main navigation and home map', (tester) async {
    await tester.pumpWidget(const YogiPartyApp());

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('톡'), findsOneWidget);
    expect(find.text('마이'), findsOneWidget);
    expect(find.text('지도에서 열린 라이브 파티 찾기'), findsOneWidget);
    expect(find.text('지도에서 위치를 눌러 열린 파티를 확인하세요'), findsOneWidget);
  });

  testWidgets('toggles chat room notifications from room menu', (tester) async {
    await tester.pumpWidget(const YogiPartyApp());

    await tester.tap(find.text('톡'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('맛커 탐방 지금 같이 갈 사람'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('알림 끄기'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
  });
}
