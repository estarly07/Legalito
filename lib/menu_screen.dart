import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Legalito Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/chats");
              },
              child: Text('Asistente legal'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/documentos");
                // TODO: Navigate to Generación de documentos screen
              },
              child: Text('Generación de documentos'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Simulador de conflictos screen
              },
              child: Text('Simulador de conflictos'),
            ),
          ],
        ),
      ),
    );
  }
}
