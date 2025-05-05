import 'package:intl/intl.dart';

class Voucher {
  final int id;
  final String code;
  final double discountValue;
  final String discountType;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final int usedCount;
  final String status;
  final bool isUsed;

  Voucher({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.discountType,
    this.minOrderValue,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    required this.usedCount,
    required this.status,
    required this.isUsed,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    print('Parsing voucher from JSON: $json');
    final now = DateTime.now();
    final startDate = json['start_date'] != null
        ? DateTime.parse(json['start_date'])
        : null;
    final endDate = json['end_date'] != null
        ? DateTime.parse(json['end_date'])
        : null;
    final usageLimit = json['usage_limit'] as int?;
    final usedCount = json['used_count'] ?? 0;

    // Kiểm tra voucher có khả dụng không
    bool isUsable = json['status'] == 'active' &&
        !json['is_used'] &&
        (startDate == null || startDate.isBefore(now)) &&
        (endDate == null || endDate.isAfter(now)) &&
        (usageLimit == null || usedCount < usageLimit);

    final voucher = Voucher(
      id: json['id'],
      code: json['code'],
      discountValue: double.parse(json['discount_value'].toString()),
      discountType: json['discount_type'],
      minOrderValue: json['min_order_value'] != null
          ? double.parse(json['min_order_value'].toString())
          : null,
      maxDiscount: json['max_discount'] != null
          ? double.parse(json['max_discount'].toString())
          : null,
      startDate: startDate,
      endDate: endDate,
      usageLimit: usageLimit,
      usedCount: usedCount,
      status: json['status'],
      isUsed: json['is_used'] ?? false,
    );
    print('Parsed voucher: $voucher');
    return voucher;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_value': discountValue,
      'discount_type': discountType,
      'min_order_value': minOrderValue,
      'max_discount': maxDiscount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'status': status,
      'is_used': isUsed,
    };
  }

  // Kiểm tra xem voucher có khả dụng hay không
  bool get isUsable {
    final now = DateTime.now();
    return status == 'active' &&
        !isUsed &&
        (startDate == null || startDate!.isBefore(now)) &&
        (endDate == null || endDate!.isAfter(now)) &&
        (usageLimit == null || usedCount < usageLimit!);
  }

  @override
  String toString() {
    return 'Voucher(id: $id, code: $code, discountValue: $discountValue, discountType: $discountType, isUsable: $isUsable)';
  }

  String getFormattedDiscount() {
    if (discountType == 'percentage') {
      return '${discountValue}%';
    } else {
      return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(discountValue);
    }
  }

  String getFormattedMinOrderValue() {
    return minOrderValue != null
        ? NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(minOrderValue)
        : 'Không yêu cầu';
  }

  String getFormattedMaxDiscount() {
    return maxDiscount != null
        ? NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(maxDiscount)
        : 'Không giới hạn';
  }

  String getFormattedDateRange() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    if (startDate == null && endDate == null) {
      return 'Không thời hạn';
    }
    return '${startDate != null ? dateFormat.format(startDate!) : 'N/A'} - '
        '${endDate != null ? dateFormat.format(endDate!) : 'N/A'}';
  }
}