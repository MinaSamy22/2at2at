import 'package:flutter/material.dart';

class QuizDetailScreen extends StatelessWidget {
  static const String routeName = '/QuizDetailScreen';

  final String quizTitle;
  final int correctAnswers;
  final int totalQuestions;

  const QuizDetailScreen({
    Key? key,
    required this.quizTitle,
    required this.correctAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double successPercentage = (correctAnswers / totalQuestions) * 100;
    final int wrongAnswers = totalQuestions - correctAnswers;
    final int marks = correctAnswers * 4;
    final int negativeMarks = wrongAnswers * 1;
    final int totalMarks = marks - negativeMarks;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(quizTitle),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Score: $correctAnswers/$totalQuestions",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${successPercentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: successPercentage >= 70
                                ? Colors.green
                                : successPercentage >= 50
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: successPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      color: successPercentage >= 70
                          ? Colors.green
                          : successPercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow("✅ Correct Answers:", "$correctAnswers"),
                    _buildResultRow("❌ Wrong Answers:", "$wrongAnswers"),
                    _buildResultRow("⭐ Marks Obtained:", "$marks"),
                    _buildResultRow("⚠️ Negative Marks:", "-$negativeMarks"),
                    _buildResultRow("🏆 Total Marks:", "$totalMarks", isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Test Details", style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                    SizedBox(height: 8),
                    Text("✅ 4 marks for correct answer"),
                    Text("❌ 1 negative mark for incorrect answer"),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Return to Home",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }
}