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
