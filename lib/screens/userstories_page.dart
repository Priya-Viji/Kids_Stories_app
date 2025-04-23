import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';
import 'package:stories_for_kids/screens/editstory_page.dart';
import 'package:stories_for_kids/screens/storydetails_page.dart';

class UserstoriesPage extends StatefulWidget {
  const UserstoriesPage({super.key});

  @override
  State<UserstoriesPage> createState() => _UserstoriesPageState();
}

class _UserstoriesPageState extends State<UserstoriesPage> {
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Stories'),
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<StoryModel>('storiesBox').listenable(),
        builder: (context, Box<StoryModel> box, _) {
          final userStories =
              box.values.where((story) => story.isUserStory == true).toList();

          if (userStories.isEmpty) {
            return Center(
              child: Text(
                "No stories added yet!",
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: userStories.length,
              itemBuilder: (context, index) {
                final story = userStories[index];
                final lastImagePath =
                    story.images.isNotEmpty ? story.images.last : '';

                return Card(
                  color: cardColor,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: lastImagePath.isNotEmpty &&
                              File(lastImagePath).existsSync()
                          ? FileImage(File(lastImagePath))
                          : const AssetImage('assets/images/story_2.jpg')
                              as ImageProvider,
                    ),
                    title: Text(
                      story.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              Icon(Icons.edit, color: themeProvider.themeColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditStoryPage(story: story),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: themeProvider.themeColor),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(box, story),
                        ),
                      ],
                    ),
                     onTap: () {
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
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
     
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      Box<StoryModel> box, StoryModel story) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text(
          'Confirm Deletion',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to delete this story?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      _deleteStory(box, story);
    }
  }

  void _deleteStory(Box<StoryModel> box, StoryModel story) async {
    await story.delete(); // Triggers ValueListenableBuilder automatically
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story deleted successfully')),
    );
  }
}
