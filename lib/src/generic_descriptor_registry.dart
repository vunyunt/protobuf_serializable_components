import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'wrapped_descriptor.dart';

abstract class GenericDescriptorRegistry {
  final Map<String, Uint8List> descriptorRegistryMap;
  final ExtensionRegistry extensionRegistry;
  final Map<String, WrappedDescriptor> _cache = {};

  GenericDescriptorRegistry({
    required this.descriptorRegistryMap,
    ExtensionRegistry? extensionRegistry,
  }) : extensionRegistry = extensionRegistry ?? ExtensionRegistry();

  /// Returns the [WrappedDescriptor] for the given [qualifiedName].
  ///
  /// The [qualifiedName] should be like '.game.data.LevelData'.
  /// It can optionally omit the leading dot.
  WrappedDescriptor? getDescriptor(String qualifiedName) {
    // Standardize qualified name to NOT start with a dot
    final key = qualifiedName.startsWith('.')
        ? qualifiedName.substring(1)
        : qualifiedName;

    if (_cache.containsKey(key)) return _cache[key];

    final blob = descriptorRegistryMap[key];
    if (blob == null) return null;

    final descriptor = WrappedDescriptor.fromBytes(blob, extensionRegistry);
    _cache[key] = descriptor;
    return descriptor;
  }

  /// Returns all registered qualified names.
  Iterable<String> get registeredNames => descriptorRegistryMap.keys;
}
