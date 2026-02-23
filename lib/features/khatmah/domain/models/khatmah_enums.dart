enum KhatmahPlanType { fixedDays, open, ramadanPreset }

extension KhatmahPlanTypeX on KhatmahPlanType {
  String get key => switch (this) {
    KhatmahPlanType.fixedDays => 'fixed_days',
    KhatmahPlanType.open => 'open',
    KhatmahPlanType.ramadanPreset => 'ramadan_preset',
  };

  static KhatmahPlanType fromKey(String? key) {
    return switch (key) {
      'open' => KhatmahPlanType.open,
      'ramadan_preset' => KhatmahPlanType.ramadanPreset,
      _ => KhatmahPlanType.fixedDays,
    };
  }
}

enum KhatmahPlanStatus { active, completed, archived }

extension KhatmahPlanStatusX on KhatmahPlanStatus {
  String get key => switch (this) {
    KhatmahPlanStatus.active => 'active',
    KhatmahPlanStatus.completed => 'completed',
    KhatmahPlanStatus.archived => 'archived',
  };

  static KhatmahPlanStatus fromKey(String? key) {
    return switch (key) {
      'completed' => KhatmahPlanStatus.completed,
      'archived' => KhatmahPlanStatus.archived,
      _ => KhatmahPlanStatus.active,
    };
  }
}

enum KhatmahStartPointOption { firstPage, lastReadPage, customPage }

extension KhatmahStartPointOptionX on KhatmahStartPointOption {
  String get key => switch (this) {
    KhatmahStartPointOption.firstPage => 'first_page',
    KhatmahStartPointOption.lastReadPage => 'last_read_page',
    KhatmahStartPointOption.customPage => 'custom_page',
  };

  static KhatmahStartPointOption fromKey(String? key) {
    return switch (key) {
      'last_read_page' => KhatmahStartPointOption.lastReadPage,
      'custom_page' => KhatmahStartPointOption.customPage,
      _ => KhatmahStartPointOption.firstPage,
    };
  }
}
