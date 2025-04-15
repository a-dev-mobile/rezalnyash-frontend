import 'package:flutter/material.dart';
import '../models/models.dart';

// Widget for displaying unplaced details
class UnplacedDetailsPanel extends StatelessWidget {
  final List<UnplacedDetailInfo> unplacedDetails;
  final Function(UnplacedDetailInfo) onDetailSelected;

  const UnplacedDetailsPanel({
    Key? key,
    required this.unplacedDetails,
    required this.onDetailSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (unplacedDetails.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.green[50],
        child: const Center(
          child: Text(
            'Все детали успешно размещены!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Неразмещенные детали:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: unplacedDetails
                  .map((detail) => _buildUnplacedDetailCard(detail))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnplacedDetailCard(UnplacedDetailInfo detail) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      color: Colors.white,
      elevation: 3,
      child: InkWell(
        onTap: () => onDetailSelected(detail),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text('ID: ${detail.id}'),
              Text('Размеры: ${detail.width} x ${detail.length} мм'),
              Text('Количество: ${detail.quantity}'),
              Text('Угол: ${detail.angle}°'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomPaint(
                  painter: UnplacedDetailPainter(
                    width: detail.width.toDouble(),
                    length: detail.length.toDouble(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter for unplaced detail preview
class UnplacedDetailPainter extends CustomPainter {
  final double width;
  final double length;

  UnplacedDetailPainter({required this.width, required this.length});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[200]!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.red[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Scale the detail to fit in the container
    final scale = _calculateScale(size);
    final scaledWidth = width * scale;
    final scaledLength = length * scale;

    // Center the detail in the container
    final offsetX = (size.width - scaledWidth) / 2;
    final offsetY = (size.height - scaledLength) / 2;

    final rect = Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledLength);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw diagonal "not available" lines
    final linePaint = Paint()
      ..color = Colors.red[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(offsetX, offsetY),
      Offset(offsetX + scaledWidth, offsetY + scaledLength),
      linePaint,
    );
    canvas.drawLine(
      Offset(offsetX + scaledWidth, offsetY),
      Offset(offsetX, offsetY + scaledLength),
      linePaint,
    );
  }

  double _calculateScale(Size containerSize) {
    // Calculate scale to fit the detail in the container
    // while preserving aspect ratio
    double scaleX = containerSize.width / width;
    double scaleY = containerSize.height / length;
    return scaleX < scaleY ? scaleX * 0.9 : scaleY * 0.9; // 90% to add some margin
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}