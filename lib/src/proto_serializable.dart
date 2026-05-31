import 'dart:async';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';

mixin ProtoSerializable<SerializedType extends GeneratedMessage> {
  /// The underlying protobuf data.
  /// Implementing classes must provide this.
  SerializedType get data;

  SerializedType serialize() => data;

  Future<void>? _activeSync;
  bool _pendingSync = false;

  /// Updates the component's data and triggers [onDataUpdated].
  void modify(void Function(SerializedType data) updates) {
    updates(data);
    _triggerSync();
  }

  void _triggerSync() async {
    if (_activeSync != null) {
      _pendingSync = true;
      return;
    }

    final result = onDataUpdated();
    if (result is Future) {
      _activeSync = result;
      await _activeSync;
      _activeSync = null;

      if (_pendingSync) {
        _pendingSync = false;
        _triggerSync();
      }
    }
  }

  /// Hook called after [modify] has updated the data.
  /// Implementing classes can override this to perform synchronization or other side effects.
  @protected
  FutureOr<void> onDataUpdated() {}
}
