/// Model for dominant colors
class DominantColor {
  final String hex;
  final int pixelFraction;

  DominantColor({
    required this.hex,
    required this.pixelFraction,
  });

  factory DominantColor.fromJson(Map<String, dynamic> json) {
    return DominantColor(
      hex: json['hex'] ?? '#000000',
      pixelFraction: json['pixelFraction'] ?? 0,
    );
  }
}