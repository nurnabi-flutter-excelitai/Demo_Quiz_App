import 'dart:convert';
import 'package:flutter/material.dart';



class Quiz {
  String question;
  List<String> options;
  int answer;
  int? selectedAnswer; // New property

  Quiz({required this.question, required this.options, required this.answer, this.selectedAnswer});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}


class QuizScreen extends StatefulWidget {
  final List<Quiz> quizList;
  QuizScreen({required this.quizList});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;

  void handleAnswer(int selectedIndex) {
    setState(() {
      widget.quizList[currentQuestionIndex].selectedAnswer = selectedIndex;
    });

    if (selectedIndex == widget.quizList[currentQuestionIndex].answer) {
      setState(() {
        score++;
      });
    }

    if (currentQuestionIndex < widget.quizList.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreboardScreen(
            quizList: widget.quizList,
            score: score,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.quizList[currentQuestionIndex].question,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 12.0),
            ...widget.quizList[currentQuestionIndex].options
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => handleAnswer(entry.key),
                  child: Text(entry.value),
                ),
              ),
            )
                .toList(),
          ],
        ),
      ),
    );
  }
}

class ScoreboardScreen extends StatelessWidget {
  final List<Quiz> quizList;
  final int score;

  ScoreboardScreen({required this.quizList, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scoreboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Score: $score / ${quizList.length}',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: quizList.length,
                itemBuilder: (context, index) {
                  var quiz = quizList[index];
                  var isCorrect = index < score;
                  var isSelectedCorrect = quiz.selectedAnswer == quiz.answer;

                  return ListTile(
                    title: Text(quiz.question),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected answer: ${quiz.options[quiz.selectedAnswer ?? -1]}'),
                        Text('Correct answer: ${quiz.options[quiz.answer]}'),
                      ],
                    ),
                    trailing: Icon(
                      isSelectedCorrect ? Icons.check : Icons.close,
                      color: isSelectedCorrect ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final quizData = '''
  [
    {
      "question": "What is the capital of France?",
      "options": ["New York", "Paris", "London", "Berlin"],
      "answer": 1
    },
    {
      "question": "What is the largest planet in our solar system?",
      "options": ["Mars", "Saturn", "Jupiter", "Neptune"],
      "answer": 2
    },
    {
      "question": "What is the smallest country in the world?",
      "options": ["Monaco", "Maldives", "Vatican City", "Liechtenstein"],
      "answer": 2
    }
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    List<Quiz> quizList = jsonDecode(quizData)
        .map<Quiz>((json) => Quiz.fromJson(json))
        .toList();
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuizScreen(quizList: quizList),
      //home: CreateQuizScreen()

    );
  }
}



