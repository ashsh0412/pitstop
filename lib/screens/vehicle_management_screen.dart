import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차량 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '등록된 차량이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('차량 등록'),
                    onPressed: () => _showAddVehicleDialog(context),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = provider.vehicles[index];
              final isSelected = vehicle.id == provider.selectedVehicle?.id;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.blue : Colors.grey,
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                      Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isSelected)
                        TextButton(
                          onPressed: () => provider.selectVehicle(vehicle),
                          child: const Text('선택'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEditVehicleDialog(context, vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _showDeleteConfirmation(context, vehicle),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _VehicleDialog(),
    );
  }

  void _showEditVehicleDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => _VehicleDialog(vehicle: vehicle),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차량 삭제'),
        content: Text('${vehicle.name}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<VehicleProvider>(context, listen: false)
                  .deleteVehicle(vehicle);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDialog extends StatefulWidget {
  final Vehicle? vehicle;

  const _VehicleDialog({this.vehicle});

  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _vinController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name);
    _makeController = TextEditingController(text: widget.vehicle?.make);
    _modelController = TextEditingController(text: widget.vehicle?.model);
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString(),
    );
    _vinController = TextEditingController(text: widget.vehicle?.vin);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vehicle == null ? '차량 등록' : '차량 정보 수정'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '차량 별명 *',
                  hintText: '예: 우리 차',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '차량 별명을 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: '제조사 *',
                  hintText: '예: 현대',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제조사를 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: '모델 *',
                  hintText: '예: 아반떼',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '모델을 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: '연식 *',
                  hintText: '예: 2020',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '연식을 입력하세요';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return '올바른 연식을 입력하세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN (선택사항)',
                  hintText: '차대번호',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _saveVehicle,
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      name: _nameController.text,
      make: _makeController.text,
      model: _modelController.text,
      year: int.parse(_yearController.text),
      vin: _vinController.text.isEmpty ? null : _vinController.text,
    );

    final provider = Provider.of<VehicleProvider>(context, listen: false);
    if (widget.vehicle == null) {
      provider.addVehicle(vehicle);
    } else {
      provider.updateVehicle(vehicle);
    }

    Navigator.pop(context);
  }
}
