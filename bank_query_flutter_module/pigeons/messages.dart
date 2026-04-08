import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: '../app/src/main/java/com/example/santparentapp/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.santparentapp'),
    dartPackageName: 'bank_query_flutter_module',
  ),
)

class TokenPayload {
  String? token;
  String? route;
}

@HostApi()
abstract class NativeApi {
  String? getToken();
  void sendAppLog(String message);
}

@FlutterApi()
abstract class FlutterTokenApi {
  void onTokenReceived(TokenPayload payload);
}
