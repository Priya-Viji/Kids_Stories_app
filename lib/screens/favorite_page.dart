import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/screens/storydetails_page.dart';
import '../providers/theme_provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Box<StoryModel> storiesBox;

   @override
  void initState() {
    super.initState();
    storiesBox = Hive.box<StoryModel>('storiesBox');
  }

   // Method to toggle favorite status
  void toggleFavorite(int key, bool isFavorite) {
    final story = storiesBox.get(key);
    if (story != null) {
      final updatedStory = story.copyWith(isFavorite: !isFavorite);
      storiesBox.put(key, updatedStory);
      setState(() {}); 
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

     return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
        title: const Text('Favorite Stories'),
      ),
      body: ValueListenableBuilder(
        valueListenable: storiesBox.listenable(),
        builder: (context, Box<StoryModel> box, _) {
          final favoriteStories = box.values
              .toList()
              .asMap()
              .entries
              .where((entry) => entry.value.isFavorite)
              .toList();

          if (favoriteStories.isEmpty) {  
            return Center(
              child: Text(
                'No favorite stories yet!',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            );
          }

         return LayoutBuilder(
            builder: (context, constraints) {
              // Switch to grid on wider screens
              if (constraints.maxWidth > 600) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3, // horizontal card style
                  ),
                  itemCount: favoriteStories.length,
                  itemBuilder: (context, index) {
                    final story = favoriteStories[index].value;
                    final key = favoriteStories[index].key;

                    return Card(
                      color: cardColor,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                     child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Image(
                          image: story.images.last.contains('/data/')
                              ? FileImage(File(story.images.last))
                              : AssetImage(story.images.last) as ImageProvider,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          story.title,
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.favorite,
                              color: themeProvider.themeColor),
                          onPressed: () =>
                              toggleFavorite(key, story.isFavorite),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryDetailsPage(
                              title: story.title,
                              content: story.content,
                              images: story.images,
                            ),
                          ),
                        ),
                      ),

                    );
                  },
                );
              } else {
                // Mobile - ListView
                return ListView.builder(
                  itemCount: favoriteStories.length,
                  itemBuilder: (context, index) {
                    final story = favoriteStories[index].value;
                    final key = favoriteStories[index].key;

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Image(
                            image: story.images.last.contains('/data/')
                                ? FileImage(File(story.images.last))
                                : AssetImage(story.images.last)
                                    as ImageProvider,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          story.title,
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.favorite,
                              color: themeProvider.themeColor),
                          onPressed: () =>
                              toggleFavorite(key, story.isFavorite),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryDetailsPage(
                              title: story.title,
                              content: story.content,
                              images: story.images,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
