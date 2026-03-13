import 'package:flutter/material.dart';

void main() {
  String? url;
  bool hasImage = url != null;
  var b = hasImage ? NetworkImage(url) : null;
}
