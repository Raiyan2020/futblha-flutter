// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class LocationHelper {
//   static Position? _currentLocation;
//
//   static Future<void> getCurrentLocation() async {
//     var permission = await Permission.location.status;
//     if (permission.isDenied) {
//       // Permissions are denied, request them again.
//       permission = await Permission.location.request();
//       if (permission.isGranted) {
//         // Permissions are granted, proceed to get the location.
//         _currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       } else {
//         // Permissions are denied again, handle accordingly.
//         print('Location permissions are denied');
//       }
//     } else if (permission.isGranted) {
//       // Permissions are already granted, proceed to get the location.
//       _currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     } else {
//       // Handle other statuses.
//       print('Permission status is: $permission');
//     }
//   }
//
//   static Position? get currentLocation => _currentLocation;
// }
