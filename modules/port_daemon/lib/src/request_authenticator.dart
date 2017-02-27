import 'package:express/express.dart';

abstract class RequestAuthenticator {
  bool isContextValid(HttpContext context);
}
