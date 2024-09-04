class Quote {
  final String quote;
  final String quoteAuthor;

  Quote({required this.quote, required this.quoteAuthor});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quote: json['quote'],
      quoteAuthor: json['quoteAuthor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'quoteAuthor': quoteAuthor,
    };
  }
}
