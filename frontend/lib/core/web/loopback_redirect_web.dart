import 'package:web/web.dart' as web;

Future<bool> redirectLoopbackHostToLocalhost() async {
  final location = web.window.location;
  final currentHost = location.hostname;
  const loopbackAliases = {'127.0.0.1', '0.0.0.0', '::1', '[::1]'};

  if (!loopbackAliases.contains(currentHost)) {
    return false;
  }

  final protocol = location.protocol;
  final port = location.port;
  final portSegment = port.isEmpty ? '' : ':$port';
  final path = location.pathname;
  final search = location.search;
  final hash = location.hash;
  final target = '$protocol//localhost$portSegment$path$search$hash';

  if (location.href != target) {
    location.replace(target);
    return true;
  }

  return false;
}
