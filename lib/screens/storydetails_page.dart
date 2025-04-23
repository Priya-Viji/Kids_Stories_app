import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stories_for_kids/models/story_model.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stories_for_kids/screens/dialogs.dart';

class StoryDetailsPage extends StatefulWidget {
  final String title;
  final String content;
  final List<String> images;
  
  const StoryDetailsPage({
    super.key,
    required this.title,
    required this.content,
    required this.images,
  });

  @override
  State<StoryDetailsPage> createState() => _StoryDetailsPageState();
}

class _StoryDetailsPageState extends State<StoryDetailsPage> {
  final FlutterTts flutterTts = FlutterTts();
  late ScrollController _scrollController;
  bool isAddedToLibrary = false; // Track if already added
  double _fontSize = 18.0;
  bool isPlaying=false;
  bool isFavorite= false; // Bookmark state
  late Box<StoryModel> storiesBox;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  
  @override
  void initState() {
    super.initState();
    openHiveBox();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
      _pageController = PageController();
    startAutoScroll();

  }

   void startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= widget.images.length-1) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void stopAutoScroll() {
    _timer?.cancel();
  }
  void _onScroll() {
    double scrollPosition = _scrollController.position.pixels;
    double maxScroll = _scrollController.position.maxScrollExtent;

    if (!isAddedToLibrary && scrollPosition > maxScroll * 0.3) {
      _addToLibrary();
      isAddedToLibrary = true; // Avoid multiple additions
    }
  }

  void _addToLibrary() async{
      int index = storiesBox.values.toList().indexWhere((story) => 
      story.title == widget.title && story.content == widget.content);
  
      if (index != -1) {
       final story = storiesBox.getAt(index);
      if (story != null) {
       final updatedStory = story.copyWith(isAddedToLibrary: !story.isAddedToLibrary);
       await storiesBox.putAt(index, updatedStory);
       setState(() {
        isAddedToLibrary = updatedStory.isAddedToLibrary;
      });
    }
      }
  }


  Future<void> openHiveBox() async {
    storiesBox = Hive.box<StoryModel>('storiesBox'); 
    checkIfFavorite(); // Check initial favorite status
  }

  void checkIfFavorite() {
    int index = storiesBox.values.toList().indexWhere((story) =>
        story.title == widget.title && story.content == widget.content);

    if (index != -1) {
      final story = storiesBox.getAt(index);
      if (story != null) {
        setState(() {
          isFavorite = story.isFavorite;
        });
      }
    }
  }
 
 @override
  void dispose() {
    flutterTts.stop();
    _scrollController.dispose();
      _pageController.dispose();
    stopAutoScroll();
    super.dispose();
  }

  Future<void> speak() async {
    
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak('${widget.title}. ${widget.content}');
    setState(() {
      isPlaying=true;
    });

    flutterTts.setCompletionHandler((){
      setState(() {
        isPlaying=false;
      });
    });
  }

  
  //  // Method to stop reading the story
    Future<void> _stop() async {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
      });
    }

    Future<void> toggleFavorite() async {
      int index = storiesBox.values.toList().indexWhere((story) => 
      story.title == widget.title && story.content == widget.content);
  
      if (index != -1) {
       final story = storiesBox.getAt(index);
      if (story != null) {
       final updatedStory = story.copyWith(isFavorite: !story.isFavorite);
       await storiesBox.putAt(index, updatedStory);
       setState(() {
        isFavorite = updatedStory.isFavorite;
      });
    }
  }
}
  // Method to share story content
  void shareContent() {
     String content = "${widget.title}\n\n${widget.content}";
     Share.share(content, subject: widget.title);
    // String image = widget.images.isNotEmpty ? widget.images.last : '';
    // String title = widget.title;
    // //String link =
    //   //  'https://yourappdomain.com/story/${title.replaceAll(' ', '-')}'; // Replace with your actual link structure

    // Share.share(image, subject: title);
  }
  

   // Method to show font size adjustment slider
   void showFontSizeDialog(BuildContext context) {
     double tempFontSize = _fontSize;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Adjust Font Size",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                 // Plus and Minus Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (tempFontSize > 12) {
                            setModalState(() => tempFontSize -= 1);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${tempFontSize.toInt()}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (tempFontSize < 30) {
                            setModalState(() => tempFontSize += 1);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Slider to Adjust Font Size
                  Slider(
                    value: tempFontSize,
                    min: 12.0,
                    max: 30.0,
                    divisions: 18,
                    label: "${tempFontSize.toInt()}",
                    onChanged: (double newValue) {
                      setModalState(() => tempFontSize = newValue);
                    },
                  ),

                  Text(
                    "Font Size: ${tempFontSize.toInt()}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _fontSize = tempFontSize;
                      });
                      Navigator.pop(context); 
                    },
                    child: const Text("Apply"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
 
  Future<void> _downloadAsPdf() async {
    final pdf = pw.Document();

    Uint8List imageBytes;
    if (widget.images.last.contains('/data/')) {
      imageBytes = await File(widget.images.last).readAsBytes();
    } else {
      final ByteData byteData = await rootBundle.load(widget.images.last);
      imageBytes = byteData.buffer.asUint8List();
    }

    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
         margin: const pw.EdgeInsets.all(32),
         build: (pw.Context context) {
        return [
          
            pw.Center(child: pw.Image(image, height: 200)),
            pw.SizedBox(height: 16),
           pw.Header(
              level: 0,
              child: pw.Text(widget.title,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Paragraph(
              text: widget.content,
              style: const pw.TextStyle(fontSize: 14),
            ),
          ];
        },
      ),
    );

    if (Platform.isAndroid) {
      final permission = await Permission.manageExternalStorage.request();

      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Storage permission is required to download PDF"),
            ),
          );
        }
        return;
      }
    }

    try {
      final dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download/')
          : await getApplicationDocumentsDirectory();

      final fileName = widget.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File('${dir.path}/$fileName.pdf');

      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF downloaded to ${dir.path}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    }
  }

  Future<void> showDownloadDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Download Story"),
        content: const Text("Do you want to download this story as a PDF?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              _downloadAsPdf();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchWordMeaning(String word) async {
    final url =
        Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data[0]; 
    } else {
      throw Exception('Meaning not found');
    }
  }

  List<Map<String, String>> parseMeanings(apiResponse) {
    final List<Map<String, String>> list = [];

    for (var meaning in apiResponse['meanings']) {
      for (var def in meaning['definitions']) {
        list.add({
          'definition': def['definition'] ?? '',
          'example': def['example'] ?? '',
        });
      }
    }
    return list;
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeColor = themeProvider.themeColor;
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor: bgColor,
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          controller: _scrollController,
          child: Stack(
            children: [
             SizedBox(
                height: screenHeight * 0.4,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length-1,
                  itemBuilder: (context, index) {
                    final imagePath = widget.images[index+1];
                    return imagePath.contains('/data/')
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          );
                  },
                  onPageChanged: (index) {
                    _currentPage = index;
                  },
                ),
              ),
          
            // Download Button
              Positioned(
                top: screenHeight * 0.27,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: themeColor,
                  radius: 28,
                  child: IconButton(
                    icon: const Icon(Icons.download, color: Colors.white, size: 28),
                    onPressed: () =>showDownloadDialog(context),
                  ),
                ),
              ),
          
              // Top Buttons (Back, Share, Favorite)
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: const Icon(Icons.text_fields, color: Colors.white),
                            onPressed: () => showFontSizeDialog(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: Icon(
                               isPlaying 
                               ? Icons.volume_mute 
                               : Icons.volume_up_outlined,
                                color: Colors.white),
                            onPressed: () {
                              isPlaying ? _stop() : speak();
                              //Navigator.push(context, MaterialPageRoute(builder: (context)=>TextToSpeechPage()));
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(                   
                            icon: Icon(
                             isFavorite ? Icons.favorite : Icons.favorite_border, 
                             color: isFavorite ? Colors.red : Colors.white
                             ),
                            onPressed: toggleFavorite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.black.withAlpha(100),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: shareContent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          
              // Story Content
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: screenHeight * 0.35),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                     color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black26,
                  //     //blurRadius: 10,
                  //     //spreadRadius: 2,
                  //     //offset: Offset(0, -3),
                  //   ),
                  // ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: _fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Text(
                    //   widget.content,
                    //   style: TextStyle(
                    //     fontSize:  _fontSize,
                    //     //height: 1.5,
                    //     color: textColor,
                    //   ),
                    // ),
                    SelectableText(
                      widget.content,
                      style: TextStyle(fontSize: _fontSize, color: textColor),
                      onSelectionChanged: (selection, cause) async {
                        final selectedText = widget.content
                            .substring(selection.start, selection.end)
                            .trim();

                        if (selectedText.isNotEmpty &&
                            selectedText.split(' ').length == 1) {

                         final data = await fetchWordMeaning(selectedText);

                          if (!context.mounted) return;

                          final meanings = parseMeanings(data);

                          if (!mounted) return;
                          
                          await showMeaningBottomSheet(
                            context: context,
                            word: selectedText,
                            meanings: meanings,
                          );

                        }                       
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
