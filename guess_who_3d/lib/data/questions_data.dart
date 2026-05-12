class QuestionsData {
  static const Map<String, List<String>> categoryQuestions = {
    'cricket': [
      'Is he an active player?',
      'Is he a bowler?',
      'Is he a batsman?',
      'Has he captained India?',
      'Does he play for CSK?',
      'Does he play for MI?',
      'Has he won a World Cup?',
      'Is he an all-rounder?',
      'Is he a wicket-keeper?',
      'Has he scored a double century?',
      'Is he retired?',
      'Does he bowl spin?',
      'Does he bowl fast?',
      'Is he known for his fitness?',
      'Has he played 100+ Tests?',
    ],
    'politics': [
      'Is he/she currently in power?',
      'Is he/she from the BJP?',
      'Is he/she from the Congress?',
      'Is he/she a Chief Minister?',
      'Has he/she been Prime Minister?',
      'Is he/she from South India?',
      'Is he/she known for fiery speeches?',
      'Is he/she below 60 years old?',
      'Is he/she a Union Minister?',
      'Is he/she a lawyer by profession?',
    ],
    'default': [
      'Is it a man?',
      'Is it a woman?',
      'Do they wear glasses?',
      'Is the hair dark?',
      'Are they smiling?',
      'Do they have facial hair?',
      'Do they wear a hat?',
      'Are they young?',
      'Do they have long hair?',
      'Are they bald?',
    ],
  };

  static List<String> getQuestionsForCategory(String category) {
    final lowerCat = category.toLowerCase();
    if (categoryQuestions.containsKey(lowerCat)) {
      return categoryQuestions[lowerCat]!;
    }
    return categoryQuestions['default']!;
  }
}
