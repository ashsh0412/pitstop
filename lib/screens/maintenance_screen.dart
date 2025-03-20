import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // 자가 수리 가이드 데이터
  final List<Map<String, dynamic>> repairGuides = [
    {
      'title': '엔진 오일 교체',
      'difficulty': '중간',
      'estimatedTime': '30분',
      'tools': ['오일 필터 렌치', '드레인 팬', '새 오일', '새 오일 필터'],
      'steps': [
        '엔진을 완전히 식힙니다',
        '드레인 플러그를 풀어 오일을 배출합니다',
        '오일 필터를 교체합니다',
        '새 오일을 주입합니다',
        '오일 레벨을 확인합니다',
      ],
    },
    {
      'title': '타이어 교체',
      'difficulty': '쉬움',
      'estimatedTime': '20분',
      'tools': ['잭', '휠 렌치', '새 타이어'],
      'steps': [
        '차량을 안전한 위치에 주차합니다',
        '타이어 너트를 풉니다',
        '잭으로 차량을 들어올립니다',
        '타이어를 교체합니다',
        '너트를 조입니다',
      ],
    },
    {
      'title': '브레이크 패드 교체',
      'difficulty': '어려움',
      'estimatedTime': '1시간',
      'tools': ['잭', '휠 렌치', '브레이크 패드', 'C-클램프'],
      'steps': [
        '차량을 들어올립니다',
        '휠을 제거합니다',
        '브레이크 캘리퍼를 분리합니다',
        '패드를 교체합니다',
        '캘리퍼를 다시 장착합니다',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Maintenance'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: repairGuides.length,
        itemBuilder: (context, index) {
          final guide = repairGuides[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                guide['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                '난이도: ${guide['difficulty']} | 예상 소요시간: ${guide['estimatedTime']}',
                style: TextStyle(
                  color: guide['difficulty'] == '쉬움'
                      ? Colors.green
                      : guide['difficulty'] == '중간'
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '필요한 도구:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: (guide['tools'] as List<String>)
                            .map((tool) => Chip(label: Text(tool)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '수리 단계:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(guide['steps'] as List<String>).map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(step)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
