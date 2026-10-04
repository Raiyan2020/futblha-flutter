import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/id_encryption.dart';

class AppLinksService {
  final AppLinks _appLinks = AppLinks();
  Stream<Uri>? _linkStream;

  DateTime? _lastHandledTime;
  static const Duration _debounceDuration = Duration(milliseconds: 600);

  void init(BuildContext context) {
    // Stream listener (runs when app already open OR immediately after cold start)
    _linkStream = _appLinks.uriLinkStream;
    _linkStream?.listen((uri) {
      _handleUriWithDebounce(context, uri);
    });

    // Initial link (cold start) - delay to ensure app is fully initialized
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        // Wait a bit for the app to be ready before handling the deep link
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            _handleUriWithDebounce(context, uri);
          }
        });
      }
    });
  }

  void _handleUriWithDebounce(BuildContext context, Uri uri) {
    final now = DateTime.now();

    // Prevent double handling
    if (_lastHandledTime != null && now.difference(_lastHandledTime!) < _debounceDuration) {
      return;
    }

    _lastHandledTime = now;
    _handleUri(context, uri);
  }

  void _handleUri(BuildContext context, Uri uri) {
    debugPrint('Received deep link: $uri');

    // Handle https://futblha.com/diwaniya/{encryptedId} format
    if (uri.host == 'futblha.com' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'diwaniya') {
      if (uri.pathSegments.length > 1) {
        final encryptedDiwaniyaId = uri.pathSegments[1];

        try {
          final diwaniyaId = IdEncryption.decrypt(encryptedDiwaniyaId);

          // Wait for router to be ready, then navigate
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                try {
                  context.router.push(DiwaniyaDetailsRoute(diwaniyaId: diwaniyaId.toString()));
                } catch (e) {
                  debugPrint('Error navigating to diwaniya details: $e');
                }
              }
            });
          });
        } catch (e) {
          debugPrint('Failed to decrypt diwaniya ID: $e');
        }
      }
    }
    // Handle futblha://diwaniya/{encryptedId} format (custom scheme fallback)
    else if (uri.scheme == 'futblha' && uri.host == 'diwaniya') {
      final encryptedDiwaniyaId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : uri.path;

      if (encryptedDiwaniyaId.isNotEmpty) {
        try {
          final diwaniyaId = IdEncryption.decrypt(encryptedDiwaniyaId);

          // Wait for router to be ready, then navigate
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                try {
                  context.router.push(DiwaniyaDetailsRoute(diwaniyaId: diwaniyaId.toString()));
                } catch (e) {
                  debugPrint('Error navigating to diwaniya details: $e');
                }
              }
            });
          });
        } catch (e) {
          debugPrint('Failed to decrypt diwaniya ID: $e');
        }
      }
    }
  }
}
