import 'package:intl/intl.dart';

class FeesModel {
  final double entrance;
  final double tuition;
  final double misc;
  final double books;
  final double watchman;
  final double aircon;
  final double others;

  FeesModel({
    required this.entrance,
    required this.tuition,
    required this.misc,
    required this.books,
    required this.watchman,
    required this.aircon,
    required this.others,
  });

  double total() {
    return entrance + tuition + misc + books + watchman + aircon + others;
  }

  String totalFormatted({bool pesoSign = true}) {
    return '${pesoSign ? 'P' : ''}${NumberFormat('#,###').format(total())}';
  }

  FeesModel copyWith({
    final double? entrance,
    final double? tuition,
    final double? misc,
    final double? books,
    final double? watchman,
    final double? aircon,
    final double? others,
  }) {
    return FeesModel(
      entrance: entrance ?? this.entrance,
      tuition: tuition ?? this.tuition,
      misc: misc ?? this.misc,
      books: books ?? this.books,
      watchman: watchman ?? this.watchman,
      aircon: aircon ?? this.aircon,
      others: others ?? this.others,
    );
  }

  factory FeesModel.fromMap(Map<String, dynamic> data) {
    return FeesModel(
      entrance: data['entrance'] != null ? data['entrance'].toDouble() : 0.0,
      tuition: data['tuition'] != null ? data['tuition'].toDouble() : 0.0,
      misc: data['misc'] != null ? data['misc'].toDouble() : 0.0,
      books: data['books'] != null ? data['books'].toDouble() : 0.0,
      watchman: data['watchman'] != null ? data['watchman'].toDouble() : 0.0,
      aircon: data['aircon'] != null ? data['aircon'].toDouble() : 0.0,
      others: data['others'] != null ? data['others'].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entrance': entrance,
      'tuition': tuition,
      'misc': misc,
      'books': books,
      'watchman': watchman,
      'aircon': aircon,
      'others': others,
    };
  }
}

enum FeeType {
  entrance,
  tuition,
  misc,
  books,
  watchman,
  aircon,
  others,
}

extension FeeStrings on FeeType {
  String firstLetter() => name[0];
  String formalName() => '${name[0].toUpperCase()}${name.substring(1)}';
}
