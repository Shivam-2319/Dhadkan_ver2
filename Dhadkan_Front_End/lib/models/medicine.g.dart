// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 4;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String?,
      format: fields[1] as String?,
      dosage: fields[2] as String?,
      frequency: fields[3] as String?,
      customFrequency: fields[4] as String?,
      companyName: fields[5] as String?,
      medClass: fields[6] as String?,
      medicineTiming: fields[7] as String?,
      generic: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.format)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.customFrequency)
      ..writeByte(5)
      ..write(obj.companyName)
      ..writeByte(6)
      ..write(obj.medClass)
      ..writeByte(7)
      ..write(obj.medicineTiming)
      ..writeByte(8)
      ..write(obj.generic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
