import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exception.dart';
import '../widgets/info_card.dart';

/// Demo 3: state cần chia sẻ giữa nhiều widget.
///
/// `_cartCount` được "nâng lên" (lifting state up) widget cha chung gần nhất.
/// Hàm cập nhật phải truyền qua từng tầng (prop drilling) tới nơi cần dùng,
/// và mỗi lần `setState` toàn bộ cây con bên dưới đều build lại.
class SharedStatePage extends StatefulWidget {
  const SharedStatePage({super.key});

  @override
  State<SharedStatePage> createState() => _SharedStatePageState();
}

class _SharedStatePageState extends State<SharedStatePage> {
  static const int _maxItems = 5;
  static const List<String> _products = <String>[
    'Bàn phím cơ',
    'Chuột không dây',
    'Tai nghe',
  ];

  int _cartCount = 0;
  int _buildCount = 0;

  void _addToCart(String product) {
    try {
      if (_cartCount >= _maxItems) {
        throw const CartLimitException('Giỏ hàng đã đầy ($_maxItems món).');
      }
      setState(() => _cartCount++);
    } on AppException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.sharedTitle),
        actions: <Widget>[
          _CartBadge(count: _cartCount),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Số lần build() của trang cha: $_buildCount'),
          const SizedBox(height: 8),
          // Tầng 1 → 2 → 3: onAdd bị truyền qua mọi tầng trung gian.
          _ProductSection(products: _products, onAdd: _addToCart),
          const SizedBox(height: 16),
          const InfoCard(
            title: 'Giới hạn của quản lý state cục bộ',
            lines: <String>[
              'Hai widget anh em (badge và danh sách) phải nhờ cha chung giữ state.',
              'Prop drilling: callback đi qua nhiều widget không dùng đến nó.',
              'setState ở cha build lại cả cây con, kể cả phần không đổi.',
              'State mất khi widget bị gỡ; không chia sẻ được giữa các màn hình.',
              'Ứng dụng lớn cần giải pháp như InheritedWidget, Provider, '
                  'Riverpod hoặc Bloc.',
            ],
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
      child: const Icon(Icons.shopping_cart_outlined),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.products, required this.onAdd});

  final List<String> products;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return _ProductList(products: products, onAdd: onAdd);
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products, required this.onAdd});

  final List<String> products;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final String product in products)
          _ProductTile(name: product, onAdd: () => onAdd(product)),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.name, required this.onAdd});

  final String name;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_shopping_cart),
          tooltip: 'Thêm vào giỏ',
        ),
      ),
    );
  }
}
