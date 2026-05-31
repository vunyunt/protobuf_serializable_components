import 'dart:async';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'proto_serializable.dart';
import 'component_descriptor.dart';

class SerializableComponentRegistry {
  final TypeRegistry typeRegistry;
  final dynamic anyProtoDeserializer; // Backwards compatible getter/field
  final Map<String, ComponentDescriptor> _descriptors = {};

  Iterable<String> get registeredQualifiedNames => _descriptors.keys;
  Iterable<GeneratedMessage> get defaultInstances =>
      _descriptors.values.map((d) => d.defaultInstance);

  SerializableComponentRegistry({
    TypeRegistry? typeRegistry,
    dynamic anyProtoDeserializer,
  })  : anyProtoDeserializer = anyProtoDeserializer,
        typeRegistry = typeRegistry ?? (anyProtoDeserializer as dynamic).registry as TypeRegistry;

  void registerDescriptor(ComponentDescriptor descriptor) {
    _descriptors[descriptor.defaultInstance.info_.qualifiedMessageName] =
        descriptor;
  }

  void registerFactory<T extends GeneratedMessage>(
    T defaultInstance,
    dynamic factory,
  ) {
    registerDescriptor(
      ComponentDescriptor(
        defaultInstance: defaultInstance,
        factory: (data, {registry}) {
          if (factory is SerializableComponentFactory) {
            return factory(data, registry: registry);
          }
          if (factory
              is FutureOr<ProtoSerializable> Function(
                T, {
                SerializableComponentRegistry? registry,
              })) {
            return factory(data as T, registry: registry);
          }
          // Handle legacy positional or dynamic factory
          final result = (factory as dynamic)(data);
          if (result is Future) {
            return result.then((v) => v as ProtoSerializable);
          }
          return result as ProtoSerializable;
        },
      ),
    );
  }

  ComponentDescriptor? getDescriptor(String qualifiedName) {
    return _descriptors[qualifiedName];
  }

  FutureOr<T> deserialize<T>(GeneratedMessage message) {
    final qualifiedName = message.info_.qualifiedMessageName;
    final descriptor = _descriptors[qualifiedName];
    if (descriptor == null) {
      throw Exception('No factory registered for type $qualifiedName');
    }
    final result = descriptor.factory(message, registry: this);
    if (result is Future<ProtoSerializable>) {
      return result.then((value) => value as T);
    }
    return result as T;
  }

  FutureOr<T> deserializeFromAny<T>(Any data) {
    final typeUrlParts = data.typeUrl.split('/');
    final qualifiedName = typeUrlParts.last;
    final builderInfo = typeRegistry.lookup(qualifiedName);
    if (builderInfo == null) {
      throw Exception('No builder found in TypeRegistry for typeUrl ${data.typeUrl}');
    }
    final createEmptyInstance = builderInfo.createEmptyInstance;
    if (createEmptyInstance == null) {
      throw Exception('No empty instance creator found for qualifiedName $qualifiedName');
    }
    final payload = createEmptyInstance();
    data.unpackInto(payload);
    return deserialize<T>(payload);
  }
}
