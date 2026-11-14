import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/counter_model.dart';
import '../widgets/info_card.dart';

/// Demo 1: state cục bộ + `setState`.
///
/// Luồng cập nhật: sự kiện → thay đổi state trong `setState` → đánh dấu
/// element "dirty" → khung hình tiếp theo gọi lại `build()` → UI mới.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  CounterModel _counter = const CounterModel();

  /// Biến bị sửa mà KHÔNG gọi `setState` để minh họa UI không tự cập nhật.
  int _staleValue = 0;

  /// Đếm số lần `build()` chạy (chỉ phục vụ minh họa).
  int _buildCount = 0;

  /// Thực thi [action] trên model và áp dụng kết quả bằng `setState`.
  ///
  /// Lỗi nghiệp vụ được hiển thị cho người dùng; lỗi khác được ghi log
  /// và hiển thị thông báo chung, không làm sập ứng dụng.
  void _apply(CounterModel Function() action) {
    try {
      final CounterModel next = action();
      setState(() => _counter = next);
    } on AppException catch (e) {
      _showMessage(e.message);
    } on Exception catch (e, stack) {
      debugPrint('[CounterPage] $e\n$stack');
      _showMessage(AppStrings.unexpectedError);
    }
  }

  void _incrementWithoutSetState() {
    _staleValue++; // State đã đổi nhưng framework không biết → UI giữ nguyên.
    _showMessage('Đã tăng _staleValue = $_staleValue nhưng UI chưa vẽ lại.');
  }

  void _forceRebuild() => setState(() {});

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.counterTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Center(
            child: Text('${_counter.value}', style: textTheme.displayLarge),
          ),
          Center(child: Text('Số lần build(): $_buildCount')),
          const SizedBox(height: 16),
          _StepSelector(
            selected: _counter.step,
            onSelected: (int step) => _apply(() => _counter.withStep(step)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton.filledTonal(
                onPressed: () => _apply(_counter.decrement),
                icon: const Icon(Icons.remove),
                tooltip: 'Giảm',
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () => _apply(_counter.reset),
                icon: const Icon(Icons.refresh),
                tooltip: 'Đặt lại',
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => _apply(_counter.increment),
                icon: const Icon(Icons.add),
                tooltip: 'Tăng',
              ),
            ],
          ),
          const Divider(height: 40),
          Text('Thử nghiệm: quên gọi setState', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('_staleValue hiển thị trên UI: $_staleValue'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: _incrementWithoutSetState,
                child: const Text('Tăng (không setState)'),
              ),
              OutlinedButton(
                onPressed: _forceRebuild,
                child: const Text('Gọi setState rỗng'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const InfoCard(
            title: 'Giải thích',
            lines: <String>[
              'setState báo cho framework biết state đã đổi và cần build lại.',
              'Chỉ widget sở hữu State (và con của nó) được build lại.',
              'Sửa biến mà không gọi setState → dữ liệu đổi nhưng UI không đổi.',
              'Logic kiểm tra giới hạn nằm ở CounterModel, UI chỉ bắt ngoại lệ.',
            ],
          ),
        ],
      ),
    );
  }
}

class _StepSelector extends StatelessWidget {
  const _StepSelector({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: <ButtonSegment<int>>[
        for (final int step in CounterModel.allowedSteps)
          ButtonSegment<int>(value: step, label: Text('Bước $step')),
      ],
      selected: <int>{selected},
      onSelectionChanged: (Set<int> values) => onSelected(values.first),
    );
  }
}
