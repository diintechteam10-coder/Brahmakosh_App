import 'package:flutter/material.dart';

void main() {
  String? url = "hello";
  bool hasImage = url != null && url.isNotEmpty;
  var b = hasImage ? NetworkImage(url) : null;
}
