import 'package:flutter/material.dart';

extension DateTimeExtensions on DateTime {
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month - 1]} $day, $year';
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return formattedDate;
  }
}

extension IntExtensions on int {
  String get percentStr => '$this%';
}

extension DoubleExtensions on double {
  String get percentStr => '${(this * 100).round()}%';
}
