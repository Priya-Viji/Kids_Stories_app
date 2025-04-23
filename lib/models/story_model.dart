import 'package:hive/hive.dart';
part 'story_model.g.dart';

@HiveType(typeId:0)
class StoryModel extends HiveObject{
  @HiveField(0)
  String title;

  @HiveField(1)
  String category;

  @HiveField(2)
  List<String> images;

  @HiveField(3)
  String content;

  @HiveField(4)
  bool isFavorite;

  @HiveField(5)
  bool isAddedToLibrary;

  @HiveField(6)
  bool isUserStory;

  StoryModel({
    required this.title,
    required this.category,
    required this.images,
    required this.content,
    this.isFavorite = false,
    this.isAddedToLibrary=false,
    this.isUserStory = false
  });

 // Add this copyWith method
  StoryModel copyWith({
    String? title,
    String? category,
    List<String>? images,
    String? content,
    bool? isFavorite,
    bool? isAddedToLibrary,
    bool? isUserStory
  }) {
    return StoryModel(
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
      isAddedToLibrary: isAddedToLibrary ?? this.isAddedToLibrary,
      isUserStory: isUserStory ?? this.isUserStory,

    );
  }
}
