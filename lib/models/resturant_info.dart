import 'dart:convert';

final class Payment {
  final String name;

  Payment({required this.name});

  static final otherPayment = Payment(name: 'Other');

  static Set<Payment> allPayments = {
    Payment(name: 'Cash'),
    Payment(name: 'WeChat Pay'),
    Payment(name: 'Visa Card'),
    Payment(name: 'MasterCard'),
    Payment(name: 'American Express'),
    Payment(name: 'Debit Card'),
    Payment(name: 'PayPal'),
    Payment(name: 'Apple Pay'),
    Payment(name: 'Google Pay'),
    // otherPayment,
  };
}

final class Cuisine {
  final String name;

  Cuisine({required this.name});

  static final otherCuisine = Cuisine(name: 'Other');

  static Set<Cuisine> allCuisines = {
    Cuisine(name: 'Chinese'),
    Cuisine(name: 'Italian'),
    Cuisine(name: 'Mexican'),
    Cuisine(name: 'Indian'),
    Cuisine(name: "Cantonese"),
    Cuisine(name: 'Japanese'),
    Cuisine(name: 'Korean'),
    Cuisine(name: 'Indian'),
    Cuisine(name: 'Thai'),
    Cuisine(name: 'Italian'),
    Cuisine(name: 'French'),
    Cuisine(name: 'Mexican'),
    Cuisine(name: 'American'),
    Cuisine(name: 'Spanish'),
    Cuisine(name: 'Vietnamese'),
    Cuisine(name: 'Mediterranean'),
    Cuisine(name: 'Middle Eastern'),
    Cuisine(name: 'Greek'),
    Cuisine(name: 'Turkish'),
    Cuisine(name: 'British'),
    Cuisine(name: 'German'),
    Cuisine(name: 'Russian'),
    Cuisine(name: 'Brazilian'),
    Cuisine(name: 'Caribbean'),
    Cuisine(name: 'African'),
    Cuisine(name: 'Australian'),
    Cuisine(name: 'Fusion'),
    otherCuisine,
  };
}

final class ResturantInfo {
  final String restuarantChineseName;
  final String restuarantEnglishName;
  final String cuisine;
  final String description;
  final String address;
  final String city;
  final String phone;
  final String map;
  final String web;
  final String facebook;
  final String instagram;
  final String email;
  final String openingHours;
  final bool accessReservation;
  Set<Payment> selectedPayments;
  final bool takeaway;
  final bool delivery;
  final String priceRange;
  final String currencyCode;
  final String extraInfo;
  final String timezone;
  List<OpeningHour> returnedOpeningHours;
  List<String> originalImages;
  List<String> thumbnilImages;

  ResturantInfo({
    required this.restuarantChineseName,
    required this.restuarantEnglishName,
    required this.cuisine,
    required this.description,
    required this.address,
    required this.city,
    required this.phone,
    required this.map,
    required this.web,
    required this.facebook,
    required this.instagram,
    required this.email,
    required this.openingHours,
    required this.priceRange,
    required this.extraInfo,
    required this.accessReservation,
    required this.takeaway,
    required this.delivery,
    required this.currencyCode,
    required this.selectedPayments,
    required this.timezone,
    this.returnedOpeningHours = const [],
    this.originalImages = const [],
    this.thumbnilImages = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotEmpty(String key, String value) {
      if (value.isNotEmpty) data[key] = value.trim();
    }

    addIfNotEmpty('restuarantChineseName', restuarantChineseName);
    addIfNotEmpty('restuarantEnglishName', restuarantEnglishName);
    addIfNotEmpty('cuisine', cuisine);
    addIfNotEmpty('description', description);
    addIfNotEmpty('address', address);
    addIfNotEmpty('city', city);
    addIfNotEmpty('phone', phone);
    addIfNotEmpty('web', web);
    addIfNotEmpty('map', map);
    addIfNotEmpty('facebook', facebook);
    addIfNotEmpty('instagram', instagram);
    addIfNotEmpty('email', email);
    addIfNotEmpty('openingHours', openingHours);
    addIfNotEmpty('priceRange', priceRange);
    addIfNotEmpty('currencyCode', currencyCode);
    addIfNotEmpty('extraInfo', extraInfo);
    addIfNotEmpty('timezone', timezone);

    data['accessReservation'] = accessReservation;
    data['selectedPayments'] = selectedPayments
        .map((p) => p.name.trim())
        .toList();
    data['takeaway'] = takeaway;
    data['delivery'] = delivery;

    return data;
  }

  factory ResturantInfo.fromJson(Map<String, dynamic> json) {
    return ResturantInfo(
      restuarantEnglishName: json['english_name'] ?? "",
      restuarantChineseName: json['chinese_name'] ?? "",
      cuisine: json['cuisine'] ?? "",
      description: json['description'] ?? "",
      address: json['address'] ?? "",
      city: json['city'] ?? "",
      phone: json['phone'] ?? "",
      map: json['map'] ?? "",
      web: json['web'] ?? "",
      facebook: json['facebook'] ?? "",
      instagram: json['instagram'] ?? "",
      email: json['email'] ?? "",
      accessReservation:
          json['access_reservation'] == 1 || json['access_reservation'] == true,
      selectedPayments: json['selected_payments'],
      takeaway: json['takeaway'] == 1 || json['takeaway'] == true,
      delivery: json['delivery'] == 1 || json['delivery'] == true,
      priceRange: json['price_range'] ?? "",
      currencyCode: json['currency_code'] ?? "",
      extraInfo: json['extraInfo'] ?? "",
      openingHours: '',
      timezone: '',
      returnedOpeningHours: (json['returnOpeningHours'] as List)
          .map((hour) => OpeningHour.fromJson(hour as Map<String, dynamic>))
          .toList(),
      originalImages: List<String>.from(json['original_images'] as List),
      thumbnilImages: List<String>.from(json['thumbnil_images'] as List),
    );
  }
}

class OpeningHour {
  final String dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isUtcFormat;
  final String timezone;

  OpeningHour({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isUtcFormat,
    required this.timezone,
  });

  factory OpeningHour.fromJson(Map<String, dynamic> json) {
    return OpeningHour(
      dayOfWeek: json['day_of_week'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isUtcFormat: json['is_utc_format'],
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
      'is_utc_format': isUtcFormat,
      'timezone': timezone,
    };
  }
}

List<OpeningHour> decodeOpeningHours(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded.map((item) => OpeningHour.fromJson(item)).toList();
}

List<OpeningHour> openingHoursFromList(List<dynamic> jsonList) {
  return jsonList.map((item) => OpeningHour.fromJson(item)).toList();
}

// String jsonString = '''[
//   {"day_of_week": "monday", "open_time": "9:00:00", "close_time": "17:00:00", "is_utc_format": false, "timezone": "Europe/London"},
//   {"day_of_week": "wednesday", "open_time": "9:00:00", "close_time": "17:00:00", "is_utc_format": false, "timezone": "Europe/London"}
// ]''';

// List<OpeningHour> hours = decodeOpeningHours(jsonString);

// for (var hour in hours) {
//   print('${hour.dayOfWeek}: ${hour.openTime} - ${hour.closeTime}');
// }
