import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart' show config;



class Intro extends StatefulWidget {
  StreamSink<int> _router;
  Intro.setRouter(this._router);

 @override
  _IntroState createState() => _IntroState();
}


class _IntroState extends State<Intro> {

  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: 
      [
        Container(
          padding: EdgeInsets.all(30),
          child: _setActionbtn(),
        ),
        _nextBtn()
      ],);
  }



  Widget _setActionbtn() {
    return MaterialButton(
      onPressed: () {
        config.switchAction();
        setState(() {});
      },
      child: () {
        if(config.isEncode()) {
          return Text("Encode");
        }else {
          return Text("Decode");
        }
      }(),
      shape: CircleBorder(
        side: BorderSide(width : 1,style: BorderStyle.solid,color: Colors.red)
      ),
      textColor: Colors.amber,
      color: Colors.blue,
    );
  }
  Widget _nextBtn() {
    return RaisedButton(
          onPressed: () {
            widget._router.add(2);
          },
          child : Text("next")
    );
  }
}


