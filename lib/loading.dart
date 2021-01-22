import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';


class Loading extends StatelessWidget {

  Stream<String> messageQueue;
  Loading.setStream(this.messageQueue);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Row(
          children: 
          [
            loadingAni(),
            textBox()
          ],
        ),
      )
    );
  }
  Widget loadingAni() {
    return Container(
      margin: EdgeInsets.only(top : 10),
      child: Center(
        child:  LoadingRotating.square(
          borderColor: Colors.blueGrey,
          borderSize: 3,
          size : 30,
          duration: Duration(milliseconds: 500),
        ),
      ),
    );
  }


  Widget textBox() {
    return StreamBuilder(
      stream: messageQueue,
      builder: (context,AsyncSnapshot<String> snapshot) => Text(
        snapshot.data
      )
    );
  }
}