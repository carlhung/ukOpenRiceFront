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
  final String phone;
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
  final String extraInfo;

  ResturantInfo({
    required this.restuarantChineseName,
    required this.restuarantEnglishName,
    required this.cuisine,
    required this.description,
    required this.address,
    required this.phone,
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
    required this.selectedPayments,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotEmpty(String key, String value) {
      if (value.isNotEmpty) data[key] = value;
    }

    addIfNotEmpty('restuarantChineseName', restuarantChineseName);
    addIfNotEmpty('restuarantEnglishName', restuarantEnglishName);
    addIfNotEmpty('cuisine', cuisine);
    addIfNotEmpty('description', description);
    addIfNotEmpty('address', address);
    addIfNotEmpty('phone', phone);
    addIfNotEmpty('web', web);
    addIfNotEmpty('facebook', facebook);
    addIfNotEmpty('instagram', instagram);
    addIfNotEmpty('email', email);
    addIfNotEmpty('openingHours', openingHours);
    addIfNotEmpty('priceRange', priceRange);
    addIfNotEmpty('extraInfo', extraInfo);

    data['accessReservation'] = accessReservation;
    data['selectedPayments'] = selectedPayments.map((p) => p.name).toList();
    data['takeaway'] = takeaway;
    data['delivery'] = delivery;

    return data;
  }
}
