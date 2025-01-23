import 'package:flutter/material.dart';

class DialogUtils {
  static Future<String?> showIpInputDialog(BuildContext context, String name) {
    final TextEditingController _textController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter static Ip for $name'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: '192.168.xx.xx',
            ),
            obscureText: false,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_textController.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> showSnInputDialog(BuildContext context, String name) {
    final TextEditingController _textController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter SN for $name'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Enter SN',
            ),
            obscureText: false,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_textController.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> showPasswordDialog(BuildContext context, String routerName) {
    final TextEditingController _passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Password for $routerName'),
          content: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              hintText: 'Enter WiFi password',
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_passwordController.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
