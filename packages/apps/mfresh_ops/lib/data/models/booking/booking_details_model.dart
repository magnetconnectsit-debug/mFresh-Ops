// region Imports
// endregion

// region Models
class BookingDetailsModel {
  final String bookingId;
  final String unitNo;
  final String bookingTimeDate;
  final String unitLocation;
  final String totalAmount;
  final String serviceIcon;
  final String fullAddress;
  final List<BookingServiceDetailItem> services;
  final int paymentMode;
  final String paymentStatus;
  final String? encryptBookingId;
  final String? phone;
  final String? addPhone;

  BookingDetailsModel({
    this.bookingId = '',
    this.unitNo = '',
    this.bookingTimeDate = '',
    this.unitLocation = '',
    this.totalAmount = '',
    this.serviceIcon = '',
    this.fullAddress = '',
    this.services = const [],
    this.paymentMode = 0,
    this.paymentStatus = '',
    this.encryptBookingId,
    this.phone,
    this.addPhone,
  });

  String get displayAddress {
    if (fullAddress.trim().isNotEmpty) return fullAddress.trim();
    if (unitLocation.trim().isNotEmpty) return unitLocation.trim();
    return 'Location not specified';
  }

  // region Price Calculation Helpers
  /// Calculates the individual unit price for a single quantity of the given service.
  /// Reconciles whether [service.price] represents line total or unit price based on
  /// booking total and overall services configuration.
  double getUnitPriceForService(BookingServiceDetailItem service) {
    final double? total = double.tryParse(totalAmount.trim());
    return service.getEffectiveUnitPrice(
      bookingTotal: total,
      allServices: services,
    );
  }

  /// Returns a clean formatted string for the individual service unit price (e.g. "10" or "10.50").
  String getFormattedUnitPriceForService(BookingServiceDetailItem service) {
    final unitPrice = getUnitPriceForService(service);
    if (unitPrice == unitPrice.roundToDouble()) {
      return unitPrice.toInt().toString();
    }
    return unitPrice.toStringAsFixed(2);
  }
  // endregion

  // region CopyWith
  BookingDetailsModel copyWith({
    String? bookingId,
    String? unitNo,
    String? bookingTimeDate,
    String? unitLocation,
    String? totalAmount,
    String? serviceIcon,
    String? fullAddress,
    List<BookingServiceDetailItem>? services,
    int? paymentMode,
    String? paymentStatus,
    String? encryptBookingId,
    String? phone,
    String? addPhone,
  }) {
    return BookingDetailsModel(
      bookingId: bookingId ?? this.bookingId,
      unitNo: unitNo ?? this.unitNo,
      bookingTimeDate: bookingTimeDate ?? this.bookingTimeDate,
      unitLocation: unitLocation ?? this.unitLocation,
      totalAmount: totalAmount ?? this.totalAmount,
      serviceIcon: serviceIcon ?? this.serviceIcon,
      fullAddress: fullAddress ?? this.fullAddress,
      services: services ?? this.services,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      encryptBookingId: encryptBookingId ?? this.encryptBookingId,
      phone: phone ?? this.phone,
      addPhone: addPhone ?? this.addPhone,
    );
  }
  // endregion

  // region Factory & Serialization
  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailsModel(
      bookingId: json['booking_id']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      bookingTimeDate: json['booking_time_date']?.toString() ?? '',
      unitLocation: (json['unit_location'] ??
              json['Unit_location'] ??
              json['location'] ??
              json['full_add'] ??
              '')
          .toString(),
      totalAmount: json['total_amount']?.toString() ?? '',
      serviceIcon: json['service_icon']?.toString() ?? '',
      fullAddress: (json['fullAddress'] ??
              json['full_address'] ??
              json['unit_location'] ??
              json['Unit_location'] ??
              json['location'] ??
              json['address'] ??
              '')
          .toString(),
      services: json['services'] != null
          ? List<BookingServiceDetailItem>.from(
              json['services'].map((service) => BookingServiceDetailItem.fromJson(service)),
            )
          : [],
      paymentMode: int.tryParse(json['payment_mode']?.toString() ?? '') ?? 0,
      paymentStatus: json['payment_status']?.toString() ?? json['Payment_status']?.toString() ?? '',
      encryptBookingId: json['encrypt_booking_id']?.toString(),
      phone: json['phone_no']?.toString() ??
          json['phone']?.toString() ??
          json['mobile_no']?.toString(),
      addPhone: json['add_phone_no']?.toString() ??
          json['Add_phone_no']?.toString() ??
          json['add_phone']?.toString(),
    );
  }
  // endregion
}

class BookingServiceDetailItem {
  final String servicesName;
  final String quantity;
  final String price;
  final String? unitPrice;
  final String? lineTotal;

  BookingServiceDetailItem({
    this.servicesName = '',
    this.quantity = '',
    this.price = '',
    this.unitPrice,
    this.lineTotal,
  });

  // region Price Calculation Helpers
  /// Returns the effective price for a single unit of this service.
  double getEffectiveUnitPrice({
    double? bookingTotal,
    List<BookingServiceDetailItem>? allServices,
  }) {
    int qty = int.tryParse(quantity.toString()) ?? 1;
    if (qty <= 0) qty = 1;

    // 1. Explicit unit price check if provided directly
    if (unitPrice != null && unitPrice!.trim().isNotEmpty) {
      final double? parsedUnit = double.tryParse(unitPrice!.trim());
      if (parsedUnit != null && parsedUnit > 0) {
        return parsedUnit;
      }
    }

    final double parsedPrice = double.tryParse(price.trim()) ?? 0.0;
    final double? parsedLineTotal =
        lineTotal != null && lineTotal!.trim().isNotEmpty ? double.tryParse(lineTotal!.trim()) : null;

    // 2. If quantity is 1, price is already unit price
    if (qty == 1) {
      if (parsedPrice > 0) return parsedPrice;
      if (parsedLineTotal != null && parsedLineTotal > 0) return parsedLineTotal;
      if (bookingTotal != null &&
          bookingTotal > 0 &&
          (allServices == null || allServices.length <= 1)) {
        return bookingTotal;
      }
      return 0.0;
    }

    // 3. For quantity > 1:
    // If lineTotal was explicitly parsed and differs from price
    if (parsedLineTotal != null && parsedLineTotal > 0) {
      if (parsedPrice > 0 && (parsedPrice * qty - parsedLineTotal).abs() < 0.05) {
        return parsedPrice;
      }
      if ((parsedPrice - parsedLineTotal).abs() < 0.05) {
        return parsedLineTotal / qty;
      }
    }

    // Check with bookingTotal and allServices context
    if (bookingTotal != null && bookingTotal > 0) {
      // Single service booking: line total MUST equal bookingTotal
      if (allServices == null || allServices.length <= 1) {
        // If parsedPrice == bookingTotal, then parsedPrice is line total!
        if ((parsedPrice - bookingTotal).abs() < 0.05) {
          return bookingTotal / qty;
        }
        // If parsedPrice * qty == bookingTotal, parsedPrice is already unit price!
        if ((parsedPrice * qty - bookingTotal).abs() < 0.05) {
          return parsedPrice;
        }
        // If multiplying parsedPrice * qty exceeds bookingTotal, parsedPrice cannot be unit price
        if (parsedPrice * qty > bookingTotal * 1.05) {
          return parsedPrice / qty;
        }
        // If parsedPrice is 0 or empty, unit price is bookingTotal / qty
        if (parsedPrice <= 0) {
          return bookingTotal / qty;
        }
      } else {
        // Multiple services booking:
        double sumRawPrices = 0.0;
        double sumMultipliedPrices = 0.0;
        for (var s in allServices) {
          final double p = double.tryParse(s.price.trim()) ?? 0.0;
          final int q = int.tryParse(s.quantity.toString()) ?? 1;
          sumRawPrices += p;
          sumMultipliedPrices += (p * (q > 0 ? q : 1));
        }

        if ((sumRawPrices - bookingTotal).abs() < 0.05 &&
            (sumMultipliedPrices - bookingTotal).abs() > 0.05) {
          // All raw prices in JSON were line totals!
          return parsedPrice / qty;
        } else if ((sumMultipliedPrices - bookingTotal).abs() < 0.05) {
          // All raw prices were already unit prices!
          return parsedPrice;
        }

        // If multiplying parsedPrice * qty exceeds bookingTotal, it must be line total
        if (parsedPrice * qty > bookingTotal * 1.05) {
          return parsedPrice / qty;
        }
      }
    }

    // Fallback: check if lineTotal equals parsedPrice
    if (parsedPrice > 0) {
      if (parsedLineTotal != null && (parsedLineTotal - parsedPrice).abs() < 0.05) {
        return parsedPrice / qty;
      }
      return parsedPrice;
    }

    return 0.0;
  }

  /// Self-formatted unit price helper
  String get formattedUnitPrice {
    final double p = double.tryParse(price.trim()) ?? 0.0;
    final int q = int.tryParse(quantity.toString()) ?? 1;
    double eff = p;
    if (q > 1 && p > 0) {
      if (unitPrice != null && unitPrice!.trim().isNotEmpty) {
        final double? u = double.tryParse(unitPrice!.trim());
        if (u != null && u > 0) eff = u;
      } else if (lineTotal != null &&
          lineTotal!.trim().isNotEmpty &&
          (double.tryParse(lineTotal!.trim()) ?? 0.0) == p) {
        eff = p / q;
      }
    }
    if (eff == eff.roundToDouble()) {
      return eff.toInt().toString();
    }
    return eff.toStringAsFixed(2);
  }
  // endregion

  // region CopyWith
  BookingServiceDetailItem copyWith({
    String? servicesName,
    String? quantity,
    String? price,
    String? unitPrice,
    String? lineTotal,
  }) {
    return BookingServiceDetailItem(
      servicesName: servicesName ?? this.servicesName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
  // endregion

  // region Factory & Serialization
  factory BookingServiceDetailItem.fromJson(Map<String, dynamic> json) {
    final String qtyStr = (json['quantity'] ??
            json['service_quantity'] ??
            json['Quantity'] ??
            json['service_qty'] ??
            '1')
        .toString();

    final dynamic rawUnitPrice = json['unit_price'] ??
        json['unitPrice'] ??
        json['unit_rate'] ??
        json['rate'] ??
        json['Rate'];

    final dynamic rawTotalPrice = json['total_price'] ??
        json['Total_price'] ??
        json['line_total'] ??
        json['total_amount'];

    final dynamic rawPrice = json['price'] ??
        json['Price'] ??
        json['amount'] ??
        json['Amount'] ??
        json['service_price'] ??
        json['Service_Price'] ??
        rawUnitPrice ??
        rawTotalPrice;

    final String resolvedPrice = (rawPrice ?? '').toString();
    final String? resolvedUnitPrice = rawUnitPrice?.toString();
    final String? resolvedLineTotal = rawTotalPrice?.toString();

    return BookingServiceDetailItem(
      servicesName: (json['services_name'] ??
              json['Service_Name'] ??
              json['service_name'] ??
              json['serviceName'] ??
              json['name'] ??
              json['Service_name'] ??
              '')
          .toString(),
      quantity: qtyStr,
      price: resolvedPrice,
      unitPrice: resolvedUnitPrice,
      lineTotal: resolvedLineTotal,
    );
  }
  // endregion
}

/// Backward compatibility alias
typedef ServiceDetailItem = BookingServiceDetailItem;
// endregion
