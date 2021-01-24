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
          padding: EdgeInsets.only(top:100),
          child: _setActionbtn(),
          width : 330,
          height : 330,
        ),
        Container(
          padding: EdgeInsets.only(top: 60),
          child:_nextBtn()
        )
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
          return Text("Encode",style: TextStyle(fontSize: 28));
        }else {
          return Text("Decode",style: TextStyle(fontSize: 28));
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


