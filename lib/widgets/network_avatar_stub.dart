import 'package:material_ui/material_ui.dart';

Widget buildPlatformNetworkImage({
  required String url,
  required double size,
  required Widget fallback,
}) {
  return Image.network(
    url,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => fallback,
  );
}
