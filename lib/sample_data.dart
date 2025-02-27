import 'package:jm_senior/models/quiz_model.dart';

class SampleData {
  final Quiz sampleQuiz = Quiz.fromJson(
    {
  "mcQuestions": [
      {
        "id": "mc1",
        "questionText": "Solve for x:  2x + 5 = 11",
        "options": [
          "2",
          "3",
          "4",
          "6"
        ],
        "correctAnswer": "3"
      },
      {
        "id": "mc2",
        "questionText": "Simplify the expression: 3(y - 4) + 2y",
        "options": [
          "5y - 12",
          "5y - 4",
          "y - 12",
          "3y - 12"
        ],
        "correctAnswer": "5y - 12"
      },
      {
        "id": "mc3",
        "questionText": "If a shirt costs USD 20 and is on sale for 25% off, what is the sale price?",
        "options": [
          "USD 5",
          "USD 15",
          "USD 10",
          "USD 25"
        ],
        "correctAnswer": "USD 15"
      }
    ],
    "openEndedQuestions": [
      {
        "id": "oe1",
        "questionText": "Solve for x:  (x/4) - 7 = 2",
        "correctAnswer": "36"
      },
      {
        "id": "oe2",
        "questionText": "A rectangle has a length of (x + 5) cm and a width of 3 cm.  If the area of the rectangle is 24 cm², what is the value of x?",
        "correctAnswer": "3"
      }
    ],
    "tfQuestions": [
      {
        "id": "tf1",
        "questionText": "The expression 5x + 2x - 3x is equivalent to 4x.",
        "correctAnswer": true
      },
      {
        "id": "tf2",
        "questionText": "If 2y = 10, then y = 20.",
        "correctAnswer": false
      },
      {
        "id": "tf3",
        "questionText": "In the equation y = mx + b, 'b' represents the slope of the line.",
        "correctAnswer": false
      }
    ],
    "fillInTheBlankQuestions": [
      {
        "id": "fb1",
        "questionText": "Simplify: 12a - 5a + 2a = ____a",
        "correctAnswer": "9"
      },
      {
        "id": "fb2",
        "questionText": "If x + 7 = 15, then x = ____.",
        "correctAnswer": "8"
      },
      {
        "id": "fb3",
        "questionText": "The solution to the equation 3n = 21 is n = _____.",
        "correctAnswer": "7"
      }
    ]
  });
}
