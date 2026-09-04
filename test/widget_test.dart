import 'package:flutter_test/flutter_test.dart';
import 'package:controle_extras/main.dart';

void main() {
  testWidgets(
    'Aplicativo Controle de Extras inicia corretamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ControleExtrasApp());

      await tester.pumpAndSettle();

      expect(
        find.text('CONTROLE DE EXTRAS'),
        findsOneWidget,
      );
    },
  );
}