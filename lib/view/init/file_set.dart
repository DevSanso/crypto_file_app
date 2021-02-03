import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../var/config.dart' as AppConfig;

class FileSetView extends StatefulWidget {
  StreamSink<int> _router;
  FileSetView(this._router);
  @override
  State<StatefulWidget> createState() {
    return _FileSetState();
  }
}


class _FileSetState extends State<FileSetView> {
  bool isOpenFile;
  bool isOpenDir;
  @override
  void initState() {
    super.initState();
    isOpenFile = false;
    isOpenDir = false;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Selecting",style:TextStyle(fontSize: 36)),
        Container(
          child:selectFilePicker(),
          margin: EdgeInsets.only(top:100,bottom:40),
        ),
        Container(
          child:selectOutDir(),
          margin: EdgeInsets.only(bottom:80),
        ),
        if(checkValue())nextBtn()
      ],
    );
  }

  bool checkValue() {
    return AppConfig.config.srcFile != null && 
      AppConfig.config.dstDirPath != null;
  }
  void srcBtnEvent() async {
    AppConfig.config.srcFile = File(await openFileDialog());
    setState(() {});
  }
  void outBtnEvent() async {
    AppConfig.config.dstDirPath = await openDirDialog();
    setState(() {});
  }

  String getSrcFilePath(){
    if(AppConfig.config.srcFile == null)return "file open";
    else return AppConfig.config.srcFile.path;
  }
  String getDirPath(){
    if(AppConfig.config.dstDirPath == null)return "dir open";
    else return AppConfig.config.dstDirPath;
  }
  
  Widget selectFilePicker() {
    return Row(children: [
      Container(
        width: 250,
        height : 30,
        decoration: BoxDecoration(
          border:  Border.all(width: 1)
        ),
        child: Text(
          "${getSrcFilePath()}",
          style: TextStyle(fontSize: 12),
        )
      ),
      Expanded(
        child: RaisedButton(
          child: Text("Open"),
          onPressed: srcBtnEvent)
      ),
    ],);
  }
  Widget selectOutDir() {
       return Row(children: [
      Container(
        width: 250,
        height : 30,
        decoration: BoxDecoration(
          border:  Border.all(width: 1)
        ),
        child: Text(
          "${getDirPath()}",
          style: TextStyle(fontSize: 12),
        )
      ),
      Expanded(
        child: RaisedButton(
          child: Text("Open"),
          onPressed: outBtnEvent)
      ),
    ],);
  }

  Widget nextBtn() {
    return RaisedButton(
          onPressed: () {
            widget._router.add(4);
          },
          child : Text("running")
    );
  }
 
  Future<String> openFileDialog() async {
    var result = await FilePicker.platform.pickFiles();
    return result.paths[0];
  }
  Future<String> openDirDialog() async{
    var result = await FilePicker.platform.getDirectoryPath();
    return result;
  }
}