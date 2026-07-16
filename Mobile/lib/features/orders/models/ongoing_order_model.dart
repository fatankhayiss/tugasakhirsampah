import 'package:flutter/material.dart';

enum OngoingStatus {
  pending,
  processing,
  pickup,
  verifying,
}

extension OngoingStatusExtension on OngoingStatus {
  String get label {
    switch (this) {
      case OngoingStatus.pending:
        return 'Menunggu';
      case OngoingStatus.processing:
        return 'Diproses';
      case OngoingStatus.pickup:
        return 'Pickup';
      case OngoingStatus.verifying:
        return 'Verifikasi';
    }
  }

  Color get badgeBackground {
    switch (this) {
      case OngoingStatus.pending:
        return const Color(0xFFEAF8EF); // Soft green
      case OngoingStatus.processing:
      case OngoingStatus.pickup:
      case OngoingStatus.verifying:
        return const Color(0xFFDDF8E7); // Emerald green background for active states
    }
  }

  Color get badgeText {
    switch (this) {
      case OngoingStatus.pending:
        return const Color(0xFF16A34A); // Medium green text
      case OngoingStatus.processing:
      case OngoingStatus.pickup:
      case OngoingStatus.verifying:
        return const Color(0xFF15803D); // Deeper green text
    }
  }
}

class OngoingOrderModel {
  final String id;
  final String title;
  final String date;
  final String subtitle;
  final OngoingStatus status;
  final String? estimatedPoints;
  final String? driverName;
  final bool isRedemption;
  final String? destination;
  final String? provider;
  final String? accountNumber;
  final String? accountName;
  final double? estimatedAmount;
  final String? rawStatus;

  const OngoingOrderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.status,
    this.estimatedPoints,
    this.driverName,
    this.isRedemption = false,
    this.destination,
    this.provider,
    this.accountNumber,
    this.accountName,
    this.estimatedAmount,
    this.rawStatus,
  });
}
