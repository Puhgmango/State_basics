import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/lifecycle_logger.dart';
import '../widgets/info_card.dart';

/// Demo 2: quan sát vòng đời của [State] qua nhật ký trên màn hình.
class LifecyclePage extends StatefulWidget {
  const LifecyclePage({super.key});

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage> {
  static const List<String> _labels = <String>['A', 'B', 'C'];

  bool _isProbeVisible = true;
  int _labelIndex = 0;

  @override
  void initState() {
    super.initState();
    LifecycleLogger.clear();
  }

  void _toggleProbe(bool value) => setState(() => _isProbeVisible = value);

  void _changeLabel() {
    setState(() => _labelIndex = (_labelIndex + 1) % _labels.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.lifecycleTitle),
        actions: <Widget>[
          IconButton(
            onPressed: LifecycleLogger.clear,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Xóa nhật ký',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SwitchListTile(
            title: const Text('Gắn widget thử nghiệm vào cây'),
            subtitle: const Text('Bật → initState, tắt → deactivate/dispose'),
            value: _isProbeVisible,
            onChanged: _toggleProbe,
          ),
          if (_isProbeVisible) LifecycleProbe(label: _labels[_labelIndex]),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _changeLabel,
            child: const Text('Đổi tham số label (didUpdateWidget)'),
          ),
          const SizedBox(height: 16),
          const _LogPanel(),
          const SizedBox(height: 16),
          const InfoCard(
            title: 'Thứ tự vòng đời',
            lines: <String>[
              'createState → initState → didChangeDependencies → build.',
              'Cập nhật: setState hoặc cha đổi tham số '
                  '(didUpdateWidget) → build.',
              'Gỡ khỏi cây: deactivate → dispose (hủy controller, timer...).',
              'Đổi label: State được giữ nguyên nên số lần chạm không mất.',
              'Tắt/bật lại: tạo State mới nên state cục bộ bị mất.',
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget có State riêng, ghi log ở mỗi bước vòng đời.
class LifecycleProbe extends StatefulWidget {
  const LifecycleProbe({required this.label, super.key});

  final String label;

  @override
  State<LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<LifecycleProbe> {
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    LifecycleLogger.log('initState (label=${widget.label})');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LifecycleLogger.log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant LifecycleProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    LifecycleLogger.log(
      'didUpdateWidget (${oldWidget.label} → ${widget.label})',
    );
  }

  @override
  void deactivate() {
    LifecycleLogger.log('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    LifecycleLogger.log('dispose');
    super.dispose();
  }

  void _onTap() => setState(() => _tapCount++);

  @override
  Widget build(BuildContext context) {
    LifecycleLogger.log('build');
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        title: Text('Probe ${widget.label} — số lần chạm: $_tapCount'),
        subtitle: const Text('Chạm để gọi setState trong chính widget này'),
        onTap: _onTap,
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: LifecycleLogger.entries,
      builder: (BuildContext context, List<String> entries, _) {
        return Container(
          height: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: entries.isEmpty
              ? const Center(child: Text('Chưa có sự kiện.'))
              : ListView.builder(
                  reverse: true,
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final int reversed = entries.length - 1 - index;
                    return Text(
                      '${reversed + 1}. ${entries[reversed]}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    );
                  },
                ),
        );
      },
    );
  }
}
