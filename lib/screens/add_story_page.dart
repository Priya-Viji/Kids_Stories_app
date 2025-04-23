import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddStoryPage extends StatefulWidget { 
  final VoidCallback onStorySaved;

  const AddStoryPage({super.key, required this.onStorySaved});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final categoryController = TextEditingController();

  final List<File> _selectedImages = [];
  String? _selectedCategory;
  final List<Uint8List> _webSelectedImages = []; // For web

  late Box<StoryModel> storiesBox;
  late List<String> categories = ['Add New Category'];

  @override
  void initState() {
    super.initState();
    storiesBox = Hive.box<StoryModel>('storiesBox');
    categories.addAll(storiesBox.values.map((story) => story.category).toSet());
    _selectedCategory = categories.first;
  }
  
  Future<void> pickImages() async {
    int remaining =
        5 - (kIsWeb ? _webSelectedImages.length : _selectedImages.length);

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can select a maximum of 5 images only.")),
      );
      return;
    }

    if (kIsWeb) {
      // Web: Use FilePicker and store image bytes
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (!mounted) return; 

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.take(remaining);

        setState(() {
          _webSelectedImages.addAll(files.map((f) => f.bytes!).toList());
        });

        if (result.files.length > remaining) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Only $remaining image(s) allowed. Extra images were ignored."),
            ),
          );
        }
      }
    } else {
      // Mobile/Desktop: Use ImagePicker and store Files
      final ImagePicker picker = ImagePicker();
      List<XFile>? pickedFiles = await picker.pickMultiImage();

      if (!mounted || pickedFiles.isEmpty) return;

      if (pickedFiles.length > remaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Only $remaining image(s) allowed. Extra images were ignored."),
          ),
        );
      }

      List<File> newFiles =
          pickedFiles.take(remaining).map((e) => File(e.path)).toList();

      setState(() {
        _selectedImages.addAll(newFiles);
      });
    }
  }
 

  // Future<void> pickImages() async {
  //   int remaining = 5 - _selectedImages.length;

  //   if (remaining <= 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("You can select a maximum of 5 images.")),
  //     );
  //     return;
  //   }

  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.image,
  //     withData: false,
  //   );

  //   if (!mounted) return;

  //   if (result != null && result.files.isNotEmpty) {
  //     List<File> selected = result.files
  //         .take(remaining) // Ensure you only take up to 5
  //         .map((file) => File(file.path!))
  //         .toList();

  //     setState(() {
  //       _selectedImages.addAll(selected);
  //     });
  //   }
  // }


  // Future<void> _replaceImage(int index) async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile =
  //       await picker.pickImage(source: ImageSource.gallery);

  //   if (!mounted) return;

  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImages[index] = File(pickedFile.path);
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Image ${index + 1} replaced successfully.")),
  //     );
  //   }
  // }

  void saveStory() {
    if (!formKey.currentState!.validate()) return;

    String category = _selectedCategory == "Add New Category"
        ? categoryController.text.trim()
        : _selectedCategory ?? "Unknown";

    final isImageSelected =
        kIsWeb ? _webSelectedImages.isNotEmpty : _selectedImages.isNotEmpty;

    if (!isImageSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one image.")),
      );
      return;
    }

    final newStory = StoryModel(
      title: titleController.text.trim(),
      category: category,
      images: _selectedImages.map((file) => file.path).toList(),
      content: contentController.text.trim(),
      isUserStory: true,
    );

    try {
      storiesBox.add(newStory);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story saved successfully!")),
      );

      setState(() {
        titleController.clear();
        contentController.clear();
        categoryController.clear();
        _selectedImages.clear();
        _selectedCategory = categories.first;
      });

      widget.onStorySaved();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save story: $e")),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
        title: const Text("Add New Story"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: saveStory,
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? Colors.grey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Story Title",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      } else if (value.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: storiesBox.listenable(),
                    builder: (context, Box<StoryModel> box, _) {
                      List<String> categories = ['Add New Category'];
                      categories.addAll(
                        box.values.map((story) => story.category).toSet(),
                      );

                      if (!categories.contains(_selectedCategory)) {
                        _selectedCategory = categories.first;
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_selectedCategory == "Add New Category")
                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: "New Category",
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (_selectedCategory == "Add New Category") {
                          if (value == null || value.trim().isEmpty) {
                            return "Please Enter a Category";
                          } else if (value.trim().length < 5) {
                            return 'Category must be at least 5 characters';
                          }
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Select Images"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                 if ((kIsWeb && _webSelectedImages.isNotEmpty) ||
                      (!kIsWeb && _selectedImages.isNotEmpty))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        SizedBox(
                          height: MediaQuery.of(context).size.width < 400
                              ? 80
                              : 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: kIsWeb
                                ? _webSelectedImages.length
                                : _selectedImages.length,
                            itemBuilder: (context, index) {
                              final imageWidget = kIsWeb
                                  ? Image.memory(
                                      _webSelectedImages[index],
                                      width: MediaQuery.of(context).size.width <
                                              400
                                          ? 70
                                          : 90,
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  400
                                              ? 70
                                              : 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      _selectedImages[index],
                                      width: MediaQuery.of(context).size.width <
                                              400
                                          ? 70
                                          : 90,
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  400
                                              ? 70
                                              : 90,
                                      fit: BoxFit.cover,
                                    );

                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imageWidget,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (kIsWeb) {
                                            _webSelectedImages.removeAt(index);
                                          } else {
                                            _selectedImages.removeAt(index);
                                          }
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height:16), 
                      ],
                    ),

                  const SizedBox(height: 16),
                  SizedBox(
                    height: screenHeight * 0.35,
                    child: TextFormField(
                      controller: contentController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        labelText: "Story Content",
                        alignLabelWithHint: true,
                        hintText: "Write your story here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Story content cannot be empty";
                        } else if (value.trim().length < 20) {
                          return "Content must be at least 20 characters";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
