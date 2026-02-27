class User {
  final int id;
  final String email;
  final String username;
  final Name name;
  final Address address;
  final String phone;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      name: Name.fromMap(map['name']),
      address: Address.fromMap(map['address']),
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name.toMap(),
      'address': address.toMap(),
      'phone': phone,
    };
  }

  String get fullName => "${name.firstName} ${name.lastName}";
}

class Name {
  final String firstName;
  final String lastName;

  Name({required this.firstName, required this.lastName});

  factory Name.fromMap(Map<String, dynamic> map) {
    return Name(firstName: map['firstname'], lastName: map['lastname']);
  }

  Map<String, dynamic> toMap() {
    return {'firstname': firstName, 'lastname': lastName};
  }
}

class Address {
  final String city;
  final String street;
  final int number;
  final String zipcode;
  final GeoLocation geolocation;

  Address({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
    required this.geolocation,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      city: map['city'],
      street: map['street'],
      number: map['number'],
      zipcode: map['zipcode'],
      geolocation: GeoLocation.fromMap(map['geolocation']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'street': street,
      'number': number,
      'zipcode': zipcode,
      'geolocation': geolocation.toMap(),
    };
  }
}

class GeoLocation {
  final String lat;
  final String long;

  GeoLocation({required this.lat, required this.long});

  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(lat: map['lat'], long: map['long']);
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'long': long};
  }
}
