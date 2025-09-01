import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FlashCardApp());
}

class FlashCardApp extends StatelessWidget {
  const FlashCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const FlashCardHome(),
    );
  }
}

class FlashCard {
  String question;
  String answer;

  FlashCard({required this.question, required this.answer});
}

class FlashCardHome extends StatefulWidget {
  const FlashCardHome({super.key});

  @override
  State<FlashCardHome> createState() => _FlashCardHomeState();
}

class _FlashCardHomeState extends State<FlashCardHome> {
  List<FlashCard> flashcards = [
    FlashCard(
      question: "What is Flutter?",
      answer: "An open-source UI toolkit by Google.",
    ),
    FlashCard(
      question: "What is Dart?",
      answer: "A programming language optimized for UI.",
    ),
  ];

  int currentIndex = 0;
  bool showAnswer = false;

  void nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % flashcards.length;
      showAnswer = false;
    });
  }

  void previousCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + flashcards.length) % flashcards.length;
      showAnswer = false;
    });
  }

  void addCard() async {
    final newCard = await showDialog<FlashCard>(
      context: context,
      builder: (context) => FlashCardDialog(),
    );
    if (newCard != null) {
      setState(() => flashcards.add(newCard));
    }
  }

  void editCard() async {
    final updatedCard = await showDialog<FlashCard>(
      context: context,
      builder: (context) => FlashCardDialog(
        question: flashcards[currentIndex].question,
        answer: flashcards[currentIndex].answer,
      ),
    );
    if (updatedCard != null) {
      setState(() => flashcards[currentIndex] = updatedCard);
    }
  }

  void deleteCard() {
    if (flashcards.isEmpty) return;
    setState(() {
      flashcards.removeAt(currentIndex);
      if (currentIndex >= flashcards.length) {
        currentIndex = flashcards.isEmpty ? 0 : flashcards.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Flashcards")),
        body: const Center(child: Text("No flashcards yet. Add one!")),
        floatingActionButton: FloatingActionButton(
          onPressed: addCard,
          child: const Icon(Icons.add),
        ),
      );
    }

    final card = flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: editCard, icon: const Icon(Icons.edit)),
          IconButton(onPressed: deleteCard, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 6,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                showAnswer ? card.answer : card.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(() => showAnswer = !showAnswer),
            child: Text(showAnswer ? "Show Question" : "Show Answer"),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navButton(Icons.arrow_back_ios, previousCard),
              const SizedBox(width: 30),
              _navButton(Icons.arrow_forward_ios, nextCard),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCard,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 28),
    );
  }
}

class FlashCardDialog extends StatefulWidget {
  final String? question;
  final String? answer;

  const FlashCardDialog({super.key, this.question, this.answer});

  @override
  State<FlashCardDialog> createState() => _FlashCardDialogState();
}

class _FlashCardDialogState extends State<FlashCardDialog> {
  late TextEditingController questionController;
  late TextEditingController answerController;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.question ?? "");
    answerController = TextEditingController(text: widget.answer ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? "Add Flashcard" : "Edit Flashcard"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: questionController,
            decoration: const InputDecoration(labelText: "Question"),
          ),
          TextField(
            controller: answerController,
            decoration: const InputDecoration(labelText: "Answer"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (questionController.text.isNotEmpty &&
                answerController.text.isNotEmpty) {
              Navigator.pop(
                context,
                FlashCard(
                  question: questionController.text,
                  answer: answerController.text,
                ),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
