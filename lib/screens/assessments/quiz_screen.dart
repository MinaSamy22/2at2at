import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final String quizTitle;
  final Function(int)? onQuizCompleted;

  const QuizScreen({
    Key? key,
    required this.quizTitle,
    this.onQuizCompleted,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  List<Question> questions = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedOption;
  bool answerSubmitted = false;
  List<int?> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuizQuestions();
  }

  Future<void> _loadQuizQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/ass.json');
      final List<dynamic> data = json.decode(response);

      final quizData = data.firstWhere(
            (quiz) => quiz['title'] == widget.quizTitle,
        orElse: () => throw Exception('Quiz "${widget.quizTitle}" not found'),
      );

      final quiz = Quiz.fromJson(quizData);

      setState(() {
        questions = quiz.questions;
        userAnswers = List<int?>.filled(quiz.questions.length, null);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading quiz: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void selectAnswer(int optionIndex) {
    setState(() {
      selectedOption = questions[currentQuestionIndex].options[optionIndex];
      userAnswers[currentQuestionIndex] = optionIndex;
    });
  }

  void moveToNextQuestion() {
    // Check if current question was answered correctly
    if (userAnswers[currentQuestionIndex] != null) {
      final correctIndex = questions[currentQuestionIndex].options
          .indexOf(questions[currentQuestionIndex].answer);
      if (userAnswers[currentQuestionIndex] == correctIndex) {
        correctAnswers++;
      }
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        answerSubmitted = false;
      });
    } else {
      // Quiz completed
      widget.onQuizCompleted?.call(correctAnswers);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Text('Your Score: $correctAnswers / ${questions.length}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      );
    }
  }

  Color _getOptionColor(int optionIndex) {
    if (!answerSubmitted) return Colors.white;

    final correctIndex = questions[currentQuestionIndex].options
        .indexOf(questions[currentQuestionIndex].answer);

    if (optionIndex == correctIndex) {
      return Colors.green.shade100;
    } else if (optionIndex == userAnswers[currentQuestionIndex]) {
      return Colors.red.shade100;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: _getOptionColor(index),
                child: ListTile(
                  title: Text(option),
                  onTap: answerSubmitted ? null : () => selectAnswer(index),
                  trailing: userAnswers[currentQuestionIndex] == index
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                ),
              );
            }).toList(),
            const SizedBox(height: 30), // Space between options and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                        selectedOption = null;
                        answerSubmitted = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 100),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      answerSubmitted = true;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      moveToNextQuestion();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion ? Colors.green : Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(isLastQuestion ? 'Submit Quiz' : 'Next'),
                ),
              ],
            ),
            const Spacer(), // Pushes everything up while maintaining space
          ],
        ),
      ),
    );
  }
}