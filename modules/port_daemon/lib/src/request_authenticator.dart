import 'package:distributed.net/secret.dart';
import 'package:express/express.dart';

abstract class RequestAuthenticator {
  bool isContextValid(HttpContext context);
}

class SecretAuthenticator implements RequestAuthenticator {
  final Secret requiredSecret;

  SecretAuthenticator(this.requiredSecret);

  @override
  bool isContextValid(HttpContext context) {
    var foreignSecret =
        new Secret.fromString(Uri.decodeComponent(context.params['secret']));
    return requiredSecret.matches(foreignSecret);
  }
}
