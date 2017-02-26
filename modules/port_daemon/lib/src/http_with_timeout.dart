import 'dart:async';
import 'package:distributed.objects/timeout.dart';
import 'package:seltzer/seltzer.dart';

class HttpWithTimeout {
  Future<SeltzerHttpResponse> send(
    SeltzerHttpRequest request, [
    Object payload,
    Duration timeout = Timeout.defaultDuration,
  ]) {
    var timeout = new Timeout(() {
      throw new TimeoutError(request.toString());
    });

    return request.send().first.then((response) {
      timeout.cancel();
      return response;
    });
  }
}
