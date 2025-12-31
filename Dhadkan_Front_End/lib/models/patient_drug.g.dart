// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_drug.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientDrugAdapter extends TypeAdapter<PatientDrug> {
  @override
  final int typeId = 5;

  @override
  PatientDrug read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientDrug(
      id: fields[0] as String?,
      weight: fields[1] as int?,
      sbp: fields[2] as int?,
      dbp: fields[3] as int?,
      hr: fields[4] as int?,
      diagnosis: fields[5] as String?,
      otherDiagnosis: fields[6] as String?,
      status: fields[7] as String?,
      canWalk: fields[8] as String?,
      canClimb: fields[9] as String?,
      medicines: (fields[10] as List?)?.cast<Medicine>(),
      createdAt: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PatientDrug obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.sbp)
      ..writeByte(3)
      ..write(obj.dbp)
      ..writeByte(4)
      ..write(obj.hr)
      ..writeByte(5)
      ..write(obj.diagnosis)
      ..writeByte(6)
      ..write(obj.otherDiagnosis)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.canWalk)
      ..writeByte(9)
      ..write(obj.canClimb)
      ..writeByte(10)
      ..write(obj.medicines)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientDrugAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
