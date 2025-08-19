class VehicleSelection {
  final String brand;
  final String model;
  final int year;

  VehicleSelection({required this.brand, required this.model, required this.year});

  Map<String, dynamic> toJson() => {'brand': brand, 'model': model, 'year': year};

  factory VehicleSelection.fromJson(Map<String, dynamic> j) =>
      VehicleSelection(brand: j['brand'], model: j['model'], year: j['year']);
}
