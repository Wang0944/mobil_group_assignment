import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Flights/flights_page.dart';
import 'customer_page.dart';
import 'app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // 默认语言

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: 'Mobil_group_assignment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(
        title: 'Mobil_group_assignment',
        setLocale: _setLocale,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title, required this.setLocale});

  final String title;
  final Function(Locale) setLocale;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton(
            child: const Text('中文'),
            onPressed: () {
              widget.setLocale(const Locale('zh'));
            },
          ),
          TextButton(
            child: const Text('English'),
            onPressed: () {
              widget.setLocale(const Locale('en'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context).translate('instructions')),
                    content: Text(AppLocalizations.of(context).translate('instructions_content')),
                    actions: [
                      TextButton(
                        child: Text(AppLocalizations.of(context).translate('ok')),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context).translate('customer_page')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerPage(setLocale: widget.setLocale)),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Flights'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FlightsPage(title: 'What is this',)));
              },
            ),
            ElevatedButton(
              child: const Text('Page 3'),
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => Page3()));
              },
            ),
            ElevatedButton(
              child: const Text('Page 4'),
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => Page4()));
              },
            ),
          ],
        ),
      ),
    );
  }
}//dsfdsfdsfsf