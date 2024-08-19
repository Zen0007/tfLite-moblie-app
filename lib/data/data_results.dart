class Results {
  final double open;
  final double close;

  Results({
    required this.open,
    required this.close,
  });

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        open: (json['o'] as num).toDouble(),
        close: (json['c'] as num).toDouble(),
      );
}
