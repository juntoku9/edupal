import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


void showErrorMessage(BuildContext context, String? errorMessage) {
  if (errorMessage == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Text(errorMessage!),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}

void showMessage(BuildContext context, String? message) {
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Text(message!),
      ),
      // backgroundColor: Colors.grey,
      duration: Duration(seconds: 3),
    ),
  );
}
