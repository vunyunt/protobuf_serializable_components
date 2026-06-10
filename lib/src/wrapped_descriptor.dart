import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'proto_gen/google/protobuf/descriptor.pb.dart';

class WrappedDescriptor {
  final DescriptorProto data;
  final Map<int, FieldDescriptorProto> fieldsByTagNumber;

  WrappedDescriptor(this.data) : fieldsByTagNumber = {} {
    for (var field in data.field) {
      fieldsByTagNumber[field.number] = field;
    }
  }

  static WrappedDescriptor fromBytes(
    Uint8List bytes,
    ExtensionRegistry registry,
  ) {
    return WrappedDescriptor(DescriptorProto.fromBuffer(bytes, registry));
  }
}
