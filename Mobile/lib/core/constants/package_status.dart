class PackageStatus {
  static const created = 'Created';
  static const receivedAtWarehouse = 'Received at Warehouse';
  static const assignedToLinehaul = 'Assigned to Linehaul';
  static const pickedUp = 'Picked Up';
  static const inTransit = 'In Transit';
  static const arrivedAtWarehouse = 'Arrived at Warehouse';
  static const assignedToCourier = 'Assigned to Courier';
  static const outForDelivery = 'Out For Delivery';
  static const delivered = 'Delivered';
  static const failedDelivery = 'Failed Delivery';

  static const linehaulTabDiGudang = [assignedToLinehaul];
  static const linehaulTabDiantar = [pickedUp, inTransit];
  static const linehaulTabSelesai = [arrivedAtWarehouse];

  static const courierTabDiGudang = [assignedToCourier];
  static const courierTabDiantar = [outForDelivery];
  static const courierTabSelesai = [delivered, failedDelivery];

  static List<String> nextStatuses(String currentStatus, String role) {
    if (role == 'LINEHAUL') {
      return switch (currentStatus) {
        assignedToLinehaul => [pickedUp],
        pickedUp => [inTransit],
        inTransit => [arrivedAtWarehouse],
        _ => [],
      };
    }
    if (role == 'COURIER') {
      return switch (currentStatus) {
        assignedToCourier => [outForDelivery],
        outForDelivery => [delivered, failedDelivery],
        _ => [],
      };
    }
    if (role == 'WAREHOUSE_ADMIN') {
      return switch (currentStatus) {
        created => [receivedAtWarehouse],
        receivedAtWarehouse => [],
        arrivedAtWarehouse => [],
        _ => [],
      };
    }
    return [];
  }
}
