import 'loopback_redirect_stub.dart'
    if (dart.library.html) 'loopback_redirect_web.dart' as impl;

Future<bool> redirectLoopbackHostToLocalhost() {
  return impl.redirectLoopbackHostToLocalhost();
}
