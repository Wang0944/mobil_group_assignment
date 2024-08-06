import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobil_group/customer_page.dart';

import 'airplane_page.dart';
import 'AppLocalizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> { //open the state <MyApp> class
  var locale = Locale("en", "CA");

  void changeLanguage(Locale newLanguage) {
    setState(() {
      locale = newLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [Locale("en", "CA"), Locale("zh", "ZH")],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate

      ],
      locale: locale,
      title: 'Mobil_group_assignment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Mobil_group_assignment'),
    );
  }

}




class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

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
              MyApp.setLocale(context, Locale("zh","ZH"));
            },
          ),
          TextButton(
            child: const Text('English'),
            onPressed: () {
              MyApp.setLocale(context, Locale("en","CA"));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.translate('instructions')!),
                    content: const Text('Instructions for using the app.'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
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
              child: const Text('Customer Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Airplane Page'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AirplanePage()));
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
}