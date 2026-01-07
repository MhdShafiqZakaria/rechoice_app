import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final int starCount;
  final double size;
  final bool isInteractive;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starCount = 5,
    this.size = 32,
    this.isInteractive = true,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _currentRating;
  late double _hoverRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _hoverRating = _currentRating;
  }

  void _setRating(double rating) {
    setState(() {
      _currentRating = rating;
      _hoverRating = rating;
    });
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        final starValue = index + 1.0;
        final isFilled = starValue <= _hoverRating;
        final isHalf = _hoverRating > index && _hoverRating < starValue;

        return GestureDetector(
          onTap: widget.isInteractive ? () => _setRating(starValue) : null,
          onHorizontalDragUpdate: widget.isInteractive
              ? (DragUpdateDetails details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final starWidth = box.size.width / widget.starCount;
                  final newRating =
                      ((localPosition.dx / starWidth) + 1).clamp(1.0, widget.starCount.toDouble()) as double;
                  setState(() {
                    _hoverRating = newRating;
                  });
                }
              : null,
          onHorizontalDragEnd: widget.isInteractive
              ? (_) => _setRating(_hoverRating.roundToDouble())
              : null,
          child: MouseRegion(
            onEnter: widget.isInteractive
                ? (_) {
                    setState(() {
                      _hoverRating = starValue;
                    });
                  }
                : null,
            onExit: widget.isInteractive
                ? (_) {
                    setState(() {
                      _hoverRating = _currentRating;
                    });
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.08),
              child: Icon(
                isHalf ? Icons.star_half : Icons.star,
                size: widget.size,
                color: isFilled || isHalf ? widget.activeColor : widget.inactiveColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}

extension on double {
  double roundToDouble() {
    return (this * 2).round() / 2;
  }
}
