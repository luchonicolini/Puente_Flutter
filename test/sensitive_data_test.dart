import 'package:flutter_test/flutter_test.dart';
import 'package:puente/domain/models/sensitive_data_item.dart';
import 'package:puente/domain/services/sensitive_data_comparator.dart';
import 'package:puente/domain/services/sensitive_data_detector.dart';

void main() {
  group('SensitiveDataComparator', () {
    const comparator = SensitiveDataComparator();

    test('Empty written input returns uncompared status', () {
      final res = comparator.compare(
        detected: r'$5.000',
        written: '   ',
        category: SensitiveDataCategory.price,
      );
      expect(res.status, equals(ComparisonStatus.uncompared));
      expect(res.isMatch, isFalse);
    });

    test('Price comparison matches despite currency symbols, dots, commas and spaces', () {
      final cases = [
        (detected: r'$5.000', written: '5000'),
        (detected: r'$ 18.000', written: '18000'),
        (detected: r'18000 pesos', written: r'$18.000'),
        (detected: r'$1500,00', written: '1500'),
        (detected: r'$1500.00', written: '1500'),
        (detected: r'2500 ARS', written: r'$2.500'),
      ];

      for (final c in cases) {
        final res = comparator.compare(
          detected: c.detected,
          written: c.written,
          category: SensitiveDataCategory.price,
        );
        expect(res.isMatch, isTrue, reason: 'Failed for ${c.detected} vs ${c.written}');
      }
    });

    test('Price comparison detects mismatch correctly', () {
      final res = comparator.compare(
        detected: r'$5.000',
        written: '5500',
        category: SensitiveDataCategory.price,
      );
      expect(res.isMismatch, isTrue);
      expect(res.isMatch, isFalse);
    });

    test('Schedule comparison matches 24h, 12h, and hs suffix variations', () {
      final cases = [
        (detected: '18:30 hs', written: '18:30'),
        (detected: '9:00', written: '09:00 hs'),
        (detected: '10.30 hs', written: '10:30'),
      ];

      for (final c in cases) {
        final res = comparator.compare(
          detected: c.detected,
          written: c.written,
          category: SensitiveDataCategory.schedule,
        );
        expect(res.isMatch, isTrue, reason: 'Failed for ${c.detected} vs ${c.written}');
      }
    });

    test('Date comparison matches with slash or hyphen or "de"', () {
      final cases = [
        (detected: '15 de noviembre', written: '15-noviembre'),
        (detected: '20/11/2026', written: '20-11-2026'),
      ];

      for (final c in cases) {
        final res = comparator.compare(
          detected: c.detected,
          written: c.written,
          category: SensitiveDataCategory.date,
        );
        expect(res.isMatch, isTrue, reason: 'Failed for ${c.detected} vs ${c.written}');
      }
    });
  });

  group('SensitiveDataDetector', () {
    const detector = SensitiveDataDetector();

    test('Detects prices accurately in conversational text', () {
      const text = 'La inscripción sale \$5.000 y la cuota mensual es de \$18.000';
      final detected = detector.extract(text);

      expect(detected.length, equals(2));
      expect(detected[0].category, equals(SensitiveDataCategory.price));
      expect(detected[0].detectedValue, equals(r'$5.000'));
      expect(detected[1].category, equals(SensitiveDataCategory.price));
      expect(detected[1].detectedValue, equals(r'$18.000'));
    });

    test('Detects schedule and date in conversational text', () {
      const text = 'El turno es a las 18:30 hs del 15 de noviembre.';
      final detected = detector.extract(text);

      expect(detected.any((d) => d.category == SensitiveDataCategory.schedule), isTrue);
      expect(detected.any((d) => d.category == SensitiveDataCategory.date), isTrue);
    });

    test('Returns empty list for text without sensitive entities', () {
      const text = 'Hola, ¿cómo estás? Qué lindo día.';
      final detected = detector.extract(text);
      expect(detected, isEmpty);
    });
  });
}
