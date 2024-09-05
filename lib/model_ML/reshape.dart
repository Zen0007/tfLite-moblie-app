List<List<T>> reshape<T>(
    {required List<List<T>> list, required int col, required int row}) {
  List<T> flatten = list
      .expand(
        (element) => element,
      )
      .toList();

  int requiredSize = col * row;

  if (flatten.length > requiredSize) {
    flatten = flatten.sublist(0, requiredSize);
  } else if (flatten.length < requiredSize) {
    flatten.addAll(List.filled(requiredSize - flatten.length, 1.000 as T));
  }

  List<List<T>> results = [];
  for (var i = 0; i < row; i++) {
    results.add(flatten.sublist(i * col, (i + 1) * col));
  }
  return results;
}
