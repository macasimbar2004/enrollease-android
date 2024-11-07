import 'package:enrollease/model/address_model.dart';

final List<Province> provinces = [
  Province('Misamis Occidental', [
    City(
        'Oroquieta City',
        [
          Barangay('Mobod', '7207'),
          Barangay('Taboc Norte', '7207'),
        ],
        '7207'),
    City(
        'Ozamiz City',
        [
          Barangay('Baybay Santa Cruz', '7200'),
          Barangay('Baybay Triunfo', '7200'),
        ],
        '7200'),
  ]),
  Province('Cebu', [
    City(
        'Cebu City',
        [
          Barangay('Barangay Luz', '6000'),
          Barangay('Barangay Labangon', '6000'),
        ],
        '6000'),
    City(
        'Mandaue City',
        [
          Barangay('Barangay Basak', '6014'),
          Barangay('Barangay Tipolo', '6014'),
        ],
        '6014'),
  ]),
];
