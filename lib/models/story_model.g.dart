// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryModelAdapter extends TypeAdapter<StoryModel> {
  @override
  final int typeId = 0;

  @override
  StoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryModel(
      title: fields[0] as String,
      category: fields[1] as String,
      images: (fields[2] as List).cast<String>(),
      content: fields[3] as String,
      isFavorite: fields[4] as bool,
      isAddedToLibrary: fields[5] as bool,
      isUserStory: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.images)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.isAddedToLibrary)
      ..writeByte(6)
      ..write(obj.isUserStory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
