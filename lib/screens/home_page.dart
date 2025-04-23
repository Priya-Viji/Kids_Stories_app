import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/screens/category_list_page.dart';
import 'package:stories_for_kids/screens/search_page.dart';
import 'package:stories_for_kids/screens/settings_page.dart';
import 'package:stories_for_kids/screens/storydetails_page.dart';
import 'package:stories_for_kids/screens/subcategory_page.dart';
import 'package:stories_for_kids/utils/constants.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> images = [
    "assets/images/story_1.jpg",
    "assets/images/story_2.jpg",
    "assets/images/story_3.jpg",
    "assets/images/story_4.jpg",
  ];

  List<StoryModel> stories = [];
  List<StoryModel> sliderStories = [];
  int myCurrentIndex = 0;
  late Box<StoryModel> storyBox;

  @override
  void initState() {
    super.initState();
    storyBox = Hive.box<StoryModel>('storiesBox');
    addInitialStories();
    stories = storyList;

    sliderStories = storyList.getRange(0, 6).toList();
  }

  void addInitialStories() async {
    if (storyBox.isEmpty) {
      for (var story in storyList) {
        await storyBox.add(story);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'English Stories',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                double sliderWidth = constraints.maxWidth > 600
                    ? 600
                    : constraints.maxWidth * 0.9;

                return Center(
                  child: CarouselSlider.builder(
                    itemCount: sliderStories.length,
                    itemBuilder: (context, index, realIndex) {
                      final story = sliderStories[index];
                      final imagePath =
                          story.images.isNotEmpty ? story.images.last : null;

                      return GestureDetector(
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
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imagePath != null
                                  ? (!kIsWeb && imagePath.contains('/data/'))
                                      ? Image.file(
                                          File(imagePath),
                                          width: sliderWidth,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          imagePath,
                                          width: sliderWidth,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                  : Container(
                                      width: sliderWidth,
                                      height: 200,
                                      color: Colors.grey,
                                      child: const Center(
                                        child: Text(
                                          'No Image',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                            ),
                            Container(
                              width: sliderWidth,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withAlpha(100),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                story.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 220,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 600),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          myCurrentIndex = index;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            AnimatedSmoothIndicator(
              activeIndex: myCurrentIndex,
              count: sliderStories.length,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                spacing: 5,
                dotColor: Colors.grey.shade300,
                activeDotColor: themeProvider.themeColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stories by Category",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryListPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "View All >",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: storyBox.listenable(),
              builder: (context, Box<StoryModel> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No stories found.'));
                }

                final allStories = box.values.toList();
                final uniqueCategories =
                    allStories.map((s) => s.category).toSet().toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 5;
                    } else if (constraints.maxWidth > 900) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 3;
                    } else {
                      crossAxisCount = 2;
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        uniqueCategories.length > 6
                            ? 6
                            : uniqueCategories.length,
                        (index) {
                          final category = uniqueCategories[index];
                          final story = allStories
                              .firstWhere((s) => s.category == category);

                          final imageProvider = (!kIsWeb &&
                                  story.images.first.contains('/data/'))
                              ? const AssetImage('assets/images/story_1.jpg')
                              : AssetImage(story.images.first);

                          return GestureDetector(
                            onTap: () {
                              final filteredStories = allStories
                                  .where((s) => s.category == category)
                                  .toList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubCategoryPage(
                                    stories: filteredStories,
                                    category: category,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  category,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
