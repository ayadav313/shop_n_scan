import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Future<String> handleApi(total) async {
    var jsonBody = {
      "amount": {"total": total, "currency": "USD"},
      "source": {
        "sourceType": "PaymentCard",
        "card": {
          "cardData": "4005550000000016",
          "expirationMonth": "02",
          "expirationYear": "2035"
        }
      },
      "transactionDetails": {"captureFlag": true},
      "transactionInteraction": {
        "origin": "ECOM",
        "eciIndicator": "CHANNEL_ENCRYPTED",
        "posConditionCode": "CARD_NOT_PRESENT_ECOM"
      },
      "merchantDetails": {
        "merchantId": "100008000003683",
        "terminalId": "10000001"
      }
    };

    var key = 'ZxmiHz3CxGmUzWZ1SJZPcx0JHhCSPGYT';
    var secret = 'xwn4X2VAN8ug4Jmvuj1kZbCEL7yoTBCnH3AicTtMEtx';
    var clientRequestId = DateTime.now().millisecondsSinceEpoch;
    var time = DateTime.now().millisecondsSinceEpoch;
    var rawSignature = '$key$clientRequestId$time${jsonEncode(jsonBody)}';
    var hmacSha256 = Hmac(sha256, utf8.encode(secret));
    var signatureBytes = hmacSha256.convert(utf8.encode(rawSignature)).bytes;
    var computedHmac = base64.encode(signatureBytes);
    
    // Now you can use the variables in your Flutter code
    var headers = {
      "Content-Type": "application/json",
      "Authorization": computedHmac,
      "Api-Key": key,
      "Client-Request-Id": clientRequestId.toString(),
      "Timestamp": time.toString(),
      "Auth-Token-Type": "HMAC",
      "Accept": "application/json",
      "Accept-Language": "en"
    };

    var url = 'https://cert.api.fiservapps.com/ch/payments/v1/charges';

    // Create new client
    HttpClient httpClient = HttpClient();

    // Make the post url
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // Set headers
    headers.forEach((header, value) {
      request.headers.set(header, value);
    });

    // Set the request body
    request.write(jsonEncode(jsonBody));

    // Get the response
    HttpClientResponse response = await request.close();

    // Read the response
    Future<String> responseBody = response.transform(utf8.decoder).join();

    return responseBody;
  }