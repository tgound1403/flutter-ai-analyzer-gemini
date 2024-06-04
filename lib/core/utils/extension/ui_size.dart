import 'package:flutter/material.dart';

class SizeUtil {
  SizeUtil._();
  factory SizeUtil.init({Size? size}) {
    SizeUtil.sizeDefault = size ?? const Size(375, 812);
    return SizeUtil._();
  }

  static SizeUtil instance = SizeUtil._();

  static late final Size sizeDefault;
  static final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  static final Size pS = view?.physicalSize ?? sizeDefault;
  static final dR = view?.devicePixelRatio ?? 1;
  static final Size _size = pS / dR;
  static Size get size => _size;
}

extension NumSize on Size {
  double h(Size size) => height / size.height;

  double w(Size size) => width / size.width;

  double f(Size size) =>
      width < height ? width / size.width : height / size.height;
}

extension NumEx on num {
  double get sf => SizeUtil.size.f(SizeUtil.sizeDefault) * this;

  Widget get vSpace => SizedBox(height: sf);

  Widget get hSpace => SizedBox(width: sf);
}