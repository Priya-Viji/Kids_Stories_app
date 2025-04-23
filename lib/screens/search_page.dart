import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/screens/storydetails_page.dart';
import '../providers/theme_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Box<StoryModel> storiesBox;
  List<StoryModel> allStories = [];
  List<StoryModel> searchStories = [];
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    storiesBox = Hive.box<StoryModel>('storiesBox');
    allStories = storiesBox.values.toList();
    searchStories = allStories;
  }

  void filteredStories(String query) {
    List<StoryModel> results = allStories.where((story) {
      final matchesQuery =
          story.title.toLowerCase().contains(query.toLowerCase()) ||
              story.category.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          story.category.toLowerCase() == _selectedCategory!.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();

    setState(() {
      searchStories = results;
    });
  }

  void _showCategoryFilter(BuildContext context) {
    final categories = allStories
        .map((story) => story.category)
        .toSet()
        .toList(); // Unique list

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: categories.map((category) {
                  final isSelected = category == _selectedCategory;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                        filteredStories(_searchController.text);
                      });
                      Navigator.pop(context);
                    },
                    selectedColor:
                        Theme.of(context).colorScheme.primary.withAlpha(50),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    filteredStories(_searchController.text);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Filter'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stories'),
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (query) => filteredStories(query),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showCategoryFilter(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: searchStories.isEmpty
                ? const Center(
                    child: Text(
                      'No stories found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3,
                          ),
                          itemCount: searchStories.length,
                          itemBuilder: (context, index) {
                            final story = searchStories[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: story.images.isNotEmpty &&
                                          !story.images.last
                                              .startsWith('assets/')
                                      ? Image.file(
                                          File(story.images.last),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          story.images.isNotEmpty
                                              ? story.images.last
                                              : 'assets/images/short_stories/story_1.jpg',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                title: Text(
                                  '${story.title} / ${story.category}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: searchStories.length,
                          itemBuilder: (context, index) {
                            final story = searchStories[index];
                            return ListTile(
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
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: story.images.isNotEmpty &&
                                        !story.images.last.startsWith('assets/')
                                    ? Image.file(
                                        File(story.images.last),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        story.images.isNotEmpty
                                            ? story.images.last
                                            : 'assets/images/short_stories/story_1.jpg',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              title: Text(
                                '${story.title} / ${story.category}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
