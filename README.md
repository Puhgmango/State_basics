# Chủ đề 10: Cơ sở quản lý trạng thái và cập nhật giao diện trong Flutter

Ứng dụng **state_basics_demo** là một app demo nhỏ gồm ba màn hình thực hành: **bộ đếm** để quan sát `setState` làm giao diện cập nhật, **nhật ký vòng đời State** hiển thị trực tiếp từng bước `initState`, `didUpdateWidget`, `build`, `dispose`, và **giỏ hàng** để thấy giới hạn của trạng thái cục bộ khi nhiều widget cần dùng chung dữ liệu. Dự án được làm để minh họa mối quan hệ giữa **state** và **giao diện**, cách dùng **StatelessWidget**, **StatefulWidget** và **setState**, cùng cách xử lý ngoại lệ chặt chẽ.


---

## 1. Thông tin nhóm

| STT | Họ và tên | MSSV | Phụ trách |
|---|---|---|---|
| 1 | Phạm Viết Duy | 106230008 | Cấu hình dự án và tầng lõi (`core/`), domain, kiểm thử, xử lý ngoại lệ, README |
| 2 | Cao Minh Phụng | 106230023 | Giao diện (`widgets/`, `pages/`, `main.dart`, `app.dart`), dàn ý slide |

Tỷ lệ đóng góp: 50% – 50%. Hai thành viên review chéo phần của nhau qua Pull Request.

Trường Đại học Bách khoa, Khoa Điện tử và Trí tuệ nhân tạo.

## 2. Yêu cầu của đề

**Nội dung:**

- Khái niệm state và mối quan hệ giữa state với giao diện.
- `StatelessWidget`, `StatefulWidget`, vòng đời `State` và `setState`.
- Phân biệt trạng thái cục bộ với trạng thái cần chia sẻ.

**Yêu cầu demo:**

- Xây dựng chương trình thể hiện việc cập nhật giao diện theo thay đổi trạng thái.
- Giải thích vòng đời cập nhật và giới hạn của cách quản lý trạng thái cục bộ.
- Cấu trúc thư mục chuẩn, clean code, tuân thủ Dart style guide, xử lý ngoại lệ chặt chẽ, demo app đơn giản.

## 3. Tính năng

- **Màn hình chính** là danh sách ba bài demo, bấm vào để mở từng màn hình.
- **Bộ đếm (setState và cập nhật giao diện):**
  - Giá trị trong khoảng 0 đến 20, chọn **bước nhảy** 1, 2 hoặc 5, có nút giảm, đặt lại và tăng.
  - Hiển thị **số lần `build()`** đã chạy để thấy mỗi lần `setState` làm widget dựng lại.
  - Vượt khoảng cho phép thì hiện thông báo lỗi bằng SnackBar, giá trị giữ nguyên.
  - Phần thử nghiệm **quên gọi `setState`**: nút *Tăng (không setState)* làm biến đổi nhưng giao diện đứng yên, nút *setState rỗng* làm giao diện cập nhật theo giá trị mới.
- **Vòng đời State:**
  - Công tắc **gắn hoặc gỡ** widget thử nghiệm khỏi cây widget (thấy `initState`, `deactivate`, `dispose`).
  - Nút **đổi tham số** `label` (A, B, C) của widget con (thấy `didUpdateWidget`); số lần chạm của widget con vẫn được giữ.
  - Chạm vào widget thử nghiệm để gọi `setState` bên trong chính nó.
  - Khung nhật ký hiển thị tối đa 40 sự kiện gần nhất, có nút xóa nhật ký.
- **Giới hạn của state cục bộ:**
  - Ba sản phẩm, nút thêm vào giỏ, biểu tượng giỏ hàng có huy hiệu đếm ở thanh tiêu đề, giỏ tối đa 5 món.
  - Trạng thái `_cartCount` nằm ở widget cha, hàm cập nhật được truyền qua nhiều tầng widget (prop drilling).
  - Hiển thị số lần `build()` của trang cha để thấy cả cây con bị dựng lại.
- Có thẻ ghi chú giải thích ngay trên mỗi màn hình, tiện cho việc thuyết trình.

## 4. Kiến trúc hệ thống

```
 Sự kiện (chạm nút)
        │
        ▼
 _apply(action) ──► CounterModel.increment()
        │                 │  trả về model mới hoặc ném AppException
        ▼                 ▼
   setState(...)     SnackBar (khi lỗi, state giữ nguyên)
        │
        ▼
 build() chạy lại ──► Giao diện mới
```

| Thành phần | Thư mục | Vai trò |
|---|---|---|
| **Domain** | `lib/features/state_demo/domain/` | `CounterModel`: mô hình bất biến, chứa logic tăng, giảm, đổi bước và kiểm tra giới hạn. Không dựng widget. |
| **Presentation** | `lib/features/state_demo/presentation/` | `pages/`: `HomePage`, `CounterPage`, `LifecyclePage`, `SharedStatePage`; `widgets/`: `InfoCard`. Giữ state cục bộ và hiển thị. |
| **App** | `lib/app/` | `StateBasicsApp`: widget gốc, cấu hình `MaterialApp` và theme. |
| **Hằng số** | `lib/core/constants/` | `AppStrings`: tập trung chuỗi hiển thị. |
| **Errors** | `lib/core/errors/` | `AppException` (lớp `sealed`) và các ngoại lệ nghiệp vụ: `CounterLimitException`, `InvalidInputException`, `CartLimitException`. |
| **Utils** | `lib/core/utils/` | `LifecycleLogger`: ghi và phát nhật ký vòng đời lên màn hình (chỉ dùng cho demo). |

### Luồng cập nhật giao diện

1. Người dùng bấm nút tăng → `onPressed` gọi `_apply(_counter.increment)`.
2. `_apply` chạy thao tác trên `CounterModel` **trước**: model tính giá trị mới, kiểm tra giới hạn rồi trả về một `CounterModel` mới, hoặc ném `CounterLimitException`.
3. Nếu hợp lệ, `_apply` gọi `setState(() => _counter = next)`. Framework đánh dấu element là *dirty* và ở khung hình kế tiếp gọi lại `build()` của `_CounterPageState`, cây con được dựng lại với dữ liệu mới.
4. Nếu có lỗi, `_apply` bắt `on AppException` và hiện SnackBar. `_counter` không đổi nên giao diện không phải dựng lại.
5. Nếu một biến bị sửa mà **không** qua `setState`, dữ liệu đổi nhưng giao diện giữ nguyên cho đến khi có một lần `setState` khác.

```dart
// Chạy thao tác trên model rồi mới setState; lỗi nghiệp vụ không làm đổi state
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

// Model bất biến: mỗi thao tác trả về đối tượng mới hoặc ném ngoại lệ
CounterModel increment() {
  final int next = value + step;
  if (next > maxValue) {
    throw const CounterLimitException('Đã đạt giá trị tối đa ($maxValue).');
  }
  return copyWith(value: next);
}
```

### StatelessWidget và StatefulWidget trong dự án

| Loại | Widget | Lý do |
|---|---|---|
| `StatelessWidget` | `StateBasicsApp`, `HomePage`, `InfoCard` | Giao diện chỉ phụ thuộc vào tham số truyền vào, không có dữ liệu thay đổi theo thời gian. |
| `StatefulWidget` | `CounterPage`, `LifecyclePage`, `LifecycleProbe`, `SharedStatePage` | Có dữ liệu thay đổi khi người dùng thao tác (giá trị đếm, trạng thái gắn/gỡ, số món trong giỏ). |

### Vòng đời của State

| Giai đoạn | Phương thức | Khi nào chạy | Quan sát trong dự án |
|---|---|---|---|
| Tạo | `createState` | Khi widget được đưa vào cây lần đầu | Gắn widget thử nghiệm bằng công tắc |
| Khởi tạo | `initState` | Một lần, ngay sau khi tạo State | Nhật ký ghi `initState` kèm label hiện tại |
| Phụ thuộc | `didChangeDependencies` | Sau `initState` và khi `InheritedWidget` phía trên đổi | Nhật ký ghi `didChangeDependencies` |
| Dựng | `build` | Sau khi khởi tạo và mỗi lần state hoặc tham số đổi | Mỗi lần chạm Probe hoặc đổi label đều thấy thêm `build` |
| Cập nhật | `didUpdateWidget` | Widget cha dựng lại và truyền tham số mới, State được giữ | Nút đổi label, số lần chạm không mất |
| Gỡ | `deactivate`, `dispose` | Khi widget bị gỡ khỏi cây | Tắt công tắc; bật lại tạo State mới nên số lần chạm về 0 |

### Trạng thái cục bộ và trạng thái cần chia sẻ

| | Trạng thái cục bộ | Trạng thái cần chia sẻ |
|---|---|---|
| Ví dụ trong dự án | `_counter` trong `CounterPage`, `_tapCount` trong Probe | `_cartCount` dùng cho cả huy hiệu giỏ hàng và nút thêm |
| Ai giữ | Chính `State` của widget dùng nó | Widget cha chung gần nhất (*lifting state up*) |
| Cách cập nhật | `setState` tại chỗ | Cha giữ state, truyền giá trị xuống và truyền callback lên |

**Giới hạn của cách quản lý cục bộ** (thể hiện ở màn hình thứ ba):

- Hai widget cùng cần một dữ liệu thì buộc phải nâng state lên cha chung.
- Callback bị truyền qua nhiều widget trung gian không dùng đến nó (prop drilling).
- `setState` ở cha làm cả cây con dựng lại, kể cả phần không đổi.
- State mất khi widget bị gỡ và không chia sẻ được giữa các màn hình.
- Ứng dụng lớn cần giải pháp như `InheritedWidget`, `Provider`, `Riverpod` hoặc `Bloc`.

## 5. Cấu trúc thư mục

```
lib/
├── main.dart
├── app/
│   └── app.dart
├── core/
│   ├── constants/
│   │   └── app_strings.dart
│   ├── errors/
│   │   └── app_exception.dart
│   └── utils/
│       └── lifecycle_logger.dart
└── features/
    └── state_demo/
        ├── domain/
        │   └── counter_model.dart
        └── presentation/
            ├── pages/
            │   ├── home_page.dart
            │   ├── counter_page.dart
            │   ├── lifecycle_page.dart
            │   └── shared_state_page.dart
            └── widgets/
                └── info_card.dart
test/
└── counter_model_test.dart
```

## 6. Cách kích hoạt cập nhật giao diện

| Thao tác | Màn hình | Điều xảy ra | Cơ chế |
|---|---|---|---|
| Bấm tăng, giảm, đặt lại | Bộ đếm | Con số và "số lần build()" cập nhật | `setState` trong `_apply` |
| Chọn bước 1, 2, 5 | Bộ đếm | Bước nhảy đổi, các lần bấm sau tăng theo bước mới | `withStep` rồi `setState` |
| Bấm vượt 0 – 20 | Bộ đếm | Hiện SnackBar, giá trị giữ nguyên, không build lại | Ném `CounterLimitException`, bắt trong `_apply` |
| Bấm *Tăng (không setState)* | Bộ đếm | Biến `_staleValue` đổi nhưng giao diện đứng yên | Sửa biến, không gọi `setState` |
| Bấm *setState rỗng* | Bộ đếm | Giao diện cập nhật theo giá trị `_staleValue` mới | `setState(() {})` |
| Gạt công tắc | Vòng đời | Thêm `initState` hoặc `deactivate`, `dispose` vào nhật ký | Gắn hoặc gỡ widget khỏi cây |
| Đổi tham số label | Vòng đời | Thêm `didUpdateWidget`, `build`; số lần chạm được giữ | Cha `setState` đổi tham số, State con được giữ |
| Chạm widget thử nghiệm | Vòng đời | Số lần chạm tăng, chỉ widget này dựng lại | `setState` trong State của Probe |
| Bấm thêm vào giỏ | Chia sẻ state | Huy hiệu giỏ hàng và số lần build của cha cùng thay đổi | `setState` ở cha, cả cây con dựng lại |
| Thêm khi giỏ đã đầy | Chia sẻ state | Hiện SnackBar, không thay đổi giỏ | Ném `CartLimitException`, bắt trong `_addToCart` |

## 7. Bảo đảm cập nhật giao diện đúng và hiệu quả

| Nguyên tắc | Cách thực hiện trong code |
|---|---|
| **Mọi thay đổi state đi qua `setState`** | Giá trị hiển thị chỉ được gán trong `setState(() => ...)`. Phần thử nghiệm *không setState* tồn tại để chỉ ra hậu quả khi vi phạm. |
| **Kiểm tra trước, đổi state sau** | `_apply` chạy thao tác trên model trước; nếu ném ngoại lệ thì `setState` không được gọi và state không bị đổi một nửa. |
| **Model bất biến** | `CounterModel` trả về đối tượng mới qua `copyWith`, không sửa trực tiếp, nên dễ kiểm thử và dễ suy luận. |
| **Tách logic khỏi giao diện** | `CounterModel` không import `flutter`; UI chỉ gọi và hiển thị. |
| **Không cập nhật widget khác khi đang build** | `LifecycleLogger` hoãn việc phát nhật ký bằng `scheduleMicrotask`, tránh lỗi `setState` trong lúc build. |
| **Widget không có state dùng `const` và `StatelessWidget`** | `StateBasicsApp`, `HomePage`, `InfoCard` được khai báo `const` để framework tái sử dụng. |
| **Phản hồi rõ khi lỗi** | Mọi lỗi nghiệp vụ đều dẫn đến SnackBar có thông điệp thân thiện thay vì làm ứng dụng dừng. |
| **Giải phóng tài nguyên** | Mọi dọn dẹp (hủy controller, timer, listener) đặt trong `dispose()`; demo ghi nhận thời điểm `dispose` chạy trong nhật ký. |

Cách kiểm tra bằng tìm kiếm trong mã nguồn (PowerShell, chạy ở thư mục gốc dự án):

```powershell
# 1. setState chỉ xuất hiện trong presentation/pages, không có ở core hay domain
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern "setState\("

# 2. Không dùng print: kết quả rỗng (chỉ dùng debugPrint)
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern "\bprint\("

# 3. Domain không phụ thuộc Flutter: kết quả rỗng
Get-ChildItem lib/features/state_demo/domain -Filter *.dart | Select-String -Pattern "package:flutter"
```

Trong VS Code: `Ctrl+Shift+F`, tìm `setState(` hoặc `package:flutter` trong thư mục `lib`.

## 8. Xử lý ngoại lệ

| Tình huống | Nơi phát sinh | Cách xử lý |
|---|---|---|
| Giá trị bộ đếm ngoài khoảng 0 – 20 | `CounterModel.increment`, `decrement` | Ném `CounterLimitException`; `_apply` bắt `on AppException` và hiện SnackBar. |
| Bước nhảy không nằm trong 1, 2, 5 | `CounterModel.withStep` | Ném `InvalidInputException`; xử lý như trên. |
| Giỏ hàng đã đủ 5 món | `_addToCart` trong `SharedStatePage` | Ném `CartLimitException`; bắt `on AppException` và hiện SnackBar. |
| Lỗi không mong đợi khi xử lý thao tác | `_apply` trong `CounterPage` | Bắt `on Exception`, ghi log bằng `debugPrint`, hiện thông báo chung `AppStrings.unexpectedError`; ứng dụng vẫn chạy. |
| Lỗi trong framework (build, layout, paint) | Toàn ứng dụng | `FlutterError.onError` ghi nhận trong `main.dart`. |
| Lỗi bất đồng bộ không có `try/catch` | Toàn ứng dụng | `PlatformDispatcher.instance.onError` ghi nhận trong `main.dart` và trả về `true` để không làm dừng ứng dụng. |

`AppException` là lớp `sealed`, mỗi ngoại lệ nghiệp vụ đều mang sẵn `message` thân thiện để hiển thị trực tiếp, và `catch` chỉ bắt đúng kiểu cần xử lý (`on AppException`, `on Exception`) thay vì bắt mọi thứ.

## 9. Hướng dẫn chạy

Yêu cầu: Flutter SDK (Dart `^3.5.0`).

```bash
git clone <đường-dẫn-repo>
cd <thư-mục-dự-án>
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Nếu thư mục dự án chưa có các thư mục nền tảng (`windows/`, `web/`, `android/`), chạy thêm `flutter create . --project-name state_basics_demo --platforms=windows,web,android`. Nếu lệnh này sinh ra file `test/widget_test.dart` mặc định thì xóa file đó, vì nó tham chiếu một widget không có trong dự án.

Để thử các tương tác trên máy tính: dùng chuột bấm các nút ở từng màn hình. Ở màn hình vòng đời, gạt công tắc rồi đổi tham số để theo dõi thứ tự sự kiện trong khung nhật ký; nhật ký cũng được in ra console với tiền tố `[Lifecycle]`.

## 10. Công nghệ sử dụng

| Thư viện | Phiên bản | Vai trò |
|---|---|---|
| `flutter` | SDK | Framework giao diện, `StatefulWidget` và `setState` |
| `flutter_test` | SDK | Bộ công cụ kiểm thử đơn vị (5 test cho `CounterModel`) |
| `flutter_lints` | ^5.0.0 | Quy tắc phân tích tĩnh |

`StatelessWidget`, `StatefulWidget`, `ValueNotifier` và `ValueListenableBuilder` đều có sẵn trong Flutter nên không cần thư viện bên ngoài. `analysis_options.yaml` bật thêm các luật `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `prefer_final_locals`, `require_trailing_commas`, `always_declare_return_types`, `avoid_print`, `unawaited_futures`, `use_super_parameters`, `sort_constructors_first`, `directives_ordering`.

## 11. Hạn chế và hướng phát triển

**Hạn chế:**

- Mọi trạng thái chỉ lưu trong bộ nhớ, thoát ứng dụng hoặc gỡ widget là mất.
- Trạng thái dùng chung được chia sẻ bằng cách nâng lên widget cha và truyền callback, chưa dùng giải pháp quản lý state chuyên dụng.
- `LifecycleLogger` dùng biến tĩnh toàn cục để tiện hiển thị nhật ký; cách này chỉ phù hợp cho demo, không nên dùng trong ứng dụng thật.
- Mới có unit test cho `CounterModel`; chưa có widget test cho các màn hình.
- Chuỗi tiếng Việt chưa tách hết khỏi code, chưa hỗ trợ đa ngôn ngữ.
- Chưa kiểm thử trên nhiều kích thước thiết bị và với trình đọc màn hình thật.

**Hướng phát triển:**

- Thay cách chia sẻ state bằng `InheritedWidget`, `Provider`, `Riverpod` hoặc `Bloc` để loại bỏ prop drilling và chỉ dựng lại đúng widget cần thiết.
- Dùng `ValueNotifier` kết hợp `ValueListenableBuilder` để thu hẹp phạm vi dựng lại.
- Lưu trạng thái bền vững bằng `shared_preferences`.
- Viết widget test kiểm tra giao diện đổi theo state và SnackBar khi vượt giới hạn.
- Tách toàn bộ chuỗi hiển thị sang `flutter_localizations`.

## 12. Phân công công việc (WBS)

| Vai trò | Người phụ trách | File chính |
|---|---|---|
| Cấu hình, tầng lõi | Phạm Viết Duy | `pubspec.yaml`, `analysis_options.yaml`, `core/` |
| Domain, kiểm thử | Phạm Viết Duy | `features/state_demo/domain/`, `test/counter_model_test.dart` |
| Giao diện, điểm vào ứng dụng | Cao Minh Phụng | `presentation/widgets/`, `presentation/pages/`, `main.dart`, `app/app.dart` |
| Xử lý ngoại lệ | Cả hai | `core/errors/`, các khối `try/catch` trong `pages/`, `main.dart` |
| Báo cáo, slide | Cả hai (Duy viết README, Phụng dàn ý slide) | `README.md`, file slide |
| Tích hợp | Cả hai | Review chéo Pull Request, chạy `flutter analyze`, `flutter test` và `flutter run` |

Quy trình Git: Duy làm trên nhánh `feature/core-domain`, Phụng làm trên nhánh `feature/presentation`; mỗi nhánh được người còn lại review rồi merge vào `main`, sau đó gắn tag `v1.0`.

## 13. Tài liệu tham khảo

- Flutter, *State management* — https://docs.flutter.dev/data-and-backend/state-mgmt/intro
- Flutter, *Differentiate between ephemeral state and app state* — https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app
- Flutter API: `StatefulWidget`, `State`, `ValueListenableBuilder` — https://api.flutter.dev
- Flutter, *Inside Flutter* — https://docs.flutter.dev/resources/inside-flutter
- Dart, *Effective Dart: Style* — https://dart.dev/effective-dart/style
- Dart, *Language: Class modifiers (`sealed`)* — https://dart.dev/language/class-modifiers
