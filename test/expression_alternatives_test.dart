import 'package:flutter_test/flutter_test.dart';
import 'package:puente/domain/expression/expression_alternatives.dart';

void main() {
  group('ExpressionAlternatives', () {
    test('no marca un saludo simple como ambiguo', () {
      expect(ExpressionAlternatives.looksAmbiguous('Hola buen día'), isFalse);
      expect(
        ExpressionAlternatives.looksAmbiguous('Necesito retirar un pedido'),
        isFalse,
      );
    });

    test('detecta consulta sin signos de pregunta como ambigua', () {
      expect(
        ExpressionAlternatives.looksAmbiguous('cuanto cuesta la cuota'),
        isTrue,
      );
      expect(
        ExpressionAlternatives.looksAmbiguous('¿cuanto cuesta la cuota?'),
        isFalse,
      );
    });

    test('detecta expresiones de duda como ambiguas', () {
      expect(
        ExpressionAlternatives.looksAmbiguous('Creo que necesito otro turno'),
        isTrue,
      );
    });

    test('conserva el original y formatea pregunta si se elige consulta', () {
      final list = ExpressionAlternatives.generate(
        'cuanto cuesta el envio',
        intent: ExpressionIntent.consultation,
      );

      expect(list.length, 3);
      expect(list[0].text, contains('¿cuanto cuesta el envio?'));
      expect(list[1].text, '¿cuanto cuesta el envio?');
      expect(list[2].text, contains('confirmarme por escrito'));
    });

    test('devuelve lista vacía si la entrada está vacía', () {
      expect(ExpressionAlternatives.generate('   '), isEmpty);
    });
  });
}
