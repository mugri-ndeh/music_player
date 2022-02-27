import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';

class BackgroundDesign extends StatelessWidget {
  const BackgroundDesign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          color: black,
          height: size.height * 0.4,
          child: Stack(
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
                    ),
                  ],
                ),
                right: 0,
                top: -size.height * 0.05,
              )
            ],
          ),
        ),
        Container(
          height: size.height * 0.4,
          child: Stack(
            children: [
              Positioned(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClayContainer(
                      color: black,
                      width: 160,
                      height: 160,
                      borderRadius: 200,
                      depth: 50,
                      curveType: CurveType.convex,
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
                      width: 70,
                      height: 70,
                      borderRadius: 200,
                      depth: 50,
                    ),
                  ],
                ),
                left: -size.width * 0.05,
                bottom: size.height * 0.1,
              )
            ],
          ),
        ),
        Container(
          height: size.height * 0.4,
          child: Stack(
            children: [
              Positioned(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClayContainer(
                      color: black,
                      width: 100,
                      height: 100,
                      borderRadius: 200,
                      depth: 50,
                      curveType: CurveType.convex,
                    ),
                    ClayContainer(
                      color: black,
                      width: 80,
                      height: 80,
                      borderRadius: 200,
                      depth: -50,
                      curveType: CurveType.convex,
                    )
                  ],
                ),
                left: size.width * 0.52,
                bottom: 10,
              )
            ],
          ),
        )
      ],
    );
  }
}
