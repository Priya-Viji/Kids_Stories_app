import 'package:hive_flutter/hive_flutter.dart';
import 'package:stories_for_kids/models/story_model.dart';

class HiveDB {

  static const String boxName="storiesBox";

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    if(!Hive.isAdapterRegistered(0)){
     Hive.registerAdapter(StoryModelAdapter());
    }
    await Hive.openBox<StoryModel>(boxName);
  }
  // Get Box

   static Box<StoryModel> getBox()=>Hive.box<StoryModel>(boxName);

   // Add Story
   static Future<void> addStory(StoryModel story) async{
    await getBox().add(story);
   }

   //Get All Stories
   static List<StoryModel> getStories() {
    return getBox().values.toList();
   }

   //Update Favorite
   static Future<void> heartFavorite(int index) async{
    final story= getBox().getAt(index);
    if(story!=null){
       story.isFavorite=!story.isFavorite;
       await story.save();
    }
   }

   //Delete Story
   static Future<void> deleteStory(int index) async {
    await getBox().deleteAt(index);
   }

  }