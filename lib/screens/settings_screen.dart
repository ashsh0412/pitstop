import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text("Connect to OBD2"),
            onTap: () {
              // 블루투스 연결 기능 추가 예정
            },
          ),
          ListTile(
            leading: Icon(Icons.car_repair),
            title: Text("Select Vehicle Model"),
            onTap: () {
              // 차량 모델 선택 기능 추가 예정
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Enable Dark Mode"),
            onTap: () {
              // 다크 모드 기능 추가 예정
            },
          ),
        ],
      ),
    );
  }
}
