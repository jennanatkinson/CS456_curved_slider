import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

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

    //   if (SliderValues.active) {
    //     paint.color = SliderValues.activeColor;
    //   } else {
    //     paint.color = SliderValues.inactiveColor;
    //   }
    //

    // var path = Path();
    // path.moveTo(0, (-1 * size.height));
    // path.quadraticBezierTo(size.width, (-1 * size.height), size.width, 0);
    // path.quadraticBezierTo(
    //     size.width * .7, size.height * .1, size.width, size.height);
    //path.lineTo(size.width, size.height);

    // canvas.drawPath(path, curvePaint);

    canvas.drawArc(
        Offset(-1 * CurvedSliderValues.rX, 0) &
            Size(CurvedSliderValues.rX * 2, CurvedSliderValues.rY * 2),
        radians(-90),
        radians(90),
        false,
        curvePaint);
    canvas.drawCircle(Offset(SliderValues.thumbX, SliderValues.thumbX),
        SliderValues.thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
