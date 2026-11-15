import '../../../core/errors/app_exception.dart';

/// Mô hình trạng thái bất biến của bộ đếm.
///
/// Mọi thao tác trả về một đối tượng mới thay vì sửa trực tiếp, nhờ đó
/// logic nghiệp vụ tách khỏi UI và dễ kiểm thử.
class CounterModel {
  const CounterModel({this.value = 0, this.step = 1});

  static const int minValue = 0;
  static const int maxValue = 20;
  static const List<int> allowedSteps = <int>[1, 2, 5];

  final int value;
  final int step;

  /// Tăng giá trị theo [step].
  ///
  /// Ném [CounterLimitException] nếu vượt [maxValue].
  CounterModel increment() {
    final int next = value + step;
    if (next > maxValue) {
      throw const CounterLimitException('Đã đạt giá trị tối đa ($maxValue).');
    }
    return copyWith(value: next);
  }

  /// Giảm giá trị theo [step].
  ///
  /// Ném [CounterLimitException] nếu nhỏ hơn [minValue].
  CounterModel decrement() {
    final int next = value - step;
    if (next < minValue) {
      throw const CounterLimitException('Đã đạt giá trị tối thiểu ($minValue).');
    }
    return copyWith(value: next);
  }

  /// Đổi bước nhảy. Ném [InvalidInputException] nếu không nằm trong
  /// [allowedSteps].
  CounterModel withStep(int newStep) {
    if (!allowedSteps.contains(newStep)) {
      throw InvalidInputException('Bước nhảy không hợp lệ: $newStep.');
    }
    return copyWith(step: newStep);
  }

  CounterModel reset() => CounterModel(step: step);

  CounterModel copyWith({int? value, int? step}) {
    return CounterModel(value: value ?? this.value, step: step ?? this.step);
  }
}
