class WeatherDetails {
  String? latitude;
  String? longitude;
  String? country;
  String? address;
  String? maxTemp;
  String? minTemp;

  WeatherDetails({
    this.latitude,
    this.longitude,
    this.address,
    this.country,
    this.maxTemp,
    this.minTemp,
  });

  WeatherDetails.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    country = json['country'];
    address = json['address'];
    maxTemp = json['maxTemp'];
    minTemp = json['minTemp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['country'] = this.country;
    data['address'] = this.address;
    data['maxTemp'] = this.maxTemp;
    data['minTemp'] = this.minTemp;
    return data;
  }
}
