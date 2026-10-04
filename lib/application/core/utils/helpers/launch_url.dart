import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LaunchUrl {
  static void makeACall(String phoneNumber) async {
    if (!await launchUrl(Uri.parse('tel:$phoneNumber'))) {
      throw 'Could not launch $phoneNumber';
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static Future<void> sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static void openUrl(String? link) async {
    if (link == null) return;
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $link';
    }
  }

  static void openGoogleMapByAddress({String fromAddress = '', String toAddress = '', String? link}) async {
    Uri url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=$fromAddress&destination=$toAddress&key=AIzaSyAivgO_m1hX7a1pVwEm2xg7OIqxi0L8iOg");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $link';
    }
  }

  static void openGoogleMap({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? link,
  }) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $link';
    }
  }

  static Future<bool> openMap({required double lat, required double lng}) async {
    final String urlString = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (!await canLaunchUrlString(urlString)) {
      throw Exception();
    }
    return await launchUrlString(urlString, mode: LaunchMode.externalApplication);
  }
}
