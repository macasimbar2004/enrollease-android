class Barangay {
  final String name;
  final String zipCode;

  Barangay(this.name, this.zipCode);
}

class City {
  final String name;
  final List<Barangay> barangays;
  final String zipCode;

  City(this.name, this.barangays, this.zipCode);
}

class Province {
  final String name;
  final List<City> cities;

  Province(this.name, this.cities);
}
