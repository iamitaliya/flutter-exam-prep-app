part of 'topic_progress.dart';

class TopicProgressAdapter extends TypeAdapter<TopicProgress> {
  @override
  final int typeId = 0;

  @override
  TopicProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopicProgress(
      topicId: fields[0] as String,
      totalAttempted: fields[1] as int,
      totalCorrect: fields[2] as int,
      failedQuestionIds: (fields[3] as List).cast<String>(),
      lastAttemptedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TopicProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.topicId)
      ..writeByte(1)
      ..write(obj.totalAttempted)
      ..writeByte(2)
      ..write(obj.totalCorrect)
      ..writeByte(3)
      ..write(obj.failedQuestionIds)
      ..writeByte(4)
      ..write(obj.lastAttemptedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
