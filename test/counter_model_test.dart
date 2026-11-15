import 'package:flutter_test/flutter_test.dart';
import 'package:state_basics_demo/core/errors/app_exception.dart';
import 'package:state_basics_demo/features/state_demo/domain/counter_model.dart';

void main() {
  group('CounterModel', () {
    test('increment tăng theo step', () {
      final CounterModel result =
          const CounterModel(step: 2).increment().increment();
      expect(result.value, 4);
    });

    test('decrement dưới 0 ném CounterLimitException', () {
      expect(
        () => const CounterModel().decrement(),
        throwsA(isA<CounterLimitException>()),
      );
    });

    test('increment vượt max ném CounterLimitException', () {
      expect(
        () => const CounterModel(value: CounterModel.maxValue).increment(),
        throwsA(isA<CounterLimitException>()),
      );
    });

    test('withStep không hợp lệ ném InvalidInputException', () {
      expect(
        () => const CounterModel().withStep(3),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('reset giữ nguyên step', () {
      final CounterModel result =
          const CounterModel(value: 10, step: 5).reset();
      expect(result.value, 0);
      expect(result.step, 5);
    });
  });
}
