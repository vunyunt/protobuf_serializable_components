import 'dart:async';
import 'package:protobuf/protobuf.dart';
import 'proto_serializable.dart';
import 'serializable_component_registry.dart';

typedef SerializableComponentFactory =
    FutureOr<ProtoSerializable> Function(
      GeneratedMessage data, {
      SerializableComponentRegistry? registry,
    });

class ComponentDescriptor {
  final GeneratedMessage defaultInstance;
  final SerializableComponentFactory factory;
  final dynamic meta; // Generic metadata support

  ComponentDescriptor({
    required this.defaultInstance,
    required this.factory,
    this.meta,
  });
}
