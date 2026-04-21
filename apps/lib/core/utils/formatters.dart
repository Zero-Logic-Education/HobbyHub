String formatEventPrice(double price, bool isFree) {
  if (isFree || price <= 0) {
    return 'Бесплатно';
  }

  final hasFraction = price % 1 != 0;
  return '${price.toStringAsFixed(hasFraction ? 2 : 0)} ₸';
}