import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager_ext.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final token = context.read<AuthService>().token;
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.mainApiBase}/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          _notifications = jsonDecode(res.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: isParadise ? cs.primary : cs.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticService.instance.light();
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isParadise ? cs.onPrimary : cs.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'NOTIFICATIONS',
          style: tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: isParadise ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
      body: _buildBody(cs, tt),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: cs.error)),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 48, color: cs.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No notifications yet.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) =>
          Divider(color: cs.outlineVariant.withOpacity(0.5)),
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        final isLike = notif['type'] == 'like';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLike ? cs.tertiaryContainer : cs.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLike ? Icons.favorite_rounded : Icons.chat_bubble_rounded,
                  color: isLike ? cs.tertiary : cs.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        children: [
                          TextSpan(
                              text: '${notif['user_name']} ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: isLike
                                  ? 'liked your post '
                                  : 'commented on your post '),
                          TextSpan(
                              text: '"${notif['post_title']}"',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    if (!isLike && notif['text'] != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '"${notif['text']}"',
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
