import 'dart:async';
import 'package:flutter/material.dart';
import '../config.dart' as AppConfig;

class CryptoSetView extends StatefulWidget {
  StreamSink<int> _router;
  CryptoSetView(this._router);
  
  @override
  State<CryptoSetView> createState() {
    return CryptoSetViewState();
  }
}

class CryptoSetViewState extends State<CryptoSetView> {
  List<bool> _selectExpaned = [false,false];


  String cryptoPanelName() {
    var mode = AppConfig.config.mode;
    if(AppConfig.CryptoMode.AES_GCM == mode)
      return "Aes GCM";
    else if(AppConfig.CryptoMode.AES_CTR == mode)
      return "Aes CTR";
    else
      return "Aes CBC";
  }
  String hashPanelName() {
    var mode = AppConfig.config.hash;
    if(AppConfig.KeyHash.SHA1 == mode)
      return "sha1";
    else if(AppConfig.KeyHash.SHA256 == mode)
      return "sha256";
    else
      return "md5";
  }


  @override
  Widget build(BuildContext context){
    return Column(
      children: 
      [
        _selectCryptoBox()
      ],);
  }
  Widget _selectCryptoBox() {
    return ExpansionPanelList(
      expansionCallback: (int index,bool isExpaned) {
        setState((){
          _selectExpaned[index] =  !_selectExpaned[index];
          
        });
      },
      children: 
      [
        _selectCrypto(),
        _selectPasswdHash()
      ]
    );
  }
  
  ExpansionPanel _selectCrypto() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context,bool isExpaned) {
        return ListTile(title : Text("Crypto: ${cryptoPanelName()}"));
      },
      isExpanded: _selectExpaned[0],
      body : Column(
        children: [
          ListTile(
            title: const Text('Aes CBC'),
            leading: Radio(
              value:  AppConfig.CryptoMode.AES_CBC,
              groupValue: AppConfig.config.mode,
              onChanged: (AppConfig.CryptoMode value) {
                setState(() {
                  AppConfig.config.mode = value;
                });
              },
            ),
            
          ),
          ListTile(
            title: const Text('Aes CTR'),
            leading: Radio(
              value:  AppConfig.CryptoMode.AES_CTR,
              groupValue: AppConfig.config.mode,
              onChanged: (AppConfig.CryptoMode value) {
                setState(() {
                  AppConfig.config.mode = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Aes GCM'),
            leading: Radio(
              value:  AppConfig.CryptoMode.AES_GCM,
              groupValue: AppConfig.config.mode,
              onChanged: (AppConfig.CryptoMode value) {
                setState(() {
                  AppConfig.config.mode = value;
                });
              },
            ),
          )
        ],
      )
    );
  }
    
  ExpansionPanel _selectPasswdHash() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context,bool isExpaned) {
        return ListTile(title : Text("Passwd Hash: ${hashPanelName()}"));
      },
      isExpanded: _selectExpaned[1],
      body : Column(
        children: [
          ListTile(
            title: const Text('MD5'),
            leading: Radio(
              value:  AppConfig.KeyHash.MD5,
              groupValue: AppConfig.config.hash,
              onChanged: (AppConfig.KeyHash value) {
                setState(() {
                  AppConfig.config.hash = value;
                });
              },
            ),
            
          ),
          ListTile(
            title: const Text('SHA1'),
            leading: Radio(
              value:  AppConfig.KeyHash.SHA1,
              groupValue: AppConfig.config.hash,
              onChanged: (AppConfig.KeyHash value) {
                setState(() {
                  AppConfig.config.hash = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('SHA256'),
            leading: Radio(
              value:  AppConfig.KeyHash.SHA256,
              groupValue: AppConfig.config.hash,
              onChanged: (AppConfig.KeyHash value) {
                setState(() {
                  AppConfig.config.hash = value;
                });
              },
            ),
          )
        ],
      )
    );
  }
  Widget _nextBtn() {
    return RaisedButton(
          onPressed: () {
            
          },
          child : Text("next")
    );
  }





}