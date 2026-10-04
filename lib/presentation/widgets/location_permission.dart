import 'package:futblha/presentation/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:futblha/generated/locale_keys.g.dart';

class LocationPermissionDialog extends StatefulWidget {
  const LocationPermissionDialog({super.key});

  @override
  State<LocationPermissionDialog> createState() => _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  bool isOpenSettings = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Location Permission Denied',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      content: const Text(
        'Please grant location permission always to continue using the application.',
        style: TextStyle(fontSize: 16),
      ),
      actions: <Widget>[
        isOpenSettings
            ? TextButton(
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : CustomElevatedButton(
                title: LocaleKeys.open_settings.tr(),
                onPressed: () {
                  setState(() {
                    isOpenSettings = true;
                  });

                  openAppSettings();
                  Navigator.pop(context);
                },
              ),
      ],
    );
  }
}
