import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:echo_emotions/service/api_service.dart'; // Ensure to replace this with the correct path to your quote service

class InspireScreen extends StatefulWidget {
  const InspireScreen({super.key});

  @override
  _InspireScreenState createState() => _InspireScreenState();
}

class _InspireScreenState extends State<InspireScreen> with WidgetsBindingObserver {
  late String quote, owner, imgLink;
  bool isWorking = false;
  final grey = Colors.blueGrey;
  late ScreenshotController screenshotController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    screenshotController = ScreenshotController();
    quote = "Love is the hardest habit to break \n and the most difficult to satisfy.";
    owner = "";
    imgLink = "";
    checkNotificationPermission();
    getQuote();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('AppLifecycleState.resumed');
        break;
      case AppLifecycleState.inactive:
        print('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState.paused');
        break;
      case AppLifecycleState.detached:
        print('AppLifecycleState.detached');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double getRandomNumber() {
    final Random random = Random();
    return random.nextDouble();
  }

  Future<String?> fetchWikipediaImage(String author) async {
    try {
      final response = await http.get(Uri.parse('https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages&titles=$author&piprop=original'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final pages = jsonData['query']['pages'];
        if (pages.isNotEmpty) {
          final firstPage = pages.values.first;
          if (firstPage.containsKey('original')) {
            return firstPage['original']['source'];
          }
        }
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return null;
  }

  void getQuote() async {
    offline() {
      List<Map<String, String>> offlineQuotes = [
        {
          'owner': 'Shaik Muneer',
          'quote': 'Love is the hardest habit to break \n and the most difficult to satisfy.'
        },
        {
          'owner': 'Unknown',
          'quote': 'Life is what happens when you\'re busy making other plans.'
        },
        {
          'owner': 'Albert Einstein',
          'quote': 'Imagination is more important than knowledge.'
        },
        {
          'owner': 'Maya Angelou',
          'quote': 'I\'ve learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel.'
        },
        {
          'owner': 'Walt Disney',
          'quote': 'All our dreams can come true, if we have the courage to pursue them.'
        },
        {
          'owner': 'John Lennon',
          'quote': 'Life is what happens to you while you’re busy making other plans.'
        },
        {
          'owner': 'Ralph Waldo Emerson',
          'quote': 'What lies behind us and what lies before us are tiny matters compared to what lies within us.'
        },
        {
          'owner': 'Eleanor Roosevelt',
          'quote': 'The future belongs to those who believe in the beauty of their dreams.'
        },
      ];

      final random = Random();
      final randomIndex = random.nextInt(offlineQuotes.length);
      final selectedQuote = offlineQuotes[randomIndex];

      setState(() {
        owner = selectedQuote['owner']!;
        quote = selectedQuote['quote']!;
        imgLink = "";
        isWorking = false;
      });
    }

    try {
      QuoteService quoteService = QuoteService();
      var fetchedQuote = await quoteService.getRandomQuote();
      if (fetchedQuote != null) {
        setState(() {
          quote = fetchedQuote.quote;
          owner = fetchedQuote.quoteAuthor;
          isWorking = false;
        });

        // Fetch image from Wikipedia
        String? imageUrl = await fetchWikipediaImage(owner);
        setState(() {
          imgLink = imageUrl ?? "";
        });
      } else {
        offline();
      }
    } catch (e) {
      offline();
    }
  }

  void copyQuote() {
    FlutterClipboard.copy("$quote\n-$owner").then((result) {
      ToastContext().init(context);
      Toast.show("Quote Copied", duration: Toast.lengthLong);
    });
  }

  void shareQuote() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    String fileName = 'screenshots${DateTime.now().toIso8601String()}.png';
    var path = '$directory';
    print("File path: $path, filename: $fileName");

    screenshotController.captureAndSave(
      path,
      fileName: fileName,
    ).then((res) {
      print("File saved at: $res");
      Share.shareFiles([res.toString()], text: "$quote Download Now 'InspireMeNow App' https://play.google.com/store/apps/details?id=com.far.makeurselfinspire.make_urself_inspire");
    }).catchError((onError) {
      print("Error while capturing screenshot: $onError");
    });
  }

  void checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
  }

  Widget drawImg() {
    if (imgLink.isEmpty) {
      return Image.asset("assets/img/offline.jpg", fit: BoxFit.cover);
    } else {
      return Image.network(imgLink, fit: BoxFit.cover);
    }
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Your Quote'),
          content: Text('Are you sure you want to share by watching a video ad?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value == true) {
        shareQuote();
      }
    });
  }

  Future<bool> _onWillPop() async {
    // Check if the current screen can navigate back
    if (Navigator.of(context).canPop()) {
      print("hello far");
      // Pop the current screen and go back to the previous one
      Navigator.of(context).pop();
      return false; // Returning false to prevent the app from closing
    }
    print("back yoyo");
    Navigator.pushReplacementNamed(context, '/');

    return true; // Allow the app to close if there's no previous screen
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handles the back button press
      child: Scaffold(
        backgroundColor: grey,
        body: Screenshot(
          controller: screenshotController,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              drawImg(),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.6, 1],
                    colors: [
                      grey.withAlpha(70),
                      grey.withAlpha(220),
                      grey.withAlpha(255),
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '“ ',
                        style: TextStyle(
                          fontFamily: "Ic",
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                        children: [
                          TextSpan(
                            text: quote,
                            style: TextStyle(
                              fontFamily: "Ic",
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                            ),
                          ),
                          TextSpan(
                            text: '”',
                            style: TextStyle(
                              fontFamily: "Ic",
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      owner,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "It",
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                          onPressed: getQuote,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                          onPressed: copyQuote,
                          icon: const Icon(Icons.copy),
                          label: const Text(
                            "Copy",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      onPressed: () => showConfirmationDialog(context),
                      icon: const Icon(Icons.share),
                      label: const Text(
                        "Share",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isWorking ? Center(child: CircularProgressIndicator()) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
