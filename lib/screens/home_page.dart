import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rezalnyash/models/models.dart';


import '../widgets/cutting_plan_view.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  String error = '';
  CuttingData? cuttingData;
  
  // Контроллеры для формы ввода
  final _formKey = GlobalKey<FormState>();
  final _sheetWidthController = TextEditingController(text: '2800');
  final _sheetLengthController = TextEditingController(text: '2070');
  final _materialTypeController = TextEditingController(text: 'ДСП');
  final _materialThicknessController = TextEditingController(text: '18.0');
  final _gapController = TextEditingController(text: '5');
  final _bladeWidthController = TextEditingController(text: '3');
  final _marginController = TextEditingController(text: '15');
  
  String _selectedMethod = 'vertical';
  String _selectedCorner = 'top-left';
  
  // Контроллеры для деталей
  final List<Map<String, TextEditingController>> _detailsControllers = [
    {
      'name': TextEditingController(text: 'Дверца'),
      'width': TextEditingController(text: '500'),
      'length': TextEditingController(text: '700'),
      'quantity': TextEditingController(text: '2'),
      'angle': TextEditingController(text: '0'),
    },
    {
      'name': TextEditingController(text: 'Полка'),
      'width': TextEditingController(text: '800'),
      'length': TextEditingController(text: '300'),
      'quantity': TextEditingController(text: '3'),
      'angle': TextEditingController(text: '0'),
    },
    {
      'name': TextEditingController(text: 'Стенка'),
      'width': TextEditingController(text: '600'),
      'length': TextEditingController(text: '1200'),
      'quantity': TextEditingController(text: '2'),
      'angle': TextEditingController(text: '0'),
    },
  ];

  @override
  void dispose() {
    _sheetWidthController.dispose();
    _sheetLengthController.dispose();
    _materialTypeController.dispose();
    _materialThicknessController.dispose();
    _gapController.dispose();
    _bladeWidthController.dispose();
    _marginController.dispose();
    
    for (var controllers in _detailsControllers) {
      controllers.forEach((key, controller) => controller.dispose());
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('РезальНяш - Оптимальный раскрой'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Левая панель с формой ввода (30% ширины)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Параметры листа'),
                      _buildTextFormField(_sheetWidthController, 'Ширина листа (мм)', 'Введите ширину'),
                      _buildTextFormField(_sheetLengthController, 'Длина листа (мм)', 'Введите длину'),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Материал'),
                      _buildTextFormField(_materialTypeController, 'Тип материала', 'Введите тип материала', isNumeric: false),
                      _buildTextFormField(_materialThicknessController, 'Толщина материала (мм)', 'Введите толщину'),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Параметры раскроя'),
                      
                      // Выпадающий список для метода раскроя
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Метод раскроя',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedMethod,
                        items: const [
                          DropdownMenuItem(value: 'horizontal', child: Text('Горизонтальный')),
                          DropdownMenuItem(value: 'vertical', child: Text('Вертикальный')),
                          DropdownMenuItem(value: 'optimal', child: Text('Оптимальный')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMethod = value ?? 'optimal';
                          });
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Выпадающий список для начального угла
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Начальный угол',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCorner,
                        items: const [
                          DropdownMenuItem(value: 'top-left', child: Text('Верхний левый')),
                          DropdownMenuItem(value: 'top-right', child: Text('Верхний правый')),
                          DropdownMenuItem(value: 'bottom-left', child: Text('Нижний левый')),
                          DropdownMenuItem(value: 'bottom-right', child: Text('Нижний правый')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCorner = value ?? 'top-left';
                          });
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      _buildTextFormField(_gapController, 'Зазор между деталями (мм)', 'Введите зазор'),
                      _buildTextFormField(_bladeWidthController, 'Ширина реза (мм)', 'Введите ширину реза'),
                      _buildTextFormField(_marginController, 'Отступ от края (мм)', 'Введите отступ'),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Детали'),
                      
                      // Список деталей
                      ..._buildDetailFields(),
                      
                      // Кнопка для добавления новых деталей
                      TextButton.icon(
                        onPressed: _addNewDetail,
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить деталь'),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Кнопка для отправки данных
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitData,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading 
                              ? const SizedBox(
                                  width: 24, 
                                  height: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('Выполнить раскрой'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Правая панель с визуализацией результата (70% ширины)
          Expanded(
            flex: 7,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
                    : cuttingData == null
                        ? const Center(child: Text('Заполните форму и нажмите "Выполнить раскрой"'))
                        : CuttingPlanView(cuttingData: cuttingData!),
          ),
        ],
      ),
    );
  }

  // Построение заголовка секции
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Построение текстового поля ввода
  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumeric = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Пожалуйста, заполните это поле';
          }
          if (isNumeric && double.tryParse(value) == null) {
            return 'Введите числовое значение';
          }
          return null;
        },
      ),
    );
  }

  // Построение полей для деталей
  List<Widget> _buildDetailFields() {
    List<Widget> fields = [];
    
    for (int i = 0; i < _detailsControllers.length; i++) {
      fields.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Деталь #${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeDetail(i),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextFormField(_detailsControllers[i]['name']!, 'Название', 'Введите название', isNumeric: false),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(_detailsControllers[i]['width']!, 'Ширина (мм)', 'Ширина'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextFormField(_detailsControllers[i]['length']!, 'Длина (мм)', 'Длина'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(_detailsControllers[i]['quantity']!, 'Количество', 'Кол-во'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextFormField(_detailsControllers[i]['angle']!, 'Угол (°)', 'Угол'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return fields;
  }

  // Добавление новой детали
  void _addNewDetail() {
    setState(() {
      _detailsControllers.add({
        'name': TextEditingController(text: 'Новая деталь'),
        'width': TextEditingController(text: '500'),
        'length': TextEditingController(text: '500'),
        'quantity': TextEditingController(text: '1'),
        'angle': TextEditingController(text: '0'),
      });
    });
  }

  // Удаление детали
  void _removeDetail(int index) {
    if (_detailsControllers.length > 1) {
      setState(() {
        // Освобождаем ресурсы контроллеров перед удалением
        _detailsControllers[index].forEach((key, controller) => controller.dispose());
        _detailsControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Должна быть хотя бы одна деталь'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Отправка данных на сервер
  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        error = '';
      });
      
      try {
        // Формируем JSON для запроса
        final requestData = {
          'sheet': {
            'width': int.parse(_sheetWidthController.text),
            'length': int.parse(_sheetLengthController.text),
          },
          'material': {
            'material_type': _materialTypeController.text,
            'thickness': double.parse(_materialThicknessController.text),
          },
          'details': _detailsControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;
            return {
              'id': index + 1,
              'name': controllers['name']!.text,
              'width': int.parse(controllers['width']!.text),
              'length': int.parse(controllers['length']!.text),
              'quantity': int.parse(controllers['quantity']!.text),
              'angle': int.parse(controllers['angle']!.text),
            };
          }).toList(),
          'layout': {
            'method': _selectedMethod,
            'gap': int.parse(_gapController.text),
            'blade_width': int.parse(_bladeWidthController.text),
            'margin': int.parse(_marginController.text),
            'starting_corner': _selectedCorner,
          },
          'edges': [
            {
              'edge_type': 'ПВХ',
              'thickness': 0.5,
            },
          ],
        };
        
        // Отправляем запрос
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/sheet'),
          // Uri.parse('http://10.0.2.2:3000/api/sheet'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            cuttingData = CuttingData.fromJson(data);
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Ошибка запроса: ${response.statusCode} - ${response.body}';
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint(e.toString());
        setState(() {
          error = 'Ошибка: $e';
          isLoading = false;
        });
      }
    }
  }
}