import 'dart:async';

import 'package:appdynamics_agent/appdynamics_agent.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AgentConfiguration(
    // **********************************************
    // Read the app key from the environment variable
    // **********************************************
    appKey: const String.fromEnvironment('APPDYNAMICS_APP_KEY'),
    loggingLevel: LoggingLevel.verbose,
  );
  await Instrumentation.start(config);
  await Instrumentation.setUserData('user-id', '1234');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AppDynamics Test',
      home: MyHomePage(title: 'AppDynamics Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // **********************************************
    // Try to log a bunch of stuff
    // **********************************************
    await Instrumentation.reportMetric(name: 'counter', value: _counter);
    await Instrumentation.leaveBreadcrumb(
      'My Breadcrumb crashesOnly',
      BreadcrumbVisibility.crashesOnly,
    );
    await Instrumentation.leaveBreadcrumb(
      'My Breadcrumb crashesAndSessions',
      BreadcrumbVisibility.crashesAndSessions,
    );
    await Instrumentation.reportMessage('Message with default severity level');
    await Instrumentation.reportMessage(
      'Message with info severity level',
      severityLevel: ErrorSeverityLevel.info,
    );
    await Instrumentation.reportMessage(
      'Message with warning severity level',
      severityLevel: ErrorSeverityLevel.warning,
    );
    await Instrumentation.reportMessage(
      'Message with critical severity level',
      severityLevel: ErrorSeverityLevel.critical,
    );
    await Instrumentation.reportError(StateError('This is a test error'));
    await Instrumentation.reportException(
      Exception('This is a test exception'),
    );
    await Instrumentation.reportException(
      Exception('This is a test exception with a stack trace'),
      stackTrace: StackTrace.current,
    );
    if (_counter > 5) {
      // Delaying 1 minute to allow the messages to be sent
      print('!!!!!!!! Going to crash in 1 minute !!!!!!!!');
      await Future.delayed(const Duration(minutes: 1));
      // **********************************************
      // Crash the app if the counter is greater than 5
      // **********************************************
      Instrumentation.crash();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'If greater than 5, the app will wait 1 minute and then trigger a crash',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
