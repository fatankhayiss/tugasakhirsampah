// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field`nimport 'package:flutter/material.dart';

enum OngoingStatus {
  pending,
  processing,
  pickup,
  verifying,
  redeemProcessing,
}

extension OngoingStatusExtension on OngoingStatus {
  String get label {
    switch (this) {
      case OngoingStatus.pending:
        return 'Menunggu Konfirmasi';
      case OngoingStatus.processing:
        return 'Picker Ditugaskan';
      case OngoingStatus.pickup:
        return 'Picker Menuju Lokasi';
      case OngoingStatus.verifying:
        return 'Validasi Bank Sampah';
      case OngoingStatus.redeemProcessing:
        return 'Pencairan Diproses';
    }
  }

  Color get badgeBackground {
    switch (this) {
      case OngoingStatus.pending:
        return const Color(0xFFFEF3C7);
      case OngoingStatus.processing:
      case OngoingStatus.pickup:
      case OngoingStatus.redeemProcessing:
        return const Color(0xFFEFF6FF);
      case OngoingStatus.verifying:
        return const Color(0xFFF3E8FF);
    }
  }

  Color get badgeText {
    switch (this) {
      case OngoingStatus.pending:
        return const Color(0xFFD97706);
      case OngoingStatus.processing:
      case OngoingStatus.pickup:
      case OngoingStatus.redeemProcessing:
        return const Color(0xFF3B82F6);
      case OngoingStatus.verifying:
        return const Color(0xFF9333EA);
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
  final String? transactionCode;
  final String? adminNote;

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
    this.transactionCode,
    this.adminNote,
  });
}
