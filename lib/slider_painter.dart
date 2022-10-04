import 'package:flutter/material.dart';

import 'main.dart';

class SliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    SliderValues.sliderMax = size.width;
    var curvePaint = Paint();
    curvePaint.color = Colors.purple;
    curvePaint.style = PaintingStyle.stroke;
    curvePaint.strokeWidth = 4;

    var thumbPaint = Paint();
    thumbPaint.color = Colors.purple;
    thumbPaint.style = PaintingStyle.fill;

    if (SliderValues.active) {
      curvePaint.color = SliderValues.activeColor;
      thumbPaint.color = SliderValues.activeColor;
    } else {
      curvePaint.color = SliderValues.inactiveColor;
      thumbPaint.color = SliderValues.inactiveColor;
    }

    canvas.drawArc(
        Offset(-1 * CurvedSliderValues.rX, 0) &
            Size(CurvedSliderValues.rX * 2, CurvedSliderValues.rY * 2),
        CurvedSliderValues.startAngle,
        CurvedSliderValues.endAngle - CurvedSliderValues.startAngle,
        false,
        curvePaint);
    canvas.drawCircle(Offset(SliderValues.thumbX, SliderValues.thumbY),
        SliderValues.thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
