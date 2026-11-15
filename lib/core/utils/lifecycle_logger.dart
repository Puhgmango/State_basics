import 'dart:async';

import 'package:flutter/foundation.dart';

/// Ghi lại các sự kiện vòng đời để hiển thị lên màn hình (chỉ dùng cho demo).
///
/// Việc cập nhật [entries] được hoãn bằng [scheduleMicrotask] vì các sự kiện
/// như `build` hay `initState` diễn ra trong giai đoạn build; gọi setState
/// của widget khác ngay lúc đó sẽ gây lỗi.
abstract final class LifecycleLogger {
  static const int _maxEntries = 40;

  static final ValueNotifier<List<String>> entries =
      ValueNotifier<List<String>>(const <String>[]);

  static void log(String event) {
    debugPrint('[Lifecycle] $event');
    scheduleMicrotask(() {
      final List<String> next = <String>[...entries.value, event];
      entries.value = next.length > _maxEntries
          ? next.sublist(next.length - _maxEntries)
          : next;
    });
  }

  static void clear() => entries.value = const <String>[];
}
