import 'package:flutter/material.dart';

enum VehicleType {
  Walk(6, 'Walk', Icons.directions_walk),
  Bike(5, 'Bike', Icons.directions_bike),
  Motorcycle(4, 'Motorcycle', Icons.motorcycle),
  Car(2, 'Car', Icons.directions_car),
  Truck(1, 'Truck', Icons.local_shipping),
  Train(3, 'Train', Icons.train),
  Drone(10, 'Drone', Icons.flight);

  final int value;
  final String name;
  final IconData icon;

  static VehicleType getTypeFromInt(int value) {
    for (var element in VehicleType.values) {
      if (element.value == value) {
        return element;
      }
    }
    return VehicleType.Bike;
  }

  const VehicleType(this.value, this.name, this.icon);
}
