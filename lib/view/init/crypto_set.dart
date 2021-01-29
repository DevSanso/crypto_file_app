import 'dart:async';
import 'package:flutter/material.dart';
import '../../var/config.dart' as AppConfig;

class CryptoSetView extends StatefulWidget {
  StreamSink<int> _router;
  CryptoSetView(this._router);
  
  @override
  State<CryptoSetView> createState() {
    return CryptoSetViewState();
  }
}

class CryptoSetViewState extends State<CryptoSetView> {
  


  @override
  Widget build(BuildContext context){
    
  }
  
  Widget _nextBtn() {
    return RaisedButton(
          onPressed: () {
            
          },
          child : Text("next")
    );
  }





}