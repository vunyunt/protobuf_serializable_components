import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';

class AnyDeserializer {
  final TypeRegistry registry;

  AnyDeserializer({required this.registry});

  String qualifiedMessageNameFromTypeUrl(final String typeUrl) {
    final typeUrlParts = typeUrl.split('/');
    return typeUrlParts.last;
  }

  String qualifiedMessageNameFromAny(final Any any) {
    return qualifiedMessageNameFromTypeUrl(any.typeUrl);
  }

  dynamic deserialize(final Any? message) {
    if (message == null) {
      return null;
    }

    final builderInfo = registry.lookup(qualifiedMessageNameFromAny(message));
    final createEmptyInstance = builderInfo?.createEmptyInstance;

    if (createEmptyInstance == null) {
      return null;
    }

    final instance = createEmptyInstance();
    message.unpackInto(instance);
    return instance;
  }
}
