import 'package:google_generative_ai/google_generative_ai.dart';

class Schemas {

  final Schema quizSchema = Schema.object(
      description: 'Quiz Schema',
      properties: {

      'mcQuestions': Schema.array(
        description: 'List of 3 multiple choice questions',
          items: Schema.object(
          description: 'Multiple Choice Question',
          properties: {
            'id': Schema.string( 
              description: 'Unique identifier for the question',
              nullable: false,
            ),
            'questionText': Schema.string(
              description: 'The text of the question',
              nullable: false,
            ),
            'options': Schema.array(
              description: 'Array of possible answers',
              items: Schema.string(),
            ),
            'correctAnswer': Schema.string(
              description: 'The correct answer',
              nullable: false,
            ),
          },
          requiredProperties: ['id','questionText', 'options', 'correctAnswer'],
        ),
      ),
      'openEndedQuestions': Schema.array(
        description: 'List of 2 open ended questions',
        items: Schema.object(
            description: 'Open-ended Question',
            properties: {
              'id': Schema.string( 
                description: 'Unique identifier for the question',
                nullable: false,
              ),
              'questionText': Schema.string(
                description: 'The text of the question',
                nullable: false,
              ),
              'correctAnswer': Schema.string(
                description: 'The expected or model answer',
                nullable: false,
              ),
            },
            requiredProperties: ['id','questionText', 'correctAnswer'],
          ),
        ),
      'tfQuestions':Schema.array(
        description: 'List of 3 true or false questions',
        items: Schema.object(
          description: 'True/False Question',
          properties: {
            'id': Schema.string( 
              description: 'Unique identifier for the question',
              nullable: false,
            ),
            'questionText': Schema.string(
              description: 'The text of the question',
              nullable: false,
            ),
            'correctAnswer': Schema.boolean(
              description: 'The correct answer (true or false)',
              nullable: false,
            ),
          },
          requiredProperties: ['id','questionText', 'correctAnswer'],
        ),
      ),
      'fillInTheBlankQuestions': Schema.array(
        description: 'List of 3 fill in the blank questions',
        items: Schema.object(
          description: 'Fill-in-the-blank Question',
          properties: {
            'id': Schema.string( 
              description: 'Unique identifier for the question',
              nullable: false,
            ),
            'questionText': Schema.string(
              description: 'The text of the question with a blank',
              nullable: false,
            ),
            'correctAnswer': Schema.string(
              description: 'The correct answer to fill in the blank',
              nullable: false,
            ),
          },
          requiredProperties: ['id','questionText', 'correctAnswer'],
        ),
      ),
      },
      requiredProperties: [
      'mcQuestions',
      'openEndedQuestions',
      'tfQuestions',
      'fillInTheBlankQuestions',
      ],
    );

    final Schema resultSchema = Schema.object(
      properties: {
        "quiz_score":  Schema.integer(
          description: 'Quiz result score',
          nullable: false
        ),
      "open_ended_suggestions": Schema.array( 
        description: "List of suggestions for open-ended questions",
        items: Schema.object( 
          properties: {
            'questionId': Schema.string( 
              description: 'Unique identifier for the question this suggestion relates to',
              nullable: false,
            ),
            'suggestion': Schema.string(
              description: "Suggestion to improve the answer.  Return 'Your answer is correct!' if no improvement is needed.",
              nullable: false,
            ),
          },
          requiredProperties: ['questionId', 'suggestion'],
        ),
      ),
      "fill_in_the_blank_suggestions": Schema.array( 
        description: "List of suggestions for fill-in-the-blank questions",
        items: Schema.object( 
          properties: {
            'questionId': Schema.string(
              description: 'Unique identifier for the question this suggestion relates to',
              nullable: false,
            ),
            'suggestion': Schema.string(
              description: "Suggestion to improve the answer. Return 'Your answer is correct!' if no improvement is needed.",
              nullable: false,
            ),
          },
          requiredProperties: ['questionId', 'suggestion'],
        ),
      ),
      },
      requiredProperties: ["quiz_score", "open_ended_suggestions","fill_in_the_blank_suggestions"]
    );
}