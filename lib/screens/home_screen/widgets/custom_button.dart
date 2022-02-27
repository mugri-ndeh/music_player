import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';

class CustomButtonWidget extends StatelessWidget {
  final Widget child;
  final double size;
  final double borderWidth;
  final bool isActive;
  final VoidCallback onTap;

  const CustomButtonWidget({
    required this.child,
    required this.onTap,
    required this.size,
    this.borderWidth = 2.0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    var boxdecoration = Stack(
      children: [
        Positioned(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClayContainer(
                color: black,
                width: 220,
                height: 220,
                borderRadius: 200,
                depth: -50,
                curveType: CurveType.convex,
              ),
              ClayContainer(
                color: black,
                width: 180,
                height: 180,
                borderRadius: 200,
                depth: 50,
              ),
              ClayContainer(
                color: black,
                width: 140,
                height: 140,
                borderRadius: 200,
                depth: -50,
                curveType: CurveType.convex,
              ),
              ClayContainer(
                color: black,
                width: 100,
                height: 100,
                borderRadius: 200,
                depth: 50,
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
    if (isActive) {
      boxdecoration = Stack(
        children: [
          Positioned(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClayContainer(
                  color: black,
                  width: 220,
                  height: 220,
                  borderRadius: 200,
                  depth: -50,
                  curveType: CurveType.convex,
                ),
                ClayContainer(
                  color: black,
                  width: 180,
                  height: 180,
                  borderRadius: 200,
                  depth: 50,
                ),
                ClayContainer(
                  color: black,
                  width: 140,
                  height: 140,
                  borderRadius: 200,
                  depth: -50,
                  curveType: CurveType.convex,
                ),
                ClayContainer(
                  color: darkBlue,
                  width: 100,
                  height: 100,
                  borderRadius: 200,
                  depth: 50,
                  child: child,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(200)),
        ),
        onPressed: onTap,
        child: boxdecoration,
      ),
    );
  }
}
