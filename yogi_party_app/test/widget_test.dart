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
}
