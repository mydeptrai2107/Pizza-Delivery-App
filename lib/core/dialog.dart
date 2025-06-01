import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

showDialogSuccess(BuildContext context, String message) {
  Flushbar(
    message: message,
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
    margin: EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(8),
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      Icons.check,
      color: Colors.white,
    ),
  ).show(context);
}

showDialogFail(BuildContext context, String message) {
  Flushbar(
    message: message,
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
    margin: EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(8),
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      Icons.error_outline_rounded,
      color: Colors.white,
    ),
  ).show(context);
}
