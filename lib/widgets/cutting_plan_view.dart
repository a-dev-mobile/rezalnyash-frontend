import 'package:flutter/material.dart';
import '../models/models.dart';
import 'unplaced_details_panel.dart';
import 'cutting_plan_painter.dart';

// Виджет для визуализации раскроя
class CuttingPlanView extends StatefulWidget {
  final CuttingData cuttingData;
  
  const CuttingPlanView({Key? key, required this.cuttingData}) : super(key: key);

  @override
  State<CuttingPlanView> createState() => _CuttingPlanViewState();
}

class _CuttingPlanViewState extends State<CuttingPlanView> {
  DetailInfo? selectedDetail;
  UnplacedDetailInfo? selectedUnplacedDetail;
  final TransformationController _transformationController = TransformationController();
  // Add this state variable to track legend visibility
  bool _showLegend = true;
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Статистика и информация о раскрое
        Container(
          color: Colors.blue[50],
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Параметры листа', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Размер: ${widget.cuttingData.sheet.width} x ${widget.cuttingData.sheet.length} мм'),
                            Text('Площадь: ${widget.cuttingData.statistics.sheetArea / 1000000} м²'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Параметры раскроя', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Метод: ${_getMethodName(widget.cuttingData.layout.method)}'),
                            Text('Начальный угол: ${_getCornerName(widget.cuttingData.layout.startingCorner)}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Результаты', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Размещено: ${widget.cuttingData.statistics.detailCount}'),
                            // Add this line to show unplaced count
                            Text('Не размещено: ${widget.cuttingData.statistics.unplacedCount}',
                                style: TextStyle(
                                  color: widget.cuttingData.statistics.unplacedCount > 0 ? Colors.red : Colors.black,
                                  fontWeight: widget.cuttingData.statistics.unplacedCount > 0 ? FontWeight.bold : FontWeight.normal,
                                )),
                            Text('Деталей: ${widget.cuttingData.statistics.detailCount}'),
                            Text('Эффективность: ${widget.cuttingData.statistics.efficiency.toStringAsFixed(2)}%'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Дополнительно', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Длина реза: ${widget.cuttingData.statistics.cutLength} мм'),
                            Text('Площадь отходов: ${widget.cuttingData.statistics.wasteArea / 1000000} м²'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Unplaced details panel
        if (widget.cuttingData.unplacedDetails.isNotEmpty)
          UnplacedDetailsPanel(
            unplacedDetails: widget.cuttingData.unplacedDetails,
            onDetailSelected: (detail) {
              setState(() {
                selectedUnplacedDetail = detail;
              });
            },
          ),
        
        // Визуализация раскроя
        Expanded(
          child: Stack(
            children: [
              // Масштабируемая область с планом раскроя
              InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.1,
                maxScale: 5.0,
                child: GestureDetector(
                  onTapUp: (details) {
                    _handleTap(details.localPosition);
                  },
                  child: Center(
                    child: CustomPaint(
                      size: Size(
                        widget.cuttingData.sheet.viewBox.width.toDouble(),
                        widget.cuttingData.sheet.viewBox.height.toDouble(),
                      ),
                      painter: CuttingPlanPainter(
                        cuttingData: widget.cuttingData,
                        selectedDetail: selectedDetail,
                        showLegend: _showLegend,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Управление масштабом
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    // Add legend toggle button
                    FloatingActionButton(
                      heroTag: 'toggle_legend',
                      mini: true,
                      onPressed: () {
                        setState(() {
                          _showLegend = !_showLegend;
                        });
                      },
                      tooltip: _showLegend ? 'Скрыть легенду' : 'Показать легенду',
                      child: Icon(_showLegend ? Icons.label_off : Icons.label),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'zoom_in',
                      mini: true,
                      onPressed: _zoomIn,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'zoom_out',
                      mini: true,
                      onPressed: _zoomOut,
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'zoom_reset',
                      mini: true,
                      onPressed: _resetZoom,
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Информация о выбранной детали
        if (selectedDetail != null)
          Container(
            color: Colors.blue[50],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Деталь: ${selectedDetail!.name}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('ID: ${selectedDetail!.id}'),
                          Text('Размеры: ${selectedDetail!.width} x ${selectedDetail!.length} мм'),
                          Text('Угол: ${selectedDetail!.angle}°'),
                          Text('Позиция: (${selectedDetail!.x}, ${selectedDetail!.y})'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Обработка нажатия на план раскроя
  void _handleTap(Offset position) {
    // Получаем текущую матрицу трансформации
    final matrix = _transformationController.value;
    
    // Инвертируем матрицу, чтобы получить координаты в исходной системе
    final Matrix4 inverseMatrix = Matrix4.copy(matrix);
    inverseMatrix.invert();
    final untransformedPosition = MatrixUtils.transformPoint(inverseMatrix, position);
    
    // Проверяем, попало ли касание на какую-либо деталь
    DetailInfo? tappedDetail;
    
    for (final detail in widget.cuttingData.details) {
      if (untransformedPosition.dx >= detail.x && 
          untransformedPosition.dx <= detail.x + detail.width &&
          untransformedPosition.dy >= detail.y && 
          untransformedPosition.dy <= detail.y + detail.length) {
        tappedDetail = detail;
        break;
      }
    }
    
    setState(() {
      selectedDetail = tappedDetail;
    });
  }

  // Увеличение масштаба
  void _zoomIn() {
    _transformationController.value = _transformationController.value.scaled(1.2, 1.2);
  }

  // Уменьшение масштаба
  void _zoomOut() {
    _transformationController.value = _transformationController.value.scaled(0.8, 0.8);
  }

  // Сброс масштаба
  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  // Получение названия метода раскроя
  String _getMethodName(String method) {
    switch (method) {
      case 'horizontal': return 'Горизонтальный';
      case 'vertical': return 'Вертикальный';
      case 'optimal': return 'Оптимальный';
      default: return method;
    }
  }

  // Получение названия начального угла
  String _getCornerName(String corner) {
    switch (corner) {
      case 'top-left': return 'Верхний левый';
      case 'top-right': return 'Верхний правый';
      case 'bottom-left': return 'Нижний левый';
      case 'bottom-right': return 'Нижний правый';
      default: return corner;
    }
  }
}