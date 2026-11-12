import 'package:flutter_test/flutter_test.dart';
import 'package:puente/domain/confirmation/data_comparison.dart';

void main() {
  group('DataComparator · importes', () {
    test('3,5 y 35 no coinciden', () {
      final result = DataComparator.compare(
        firstValue: '3,5',
        secondValue: '35',
        kind: DataKind.amount,
      );

      expect(result.matches, isFalse);
      expect(result.kind, DataKind.amount);
    });

    test('1.500 y 1500 sí coinciden', () {
      expect(
        DataComparator.compare(
          firstValue: '1.500',
          secondValue: '1500',
          kind: DataKind.amount,
        ).matches,
        isTrue,
      );
    });

    test('el símbolo de moneda no impide comparar el importe', () {
      expect(
        DataComparator.compare(
          firstValue: r'$35.000',
          secondValue: '35.000',
          kind: DataKind.amount,
        ).matches,
        isTrue,
      );
    });

    test('1.234,56 y 1234,56 coinciden', () {
      expect(
        DataComparator.compare(
          firstValue: '1.234,56',
          secondValue: '1234,56',
          kind: DataKind.amount,
        ).matches,
        isTrue,
      );
    });

    test('35.000 y 35,000 no son el mismo importe en formato rioplatense', () {
      expect(
        DataComparator.compare(
          firstValue: '35.000',
          secondValue: '35,000',
          kind: DataKind.amount,
        ).matches,
        isFalse,
      );
    });

    test('un valor no reconocible no se fuerza a coincidir', () {
      expect(
        DataComparator.compare(
          firstValue: 'treinta y cinco mil',
          secondValue: '35.000',
          kind: DataKind.amount,
        ).matches,
        isFalse,
      );
    });
  });

  group('DataComparator · fechas', () {
    test('3/5/2026 y 03/05/2026 coinciden', () {
      expect(
        DataComparator.compare(
          firstValue: '3/5/2026',
          secondValue: '03/05/2026',
          kind: DataKind.date,
        ).matches,
        isTrue,
      );
    });

    test('distinto año no coincide', () {
      expect(
        DataComparator.compare(
          firstValue: '3/5/2025',
          secondValue: '3/5/2026',
          kind: DataKind.date,
        ).matches,
        isFalse,
      );
    });

    test('día y mes sin año se comparan entre sí', () {
      expect(
        DataComparator.compare(
          firstValue: '3/5',
          secondValue: '03/05',
          kind: DataKind.date,
        ).matches,
        isTrue,
      );
    });

    test('fecha escrita en español coincide con formato numérico', () {
      expect(
        DataComparator.compare(
          firstValue: '15 de noviembre',
          secondValue: '15/11',
          kind: DataKind.date,
        ).matches,
        isTrue,
      );
    });
  });

  group('DataComparator · horarios', () {
    test('9:41 y 09:41 coinciden', () {
      expect(
        DataComparator.compare(
          firstValue: '9:41',
          secondValue: '09:41',
          kind: DataKind.time,
        ).matches,
        isTrue,
      );
    });

    test('18 hs y 18:00 coinciden', () {
      expect(
        DataComparator.compare(
          firstValue: '18 hs',
          secondValue: '18:00',
          kind: DataKind.time,
        ).matches,
        isTrue,
      );
    });

    test('9:41 y 21:41 no coinciden', () {
      expect(
        DataComparator.compare(
          firstValue: '9:41',
          secondValue: '21:41',
          kind: DataKind.time,
        ).matches,
        isFalse,
      );
    });
  });

  group('DataComparator · texto', () {
    test('ignora mayúsculas y espacios repetidos, pero no símbolos', () {
      expect(
        DataComparator.compare(
          firstValue: '  Hola   mundo ',
          secondValue: 'hola mundo',
        ).matches,
        isTrue,
      );
      expect(
        DataComparator.compare(
          firstValue: r'$35.000',
          secondValue: '35.000',
        ).matches,
        isFalse,
      );
    });

    test('un valor vacío nunca coincide', () {
      expect(
        DataComparator.compare(firstValue: '', secondValue: '').matches,
        isFalse,
      );
    });
  });
}
