class RightsManagementModel {
  final String rightsHolder;
  final String licenseReference;
  final List<String> permittedTerritories;
  final String permittedUsage;
  final DateTime? licenseStartDate;
  final DateTime? licenseEndDate;
  final bool commercialAuthorized;

  const RightsManagementModel({
    required this.rightsHolder,
    required this.licenseReference,
    this.permittedTerritories = const ['IN', 'GLOBAL'],
    this.permittedUsage = 'Streaming only',
    this.licenseStartDate,
    this.licenseEndDate,
    this.commercialAuthorized = true,
  });

  bool get isExpired {
    if (licenseEndDate == null) return false;
    return DateTime.now().isAfter(licenseEndDate!);
  }

  bool get isValidForStreaming {
    if (isExpired) return false;
    return commercialAuthorized;
  }

  Map<String, dynamic> toMap() {
    return {
      'rightsHolder': rightsHolder,
      'licenseReference': licenseReference,
      'permittedTerritories': permittedTerritories,
      'permittedUsage': permittedUsage,
      'licenseStartDate': licenseStartDate?.toIso8601String(),
      'licenseEndDate': licenseEndDate?.toIso8601String(),
      'commercialAuthorized': commercialAuthorized,
    };
  }

  factory RightsManagementModel.fromMap(Map<String, dynamic> map) {
    return RightsManagementModel(
      rightsHolder: map['rightsHolder'] as String? ?? 'Authorized Producer / Self',
      licenseReference: map['licenseReference'] as String? ?? 'N/A',
      permittedTerritories: List<String>.from(map['permittedTerritories'] ?? ['IN', 'GLOBAL']),
      permittedUsage: map['permittedUsage'] as String? ?? 'Streaming only',
      licenseStartDate: map['licenseStartDate'] != null
          ? DateTime.tryParse(map['licenseStartDate'].toString())
          : null,
      licenseEndDate: map['licenseEndDate'] != null
          ? DateTime.tryParse(map['licenseEndDate'].toString())
          : null,
      commercialAuthorized: map['commercialAuthorized'] as bool? ?? true,
    );
  }

  RightsManagementModel copyWith({
    String? rightsHolder,
    String? licenseReference,
    List<String>? permittedTerritories,
    String? permittedUsage,
    DateTime? licenseStartDate,
    DateTime? licenseEndDate,
    bool? commercialAuthorized,
  }) {
    return RightsManagementModel(
      rightsHolder: rightsHolder ?? this.rightsHolder,
      licenseReference: licenseReference ?? this.licenseReference,
      permittedTerritories: permittedTerritories ?? this.permittedTerritories,
      permittedUsage: permittedUsage ?? this.permittedUsage,
      licenseStartDate: licenseStartDate ?? this.licenseStartDate,
      licenseEndDate: licenseEndDate ?? this.licenseEndDate,
      commercialAuthorized: commercialAuthorized ?? this.commercialAuthorized,
    );
  }
}
