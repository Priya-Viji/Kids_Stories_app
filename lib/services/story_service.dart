import 'package:hive/hive.dart';
import '../models/story_model.dart';
import '../utils/constants.dart';

class StoryService {
  final Box<StoryModel> storyBox = Hive.box<StoryModel>('storiesBox');

  void initializeStories() async {
    if (storyBox.isEmpty) {
      for (var story in storyList) {
        await storyBox.add(story);
      }
    }
  }

  List<StoryModel> getSliderStories([int count = 6]) {
    return storyBox.values.take(count).toList();
  }

  List<StoryModel> getAllStories() {
    return storyBox.values.toList();
  }

  List<String> getUniqueCategories() {
    return storyBox.values.map((s) => s.category).toSet().toList();
  }

  List<StoryModel> getStoriesByCategory(String category) {
    return storyBox.values.where((s) => s.category == category).toList();
  }
}
