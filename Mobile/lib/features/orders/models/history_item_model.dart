/// Kategori transaksi riwayat untuk filter & tampilan card.
enum HistoryType {
  setor,
  pencairan,
  bonus,
  penukaran,
}

/// Filter chip pada tab History.
enum HistoryFilter {
  semua,
  setorSampah,
  pencairanSaldo,
  bonus,
  penukaran,
}

extension HistoryFilterExtension on HistoryFilter {
  String get label {
    switch (this) {
      case HistoryFilter.semua:
        return 'Semua';
      case HistoryFilter.setorSampah:
        return 'Penjemputan';
      case HistoryFilter.pencairanSaldo:
        return 'Tukar Poin';
      case HistoryFilter.bonus:
        return 'Bonus';
      case HistoryFilter.penukaran:
        return 'Penukaran';
    }
  }

  HistoryType? get typeFilter {
    switch (this) {
      case HistoryFilter.semua:
        return null;
      case HistoryFilter.setorSampah:
        return HistoryType.setor;
      case HistoryFilter.pencairanSaldo:
        return HistoryType.pencairan;
      case HistoryFilter.bonus:
        return HistoryType.bonus;
      case HistoryFilter.penukaran:
        return HistoryType.penukaran;
    }
  }
}

class HistoryItemModel {
  final String id;
  final String title;
  final String date;
  final String points;
  final HistoryType type;
  final String? weight;
  final String? statusLabel;
  final String? destination;
  final String? provider;
  final String? accountNumber;
  final String? accountName;
  final double? estimatedAmount;
  final String? adminNote;
  final String? rawStatus;
  final String? transactionCode;
  final String? transferProof;
  final String? rejectionReason;

  const HistoryItemModel({
    required this.id,
    required this.title,
    required this.date,
    required this.points,
    required this.type,
    this.weight,
    this.statusLabel,
    this.destination,
    this.provider,
    this.accountNumber,
    this.accountName,
    this.estimatedAmount,
    this.adminNote,
    this.rawStatus,
    this.transactionCode,
    this.transferProof,
    this.rejectionReason,
  });
}
