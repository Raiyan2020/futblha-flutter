class PlaygroundFilterRequestModel {
  final List<int>? cityIds;
  final List<int>? capacityIds;
  final List<String>? landTypes;
  final List<int>? facilityIds;
  final String? name;
  final String? date;

  PlaygroundFilterRequestModel({
    this.cityIds,
    this.capacityIds,
    this.landTypes,
    this.facilityIds,
    this.name,
    this.date,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (cityIds != null && cityIds!.isNotEmpty) {
      for (int i = 0; i < cityIds!.length; i++) {
        params['cityIds[$i]'] = cityIds![i];
      }
    }
    
    if (capacityIds != null && capacityIds!.isNotEmpty) {
      for (int i = 0; i < capacityIds!.length; i++) {
        params['capacityIds[$i]'] = capacityIds![i];
      }
    }
    
    if (landTypes != null && landTypes!.isNotEmpty) {
      for (int i = 0; i < landTypes!.length; i++) {
        params['landTypes[$i]'] = landTypes![i];
      }
    }
    
    if (facilityIds != null && facilityIds!.isNotEmpty) {
      for (int i = 0; i < facilityIds!.length; i++) {
        params['facilityIds[$i]'] = facilityIds![i];
      }
    }
    
    if (name != null && name!.isNotEmpty) {
      params['name'] = name!;
    }
    
    if (date != null && date!.isNotEmpty) {
      params['date'] = date!;
    }
    
    return params;
  }

  /// Check if any filters are active (excluding search name)
  bool hasActiveFilters() {
    return (cityIds != null && cityIds!.isNotEmpty) ||
        (capacityIds != null && capacityIds!.isNotEmpty) ||
        (landTypes != null && landTypes!.isNotEmpty) ||
        (facilityIds != null && facilityIds!.isNotEmpty) ||
        (date != null && date!.isNotEmpty);
  }
}

