import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Network connectivity check
  static Future<bool> hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.last != ConnectivityResult.none;
  }

  // Date formatting
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  // Time formatting
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  // Date and time formatting
  static String formatDateTime(
    DateTime? dateTime, {
    String format = 'yyyy-MM-dd HH:mm',
  }) {
    if (dateTime == null) return 'N/A';
    return DateFormat(format).format(dateTime);
  }

  // Relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Show a snackbar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Duration? duration,
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  // Show a toast message
  static void showToast(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration ?? const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Email validation
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  // Password validation (at least 8 chars, 1 uppercase, 1 lowercase, 1 number)
  static bool isValidPassword(String password) {
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Phone number validation (simple)
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // URL validation
  static bool isValidUrl(String url) {
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$',
    );
    return urlRegExp.hasMatch(url);
  }

  // Truncate string with ellipsis
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(2)} GB';
    }
  }

  // Format currency
  static String formatCurrency(
    double amount, {
    String symbol = '\$',
    String locale = 'en_US',
  }) {
    return NumberFormat.currency(symbol: symbol, locale: locale).format(amount);
  }

  // Format interval string (e.g., "48h" to "2 days")
  static String formatInterval(String? interval) {
    if (interval == null || interval.isEmpty) {
      return '0h';
    }
    final intHours = int.tryParse(interval.replaceAll('h', '')) ?? 0;
    if (intHours < 24) {
      return '$intHours hours';
    } else {
      final days = (intHours / 24).round();
      return '$days days';
    }
  }

  // static String formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final hours = twoDigits(duration.inHours);
  //   final minutes = twoDigits(duration.inMinutes.remainder(60));
  //   final seconds = twoDigits(duration.inSeconds.remainder(60));
  //   return '$hours:$minutes:$seconds';
  // }

  // Parse duration string like "1h30m" to milliseconds
  static int durationToMs(String durationStr) {
    final regex = RegExp(r'(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?');
    final match = regex.firstMatch(durationStr);
    if (match == null) {
      return 0;
    }
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    return hours * 3600000 + minutes * 60000 + seconds * 1000;
  }

  // Convert milliseconds to duration string "HH:MM:SS"
  static String msToHHmmss(int? durationMs) {
    if (durationMs == null || durationMs <= 0) {
      return '';
    }
    final duration = Duration(milliseconds: durationMs);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // Convert milliseconds to duration string "Xh Ym Zs"
  static String msToDurationString(int? durationMs) {
    if (durationMs == null || durationMs <= 0) {
      return '';
    }
    final duration = Duration(milliseconds: durationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    String result = '';
    if (hours > 0) {
      result += '${hours}h';
    }
    if (minutes > 0) {
      result += '${minutes}m';
    }
    if (seconds > 0) {
      result += '${seconds}s';
    }
    return result;
  }

  // Convert UTC DateTime to local and format
  // e.g., "2025-10-02 13:40:44.711Z" to "2025-10-02 01:40 PM"
  static String utcToLocalString(DateTime? utcDateTime) {
    if (utcDateTime == null) return '';
    final localDateTime = utcDateTime.toLocal();
    return DateFormat('yyyy-MM-dd hh:mm a').format(localDateTime);
  }

  // Convert 24h UTC to 12h Local format
  // e.g., "14:30" to "2:30 PM"
  static String to12HourFormat(String? time24Utc) {
    if (time24Utc == null) return '';
    try {
      // Handle time only format
      final dateTime = DateTime.parse('2026-01-22T$time24Utc.000Z');
      final localDateTime = dateTime.toLocal();
      return DateFormat.jm().format(localDateTime);
    } catch (e) {
      return time24Utc; // Return original if parsing fails
    }
  }

  // Parse 12h to 24h format
  static String to24HourFormat(String? time12) {
    try {
      if (time12 == null) return '';
      final dateTime = DateTime.parse('2026-01-22T$time12.000Z');
      final localDateTime = dateTime.toLocal();
      return DateFormat.Hms().format(localDateTime);
    } catch (e) {
      return time12!; // Return original if parsing fails
    }
  }

  // Parse local "HH:MM:SS" to UTC "HH:MM:SS"
  static String? toUtcTime(String? localTime) {
    if (localTime == null) return null;
    try {
      final now = DateTime.now();
      final localDateTime = DateFormat.Hms().parse(localTime);
      final combinedLocal = DateTime(
        now.year,
        now.month,
        now.day,
        localDateTime.hour,
        localDateTime.minute,
        localDateTime.second,
      );
      final utcDateTime = combinedLocal.toUtc();
      return DateFormat.Hms().format(utcDateTime);
    } catch (e) {
      return localTime; // Return original if parsing fails
    }
  }

  // Parse UTC "HH:MM:SS" to local "HH:MM:SS"
  static String? toLocalTime(String? utcTime) {
    if (utcTime == null) return null;
    try {
      final dateTime = DateTime.parse('2026-01-22T$utcTime.000Z');
      final localDateTime = dateTime.toLocal();
      return DateFormat.Hms().format(localDateTime);
    } catch (e) {
      return utcTime; // Return original if parsing fails
    }
  }
}
