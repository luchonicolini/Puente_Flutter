import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/widgets/not_understood_sheet.dart';

void main() {
  test('NotUnderstoodSheet provides the 4 required offline options', () {
    expect(NotUnderstoodSheet.options.length, 4);
    expect(NotUnderstoodSheet.options, contains('¿Podés repetirlo?'));
    expect(NotUnderstoodSheet.options, contains('¿Podés escribirlo?'));
    expect(NotUnderstoodSheet.options, contains('¿Podés hablar más despacio?'));
    expect(NotUnderstoodSheet.options, contains('¿Podés explicarlo de otra manera?'));
  });
}
