import 'dart:ui_web' as ui_web;
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;

Widget buildPlatformNetworkImage({
  required String url,
  required double size,
  required Widget fallback,
}) {
  return _WebAvatarImage(url: url, size: size, fallback: fallback);
}

class _WebAvatarImage extends StatefulWidget {
  final String url;
  final double size;
  final Widget fallback;

  const _WebAvatarImage({
    required this.url,
    required this.size,
    required this.fallback,
  });

  @override
  State<_WebAvatarImage> createState() => _WebAvatarImageState();
}

class _WebAvatarImageState extends State<_WebAvatarImage> {
  late String _viewType;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant _WebAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasError = false;
      _registerView();
    }
  }

  void _registerView() {
    _viewType =
        'avatar-img-${widget.url.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final img = web.document.createElement('img') as web.HTMLImageElement;
      img.src = widget.url;
      img.style.width = '100%';
      img.style.height = '100%';
      img.style.objectFit = 'cover';
      img.style.borderRadius = '50%';
      img.style.display = 'block';
      img.onError.listen((_) {
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
      return img;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return widget.fallback;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
