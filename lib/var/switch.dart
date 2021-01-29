import 'dart:async';

enum MainScreen {
  Init,
  Processing
}

class _MainSwitch{
  StreamController<MainScreen> _s = StreamController<MainScreen>();
  _MainSwitch() {
    _s.add(MainScreen.Init);
  }

  void screenSwitch(MainScreen screen) {
    _s.add(screen);
  }

  Stream<MainScreen> get stream => _s.stream;

}


final _MainSwitch sswitch = _MainSwitch();



