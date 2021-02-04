import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';


import './init/intro.dart';
import './init/crypto_set.dart';
import './init/file_set.dart';

class InitView extends StatefulWidget {
  StreamController<int> routerQueue = StreamController<int>();



  @override
  State<InitView> createState() {
    
    return _InitState();
  }
}


class _InitState extends State<InitView> {
  List<bool> canMove;
  @override
  void initState() {
    super.initState();
    canMove = [false,false,false];
    widget.routerQueue.add(1);
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: 
      [
        widgetRouter(),
        mainWidget()
      ],
    );
    
  }

  Widget widgetRouter() {
    
    final genIndex = () {
      var res = List<Widget>();

      for(var i in [1,2,3]) {
        
        res.add(
          Expanded(
            child: OutlineButton(
              child:Text(""),
              onPressed: (){
                if(!canMove[i-1])return;
                widget.routerQueue.add(i);
              }
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
      stream : widget.routerQueue.stream,
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
            view = Intro.setRouter(widget.routerQueue);
            canMove[0] = true;
            break;
          case 2:
            view = CryptoSetView(widget.routerQueue);
            canMove[1] = true;
            break;
          case 3:
            view = FileSetView(widget.routerQueue);
            canMove[2] = true;
            break;
        }
        return view;
      }
    );
  }
}