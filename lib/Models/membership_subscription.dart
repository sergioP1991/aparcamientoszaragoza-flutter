import 'package:cloud_firestore/cloud_firestore.dart';

/// Estados de la suscripción
enum MembershipStatus {
  basic,        // Usuario básico sin PRO
  pro,          // Usuario PRO activo
  canceled,     // Suscripción cancelada
  expired,      // Suscripción expirada
}

/// Tipos de planes
enum MembershipPlan {
  monthly,      // Suscripción mensual
  annual,       // Suscripción anual
}

class MembershipSubscription {
  final String id;
  final String userId;
  final MembershipStatus status;
  final MembershipPlan? plan;
  final String? stripeSubscriptionId;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? canceledAt;
  final double monthlyPrice;
  final double annualPrice;
  final String currency;
  final bool autoRenew;

  MembershipSubscription({
    required this.id,
    required this.userId,
    this.status = MembershipStatus.basic,
    this.plan,
    this.stripeSubscriptionId,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.canceledAt,
    this.monthlyPrice = 9.99,
    this.annualPrice = 99.99,
    this.currency = 'EUR',
    this.autoRenew = true,
  });

  /// Verifica si el usuario es PRO activo
  bool get isProActive {
    if (status != MembershipStatus.pro) return false;
    if (endDate != null && endDate!.isBefore(DateTime.now())) return false;
    return true;
  }

  /// Verifica si la suscripción está próxima a vencer (7 días)
  bool get isExpiringsoon {
    if (endDate == null) return false;
    final daysUntilExpiry = endDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  /// Días restantes hasta expiry
  int get daysRemaining {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'status': status.toString().split('.').last,
      'plan': plan?.toString().split('.').last,
      'stripeSubscriptionId': stripeSubscriptionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'canceledAt': canceledAt != null ? Timestamp.fromDate(canceledAt!) : null,
      'monthlyPrice': monthlyPrice,
      'annualPrice': annualPrice,
      'currency': currency,
      'autoRenew': autoRenew,
    };
  }

  factory MembershipSubscription.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return MembershipSubscription(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      status: _parseStatus(data['status']),
      plan: data['plan'] != null ? _parsePlan(data['plan']) : null,
      stripeSubscriptionId: data['stripeSubscriptionId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null,
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      canceledAt: data['canceledAt'] != null ? (data['canceledAt'] as Timestamp).toDate() : null,
      monthlyPrice: (data['monthlyPrice'] ?? 9.99).toDouble(),
      annualPrice: (data['annualPrice'] ?? 99.99).toDouble(),
      currency: data['currency'] ?? 'EUR',
      autoRenew: data['autoRenew'] ?? true,
    );
  }

  static MembershipStatus _parseStatus(String? status) {
    switch (status) {
      case 'pro':
        return MembershipStatus.pro;
      case 'canceled':
        return MembershipStatus.canceled;
      case 'expired':
        return MembershipStatus.expired;
      default:
        return MembershipStatus.basic;
    }
  }

  static MembershipPlan _parsePlan(String? plan) {
    switch (plan) {
      case 'annual':
        return MembershipPlan.annual;
      default:
        return MembershipPlan.monthly;
    }
  }

  MembershipSubscription copyWith({
    String? id,
    String? userId,
    MembershipStatus? status,
    MembershipPlan? plan,
    String? stripeSubscriptionId,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? canceledAt,
    double? monthlyPrice,
    double? annualPrice,
    String? currency,
    bool? autoRenew,
  }) {
    return MembershipSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      plan: plan ?? this.plan,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      canceledAt: canceledAt ?? this.canceledAt,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      annualPrice: annualPrice ?? this.annualPrice,
      currency: currency ?? this.currency,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}
