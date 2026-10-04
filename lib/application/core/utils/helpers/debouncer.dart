import 'dart:async';

import 'dart:ui';


class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({ required this.milliseconds });

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer?.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

Function() debounce(Function() func, int milliseconds) {
  Timer? timer;
  return () {
    // or (arg) if you need an argument
    if (timer != null) {
      timer?.cancel();
    }
    timer =
        Timer(Duration(milliseconds: milliseconds), func); // or () => func(arg)
  };
}
