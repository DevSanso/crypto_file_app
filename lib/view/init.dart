import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';


import './init/intro.dart';



class InitView extends StatefulWidget {
  StreamController<int> routerQueue = StreamController<int>();



  @override
  State<InitView> createState() {
    routerQueue.add(1);
    return _InitState();
  }
}


class _InitState extends State<InitView> {
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

      for(var i in [1,2,3,4]) {
        
        res.add(
          Expanded(
            child: OutlineButton(
              child:Text(i.toString()),
              onPressed: (){widget.routerQueue.add(i);}
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
            break;
          case 2:
            view = Text(snapshot.data.toString());
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