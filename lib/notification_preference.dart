enum NotificationPreference {
  NEVER,
  NOTIFY_ONCE,
  ALWAYS,
  UNKNOWN
}

class NotificationPreferenceParser {
  static NotificationPreference parse (String notificationPreference) {
    switch (notificationPreference) {
      case 'never':
        return NotificationPreference.NEVER;
      case 'notify_once':
        return NotificationPreference.NOTIFY_ONCE;
      case 'always':
        return NotificationPreference.ALWAYS;
    }
    return NotificationPreference.UNKNOWN;
  }
}