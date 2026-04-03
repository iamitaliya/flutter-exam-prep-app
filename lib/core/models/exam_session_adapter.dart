part of 'exam_session.dart';

class ExamSessionAdapter extends TypeAdapter<ExamSession> {
  @override
  final int typeId = 1;

  @override
  ExamSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamSession(
      id: fields[0] as String,
      topicId: fields[1] as String,
      startedAt: fields[2] as DateTime,
      completedAt: fields[3] as DateTime?,
      totalQuestions: fields[4] as int,
      answeredCorrectly: fields[5] as int,
      failedQuestionIds: (fields[6] as List).cast<String>(),
      isPassed: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExamSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.topicId)
      ..writeByte(2)
      ..write(obj.startedAt)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.totalQuestions)
      ..writeByte(5)
      ..write(obj.answeredCorrectly)
      ..writeByte(6)
      ..write(obj.failedQuestionIds)
      ..writeByte(7)
      ..write(obj.isPassed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
