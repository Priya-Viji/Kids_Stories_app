import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';
import 'package:stories_for_kids/screens/storydetails_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Box<StoryModel> libraryBox;

  @override
  void initState() {
    super.initState();
    libraryBox = Hive.box<StoryModel>('storiesBox');
  }

  void goToDetails(StoryModel story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailsPage(
          title: story.title,
          content: story.content,
          images: story.images,
        ),
      ),
    );
  }

  void removeStory(int key) {
    final story = libraryBox.get(key);
    if (story != null) {
      story.isAddedToLibrary = false;
      story.save();
    }
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200) {
      return 5; // Large desktop
    } else if (screenWidth >= 900) {
      return 4; // Small desktop or large tablet
    } else if (screenWidth >= 600) {
      return 3; // Tablet
    } else {
      return 2; // Mobile
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
        title: const Text('Library'),
      ),
      body: ValueListenableBuilder(
        valueListenable: libraryBox.listenable(),
        builder: (context, Box<StoryModel> box, _) {
          final bookmarkedStories =
              box.values.where((story) => story.isAddedToLibrary).toList();

          if (bookmarkedStories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'No stories in your library yet!',
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _calculateCrossAxisCount(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: bookmarkedStories.length,
            itemBuilder: (context, index) {
              final story = bookmarkedStories[index];
              final hasImage = story.images.isNotEmpty;
              final imagePath = hasImage ? story.images.last : "";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                color: cardColor,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => goToDetails(story),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: imagePath.contains('/data/')
                              ? Image.file(
                                  File(imagePath),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  imagePath.isNotEmpty
                                      ? imagePath
                                      : 'assets/images/placeholder.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                story.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'remove') {
                                  removeStory(story.key as int);
                                } else if (value == 'details') {
                                  goToDetails(story);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Text('Go to Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove'),
                                ),
                              ],
                              icon: Icon(Icons.more_vert,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
