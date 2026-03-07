class UserModel {
  final String id;
  final String cedula;
  final String kycStatus; // 'PENDING', 'APPROVED', 'REJECTED'
  final String? truoraId;
  final bool complianceModeBypass;
  final int lanayaPoints;
  final bool hasFeeFreeCredit;
  final bool isFoundingMember;
  final String? betaCodeUsed;
  final bool betaAccessGranted;

  UserModel({
    required this.id,
    required this.cedula,
    required this.kycStatus,
    this.truoraId,
    this.complianceModeBypass = false,
    this.lanayaPoints = 0,
    this.hasFeeFreeCredit = false,
    this.isFoundingMember = false,
    this.betaCodeUsed,
    this.betaAccessGranted = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      cedula: data['cedula'] ?? '',
      kycStatus: data['kycStatus'] ?? 'PENDING',
      truoraId: data['truoraId'],
      complianceModeBypass: data['complianceModeBypass'] ?? false,
      lanayaPoints: data['lanayaPoints'] ?? 0,
      hasFeeFreeCredit: data['hasFeeFreeCredit'] ?? false,
      isFoundingMember: data['isFoundingMember'] ?? false,
      betaCodeUsed: data['betaCodeUsed'],
      betaAccessGranted: data['betaAccessGranted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'kycStatus': kycStatus,
      'truoraId': truoraId,
      'complianceModeBypass': complianceModeBypass,
      'lanayaPoints': lanayaPoints,
      'hasFeeFreeCredit': hasFeeFreeCredit,
      'isFoundingMember': isFoundingMember,
      'betaCodeUsed': betaCodeUsed,
      'betaAccessGranted': betaAccessGranted,
    };
  }

  UserModel copyWith({
    String? id, String? cedula, String? kycStatus, String? truoraId,
    bool? complianceModeBypass, int? lanayaPoints, bool? hasFeeFreeCredit,
    bool? isFoundingMember, String? betaCodeUsed, bool? betaAccessGranted,
  }) {
    return UserModel(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      kycStatus: kycStatus ?? this.kycStatus,
      truoraId: truoraId ?? this.truoraId,
      complianceModeBypass: complianceModeBypass ?? this.complianceModeBypass,
      lanayaPoints: lanayaPoints ?? this.lanayaPoints,
      hasFeeFreeCredit: hasFeeFreeCredit ?? this.hasFeeFreeCredit,
      isFoundingMember: isFoundingMember ?? this.isFoundingMember,
      betaCodeUsed: betaCodeUsed ?? this.betaCodeUsed,
      betaAccessGranted: betaAccessGranted ?? this.betaAccessGranted,
    );
  }
}
