import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echo_emotions/models/quote.dart';

class QuoteService {
  final String url = 'https://raw.githubusercontent.com/francefaraz/quote_sender_node/master/src/helpers/quotes.json';

  Future<void> fetchAndStoreQuotes() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonQuotes = json.decode(response.body);
      print(jsonQuotes);
      print("faraz: ");
      List<Quote> quotes = jsonQuotes.map((q) => Quote.fromJson(q)).toList();
      print("faraz11: ");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> quotesString = quotes.map((q) => json.encode(q.toJson())).toList();

      await prefs.setStringList('quotes', quotesString);
    } else {
      print("error is ");
      throw Exception('Failed to load quotes');
    }
  }

  Future<Quote?> getRandomQuote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? quotesString = prefs.getStringList('quotes');
    if(quotesString==null) {
      fetchAndStoreQuotes();
    }
    if (quotesString != null && quotesString.isNotEmpty) {
      List<Quote> quotes = quotesString.map((q) => Quote.fromJson(json.decode(q))).toList();
      quotes.shuffle();  // Randomize the list
      return quotes.first;
    } else {
      return null;
    }
  }
}
