import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

/// Ngoại lệ nghiệp vụ: giá trị vượt giới hạn cho phép.
class LimitException implements Exception {
  const LimitException(this.message);

  final String message;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Widget gốc: không có state nên dùng StatelessWidget.
class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo State Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý trạng thái trong Flutter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          CounterSection(),
          SizedBox(height: 16),
          LifecycleSection(),
          SizedBox(height: 16),
          SharedStateSection(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.note,
    required this.child,
  });

  final String title;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(note, style: textTheme.bodySmall),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. State cục bộ + setState
// ---------------------------------------------------------------------------

class CounterSection extends StatefulWidget {
  const CounterSection({super.key});

  @override
  State<CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  static const int _min = 0;
  static const int _max = 10;

  int _count = 0;
  int _hiddenCount = 0;
  int _buildCount = 0;

  void _change(int delta) {
    try {
      final int next = _count + delta;
      if (next < _min || next > _max) {
        throw const LimitException('Giá trị phải nằm trong khoảng 0 - 10.');
      }
      setState(() => _count = next);
    } on LimitException catch (e) {
      _showMessage(context, e.message);
    }
  }

  /// Sửa biến nhưng KHÔNG gọi setState → UI không cập nhật.
  void _changeWithoutSetState() => _hiddenCount++;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return _SectionCard(
      title: '1. State cục bộ và setState',
      note: 'setState → build() chạy lại → giao diện mới.',
      child: Column(
        children: <Widget>[
          Text(
            '$_count',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text('Số lần build(): $_buildCount'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton.filledTonal(
                onPressed: () => _change(-1),
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => _change(1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Biến không gọi setState (UI hiển thị): $_hiddenCount'),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: _changeWithoutSetState,
                child: const Text('Tăng (không setState)'),
              ),
              OutlinedButton(
                onPressed: () => setState(() {}),
                child: const Text('setState rỗng'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Vòng đời State
// ---------------------------------------------------------------------------

class LifecycleSection extends StatefulWidget {
  const LifecycleSection({super.key});

  @override
  State<LifecycleSection> createState() => _LifecycleSectionState();
}

class _LifecycleSectionState extends State<LifecycleSection> {
  final ValueNotifier<List<String>> _log =
      ValueNotifier<List<String>>(<String>[]);

  bool _isVisible = true;
  int _version = 1;

  /// Ghi log; hoãn bằng microtask vì sự kiện có thể phát sinh trong lúc build.
  void _write(String event) {
    scheduleMicrotask(() {
      if (!mounted) {
        return;
      }
      final List<String> next = <String>[..._log.value, event];
      _log.value = next.length > 12 ? next.sublist(next.length - 12) : next;
    });
  }

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '2. Vòng đời State',
      note: 'Tắt/bật để thấy initState và dispose; đổi tham số để thấy '
          'didUpdateWidget. State được giữ khi đổi tham số, mất khi gỡ.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Gắn widget thử nghiệm'),
            value: _isVisible,
            onChanged: (bool value) => setState(() => _isVisible = value),
          ),
          if (_isVisible) _Probe(version: _version, onEvent: _write),
          TextButton(
            onPressed: () => setState(() => _version++),
            child: const Text('Đổi tham số của widget con'),
          ),
          Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _log,
              builder: (BuildContext context, List<String> logs, _) {
                return SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    logs.isEmpty ? '(chưa có sự kiện)' : logs.join('\n'),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Probe extends StatefulWidget {
  const _Probe({required this.version, required this.onEvent});

  final int version;
  final ValueChanged<String> onEvent;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  int _taps = 0;

  @override
  void initState() {
    super.initState();
    widget.onEvent('initState (v${widget.version})');
  }

  @override
  void didUpdateWidget(covariant _Probe oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.onEvent('didUpdateWidget (v${oldWidget.version} → '
        'v${widget.version})');
  }

  @override
  void deactivate() {
    widget.onEvent('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    widget.onEvent('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onEvent('build');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
      title: Text('Probe v${widget.version} — số lần chạm: $_taps'),
      onTap: () => setState(() => _taps++),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. State cần chia sẻ → nâng state lên widget cha
// ---------------------------------------------------------------------------

class SharedStateSection extends StatefulWidget {
  const SharedStateSection({super.key});

  @override
  State<SharedStateSection> createState() => _SharedStateSectionState();
}

class _SharedStateSectionState extends State<SharedStateSection> {
  static const int _maxItems = 5;

  int _cartCount = 0;
  int _buildCount = 0;

  void _addToCart() {
    try {
      if (_cartCount >= _maxItems) {
        throw const LimitException('Giỏ hàng đã đầy ($_maxItems món).');
      }
      setState(() => _cartCount++);
    } on LimitException catch (e) {
      _showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return _SectionCard(
      title: '3. State cần chia sẻ',
      note: 'Hai widget anh em cùng cần _cartCount nên state phải nằm ở '
          'cha chung. Cha build lại → cả hai con build lại. '
          'Số lần build() của cha: $_buildCount.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _CartBadge(count: _cartCount),
          FilledButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Thêm vào giỏ'),
          ),
        ],
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text('$count'),
      isLabelVisible: count > 0,
      child: const Icon(Icons.shopping_cart_outlined, size: 32),
    );
  }
}
