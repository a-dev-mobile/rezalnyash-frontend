// Models for cutting application
// This file contains all data models used in the application

// Модель для данных раскроя
class CuttingData {
  final SheetInfo sheet;
  final LayoutInfo layout;
  final List<DetailInfo> details;
  final List<UnplacedDetailInfo> unplacedDetails;
  final Statistics statistics;

  CuttingData({
    required this.sheet,
    required this.layout,
    required this.details,
    required this.unplacedDetails,
    required this.statistics,
  });

  factory CuttingData.fromJson(Map<String, dynamic> json) {
    return CuttingData(
      sheet: SheetInfo.fromJson(json['sheet']),
      layout: LayoutInfo.fromJson(json['layout']),
      details: (json['details'] as List)
          .map((detail) => DetailInfo.fromJson(detail))
          .toList(),
      unplacedDetails: (json['unplaced_details'] as List)
          .map((detail) => UnplacedDetailInfo.fromJson(detail))
          .toList(),
      statistics: Statistics.fromJson(json['statistics']),
    );
  }
}

// Модель для нераспределенных деталей
class UnplacedDetailInfo {
  final int id;
  final String name;
  final int width;
  final int length;
  final int angle;
  final int quantity;

  UnplacedDetailInfo({
    required this.id,
    required this.name,
    required this.width,
    required this.length,
    required this.angle,
    required this.quantity,
  });

  factory UnplacedDetailInfo.fromJson(Map<String, dynamic> json) {
    return UnplacedDetailInfo(
      id: json['id'],
      name: json['name'],
      width: json['width'],
      length: json['length'],
      angle: json['angle'],
      quantity: json['quantity'],
    );
  }
}

// Модели для информации о листе
class SheetInfo {
  final int width;
  final int length;
  final int padding;
  final ViewBox viewBox;

  SheetInfo({
    required this.width,
    required this.length,
    required this.padding,
    required this.viewBox,
  });

  factory SheetInfo.fromJson(Map<String, dynamic> json) {
    return SheetInfo(
      width: json['width'],
      length: json['length'],
      padding: json['padding'],
      viewBox: ViewBox.fromJson(json['viewBox']),
    );
  }
}

class ViewBox {
  final int width;
  final int height;

  ViewBox({required this.width, required this.height});

  factory ViewBox.fromJson(Map<String, dynamic> json) {
    return ViewBox(
      width: json['width'],
      height: json['height'],
    );
  }
}

// Модель информации о макете
class LayoutInfo {
  final String method;
  final int gap;
  final int bladeWidth;
  final int margin;
  final String startingCorner;

  LayoutInfo({
    required this.method,
    required this.gap,
    required this.bladeWidth,
    required this.margin,
    required this.startingCorner,
  });

  factory LayoutInfo.fromJson(Map<String, dynamic> json) {
    return LayoutInfo(
      method: json['method'],
      gap: json['gap'],
      bladeWidth: json['blade_width'],
      margin: json['margin'],
      startingCorner: json['starting_corner'],
    );
  }
}

// Модель для деталей
class DetailInfo {
  final int id;
  final String name;
  final int width;
  final int length;
  final int angle;
  final int x;
  final int y;
  final TextPosition textPosition;

  DetailInfo({
    required this.id,
    required this.name,
    required this.width,
    required this.length,
    required this.angle,
    required this.x,
    required this.y,
    required this.textPosition,
  });

  factory DetailInfo.fromJson(Map<String, dynamic> json) {
    return DetailInfo(
      id: json['id'],
      name: json['name'],
      width: json['width'],
      length: json['length'],
      angle: json['angle'],
      x: json['x'],
      y: json['y'],
      textPosition: TextPosition.fromJson(json['textPosition']),
    );
  }
}

class TextPosition {
  final int x;
  final int y;

  TextPosition({required this.x, required this.y});

  factory TextPosition.fromJson(Map<String, dynamic> json) {
    return TextPosition(
      x: json['x'],
      y: json['y'],
    );
  }
}

// Модель для статистики
class Statistics {
  final int sheetArea;
  final int usedArea;
  final int wasteArea;
  final int cutLength;
  final int edgeLength;
  final int detailCount;
  final int unplacedCount;
  final double efficiency;

  Statistics({
    required this.sheetArea,
    required this.usedArea,
    required this.wasteArea,
    required this.cutLength,
    required this.edgeLength,
    required this.detailCount,
    required this.unplacedCount,
    required this.efficiency,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      sheetArea: json['sheet_area'],
      usedArea: json['used_area'],
      wasteArea: json['waste_area'],
      cutLength: json['cut_length'],
      edgeLength: json['edge_length'],
      detailCount: json['detail_count'],
      unplacedCount: json['unplaced_count'],
      efficiency: json['efficiency'].toDouble(),
    );
  }
}