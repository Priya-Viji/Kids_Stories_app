import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();

 Future<void> showMeaningBottomSheet({
  required BuildContext context,
  required String word,
  required List<Map<String, String>> meanings, 
 }) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: controller,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    flutterTts.speak(word);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                  ),
                  onPressed: () {
                    final copiedText = '''
$word

${meanings.map((m) => '• ${m["definition"]}\nExample: ${m["example"]}').join('\n\n')}
''';

                    Clipboard.setData(ClipboardData(text: copiedText));

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard")),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Verb",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ...meanings.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ${m["definition"]}",
                          style: const TextStyle(
                            fontSize: 16,
                          )),
                      if (m["example"]?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4),
                          child: Text(
                            'Example: "${m["example"]}"',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700]),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    ),
  );
}
