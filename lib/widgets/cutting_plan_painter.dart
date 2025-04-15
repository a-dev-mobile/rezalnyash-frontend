import 'package:flutter/material.dart';
import '../models/models.dart';

// CustomPainter для отрисовки плана раскроя
class CuttingPlanPainter extends CustomPainter {
  final CuttingData cuttingData;
  final DetailInfo? selectedDetail;
  final bool showLegend;
  
  CuttingPlanPainter({
    required this.cuttingData,
    this.selectedDetail,
    required this.showLegend,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final sheet = cuttingData.sheet;
    
    // Масштабируем, чтобы план поместился на экране
    final scaleX = size.width / sheet.viewBox.width;
    final scaleY = size.height / sheet.viewBox.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    canvas.scale(scale);
    
    // Рисуем фон листа
    final sheetPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
      
    canvas.drawRect(
      Rect.fromLTWH(
        sheet.padding.toDouble(), 
        sheet.padding.toDouble(),
        sheet.width.toDouble(),
        sheet.length.toDouble(),
      ),
      sheetPaint,
    );
    
    // Рисуем сетку
    _drawGrid(canvas, sheet);
    
    // Рисуем границу листа
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawRect(
      Rect.fromLTWH(
        sheet.padding.toDouble(), 
        sheet.padding.toDouble(),
        sheet.width.toDouble(),
        sheet.length.toDouble(),
      ),
      borderPaint,
    );
    
    // Рисуем детали
    final List<Color> detailColors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.amber[200]!,
      Colors.red[200]!,
      Colors.purple[200]!,
      Colors.orange[200]!,
      Colors.teal[200]!,
      Colors.cyan[200]!,
      Colors.lime[200]!,
      Colors.indigo[200]!,
    ];
    
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 14.0 / scale, // Масштабируем размер текста
    );
    
    final textBackground = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
      
    // Отрисовка деталей
    for (final detail in cuttingData.details) {
      // Выбираем цвет по ID детали
      final color = detailColors[detail.id % detailColors.length];
      
      // Определяем, выбрана ли эта деталь
      final isSelected = selectedDetail?.id == detail.id && 
                         selectedDetail?.x == detail.x && 
                         selectedDetail?.y == detail.y;
      
      // Рисуем деталь
      final detailPaint = Paint()
        ..color = isSelected ? color.withOpacity(0.8) : color
        ..style = PaintingStyle.fill;
        
      final strokePaint = Paint()
        ..color = isSelected ? Colors.red : Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3.0 : 1.0;
        
      // Сохраняем текущее состояние canvas
      canvas.save();
      
      // Если деталь повернута, выполняем поворот canvas
      if (detail.angle != 0) {
        // Вычисляем центр детали
        final centerX = detail.x + detail.width / 2;
        final centerY = detail.y + detail.length / 2;
        
        // Поворачиваем canvas вокруг центра детали
        canvas.translate(centerX.toDouble(), centerY.toDouble());
        canvas.rotate(detail.angle * 3.14159 / 180);
        canvas.translate(-centerX.toDouble(), -centerY.toDouble());
      }
      
      // Рисуем прямоугольник детали
      final rect = Rect.fromLTWH(
        detail.x.toDouble(),
        detail.y.toDouble(),
        detail.width.toDouble(),
        detail.length.toDouble(),
      );
      
      canvas.drawRect(rect, detailPaint);
      canvas.drawRect(rect, strokePaint);
      
      // Восстанавливаем состояние canvas
      canvas.restore();
      
      // Рисуем текст с именем и размерами детали только если включена легенда
      if (showLegend) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${detail.name}\n${detail.width}x${detail.length}',
            style: textStyle,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        // Рисуем фон для текста
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(
              detail.textPosition.x.toDouble(),
              detail.textPosition.y.toDouble(),
            ),
            width: textPainter.width + 10,
            height: textPainter.height + 6,
          ),
          textBackground,
        );
        
        // Рисуем текст
        textPainter.paint(
          canvas,
          Offset(
            detail.textPosition.x - textPainter.width / 2,
            detail.textPosition.y - textPainter.height / 2,
          ),
        );
      }
    }
  }
  
  // Метод для отрисовки сетки
  void _drawGrid(Canvas canvas, SheetInfo sheet) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Шаг сетки в миллиметрах (каждые 100 мм)
    const gridStep = 100.0;
    
    // Вертикальные линии
    for (double x = sheet.padding.toDouble(); x <= sheet.padding + sheet.width; x += gridStep) {
      canvas.drawLine(
        Offset(x, sheet.padding.toDouble()),
        Offset(x, (sheet.padding + sheet.length).toDouble()),
        gridPaint,
      );
    }
    
    // Горизонтальные линии
    for (double y = sheet.padding.toDouble(); y <= sheet.padding + sheet.length; y += gridStep) {
      canvas.drawLine(
        Offset(sheet.padding.toDouble(), y),
        Offset((sheet.padding + sheet.width).toDouble(), y),
        gridPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CuttingPlanPainter oldDelegate) {
    return oldDelegate.cuttingData != cuttingData ||
           oldDelegate.selectedDetail != selectedDetail ||
           oldDelegate.showLegend != showLegend;
  }
}