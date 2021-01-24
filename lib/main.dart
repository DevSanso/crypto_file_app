import 'dart:async';


import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import 'view/intro.dart';
import 'view/crypto_set.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto File',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Crypto File'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<int> routerQueue = StreamController<int>();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    routerQueue.add(1);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: scaffoldBody() // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  Widget scaffoldBody() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: widgetRouter(),
        ),
        mainWidget(),
       
      ],
    );
  }
 
  Widget widgetRouter() {
    
    final genIndex = () {
      var res = List<Widget>();

      for(var i in [1,2,3,4]) {
        
        res.add(
          Expanded(
            child: OutlineButton(
              child:Text(i.toString()),
              onPressed: (){routerQueue.add(i);}
            )
          )
        );
      }
      
      return res;
    };

    
    return Row(
      children: genIndex(),
    );
  }

  Widget mainWidget() {
    return StreamBuilder(
      stream : this.routerQueue.stream,
      builder: (context,AsyncSnapshot<int> snapshot) {
        //first init time, snapshot is null,first stream add function 1, before wait loading widget
        Widget view = LoadingRotating.square(
          borderColor: Colors.blueGrey,
          borderSize: 3,
          size : 30,
          duration: Duration(milliseconds: 500),
        );

        switch(snapshot.data) {
          case 1:
            view = Intro.setRouter(this.routerQueue);
            break;
          case 2:
            view = CryptoSetView(this.routerQueue);
            break;
          case 3:
            view = Text(snapshot.data.toString());
            break;
          case 4:
            view = Text(snapshot.data.toString());
            break;
        }
        return view;
      }
    );
  }
}
