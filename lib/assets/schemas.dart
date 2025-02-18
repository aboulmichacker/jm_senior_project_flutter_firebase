import 'package:google_generative_ai/google_generative_ai.dart';

class Schemas {

  final Schema quizSchema = Schema.object(
      description: 'Quiz Question Schema',
      properties: {
      'mcQuestion': Schema.object(
        description: 'Multiple Choice Question',
        properties: {
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
        requiredProperties: ['questionText', 'options', 'correctAnswer'],
      ),
      'openEndedQuestion': Schema.object(
        description: 'Open-ended Question',
        properties: {
          'questionText': Schema.string(
            description: 'The text of the question',
            nullable: false,
          ),
          'correctAnswer': Schema.string(
            description: 'The expected or model answer',
            nullable: false,
          ),
        },
        requiredProperties: ['questionText', 'correctAnswer'],
      ),
      'tfQuestion': Schema.object(
        description: 'True/False Question',
        properties: {
          'questionText': Schema.string(
            description: 'The text of the question',
            nullable: false,
          ),
          'correctAnswer': Schema.boolean(
            description: 'The correct answer (true or false)',
            nullable: false,
          ),
        },
        requiredProperties: ['questionText', 'correctAnswer'],
      ),
      'fillInTheBlankQuestion': Schema.object(
        description: 'Fill-in-the-blank Question',
        properties: {
          'questionText': Schema.string(
            description: 'The text of the question with a blank',
            nullable: false,
          ),
          'correctAnswer': Schema.string(
            description: 'The correct answer to fill in the blank',
            nullable: false,
          ),
        },
        requiredProperties: ['questionText', 'correctAnswer'],
      ),
      },
      requiredProperties: [
      'mcQuestion',
      'openEndedQuestion',
      'tfQuestion',
      'fillInTheBlankQuestion',
      ],
    );

    final Schema resultSchema = Schema.object(
      properties: {
        "accuracy_score":  Schema.integer(
          description: 'Quiz result accuracy score from 0 to 100',
          nullable: false
        ),
        "open_ended_suggestions": Schema.string(
          description: "Suggestions to improve answer to open ended question to match the correct answer. Return 'Your answer is correct!' instead of null", 
          nullable: false
        ),
        "fill_in_the_blank_suggestion": Schema.string(
          description: "Suggestions to improve answer to fill in the blank question to match the correct answer. Return 'Your answer is correct!' instead of null", 
          nullable: false
        )
      },
      requiredProperties: ["accuracy_score"]
    );
}