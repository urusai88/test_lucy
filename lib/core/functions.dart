String formatPrice(String price) {
  final parts = price.split('.');

  if (parts[1] == '00') {
    return parts[0];
  } else {
    return price;
  }
}
