// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrugAdapter extends TypeAdapter<Drug> {
  @override
  final int typeId = 3;

  @override
  Drug read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drug(
      id: fields[0] as String?,
      name: fields[1] as String?,
      companyName: fields[2] as String?,
      drugClass: fields[3] as String?,
      format: fields[4] as String?,
      generic: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Drug obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.drugClass)
      ..writeByte(4)
      ..write(obj.format)
      ..writeByte(5)
      ..write(obj.generic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
