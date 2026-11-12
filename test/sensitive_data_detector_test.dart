import 'package:flutter_test/flutter_test.dart';
import 'package:puente/domain/confirmation/data_comparison.dart';
import 'package:puente/domain/conversation/sensitive_data_detector.dart';

void main() {
  group('SensitiveDataDetector', () {
    test('detecta dos importes y los etiqueta por contexto cercano', () {
      final detection = SensitiveDataDetector.detect(
        r'La inscripción es de $20.000 y la cuota mensual cuesta $35.000.',
      );

      expect(detection, isNotNull);
      expect(detection!.items['Inscripción'], r'$20.000');
      expect(detection.items['Cuota mensual'], r'$35.000');
    });

    test('etiqueta importes cuando la etiqueta aparece después del valor', () {
      final detection = SensitiveDataDetector.detect(
        r'$20.000 de inscripción y $35.000 de cuota',
      );

      expect(detection, isNotNull);
      expect(detection!.items['Inscripción'], r'$20.000');
      expect(detection.items['Cuota'], r'$35.000');
    });

    test('detecta importes sin símbolo con separador de miles', () {
      final detection = SensitiveDataDetector.detect(
        'La inscripción cuesta 20.000 y la cuota 35.000.',
      );

      expect(detection, isNotNull);
      expect(detection!.items['Inscripción'], '20.000');
      expect(detection.items['Cuota'], '35.000');
    });

    test('etiqueta el total y admite decimales con coma', () {
      final detection = SensitiveDataDetector.detect('El total es 12.345,50');

      expect(detection, isNotNull);
      expect(detection!.items['Total'], '12.345,50');
    });

    test('usa claves únicas cuando no hay contexto', () {
      final detection = SensitiveDataDetector.detect('Pagué 20.000 y 35.000');

      expect(detection, isNotNull);
      expect(detection!.items.keys, ['Importe', 'Importe 2']);
    });

    test('detecta fecha y horario con su tipo sin confundirlos con importes', () {
      final detection = SensitiveDataDetector.detect(
        'Nos vemos el 3/5 a las 9:41',
      );

      expect(detection, isNotNull);
      expect(detection!.items['Fecha'], '3/5');
      expect(detection.items['Horario'], '9:41');
      expect(detection.kinds['Fecha'], DataKind.date);
      expect(detection.kinds['Horario'], DataKind.time);
      expect(detection.items.containsKey('Importe'), isFalse);
    });

    test('detecta fechas en español, horarios con hs e importes juntos', () {
      final detection = SensitiveDataDetector.detect(
        r'El turno del 15 de noviembre es a las 18 hs y sale $12.500',
      );

      expect(detection, isNotNull);
      expect(detection!.items['Fecha de turno'], '15 de noviembre');
      expect(detection.kinds['Fecha de turno'], DataKind.date);
      expect(detection.items['Hora de turno'], '18 hs');
      expect(detection.kinds['Hora de turno'], DataKind.time);
      expect(detection.items['Importe'], r'$12.500');
      expect(detection.kinds['Importe'], DataKind.amount);
    });

    test('no detecta un número sin separadores como importe', () {
      expect(SensitiveDataDetector.detect('El código es 1234'), isNull);
    });

    test('reconoce ARS como moneda explícita', () {
      final detection = SensitiveDataDetector.detect('La seña es ARS 5.000');

      expect(detection, isNotNull);
      expect(detection!.items['Seña'], 'ARS 5.000');
    });
  });
}
