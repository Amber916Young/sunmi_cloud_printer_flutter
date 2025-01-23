package example;

class Router {
  final String name;
  final bool hasPwd;
  final String? pwd;
  final int rssi;

  Router({
    required this.name,
    required this.hasPwd,
    this.pwd,
    required this.rssi,
  });

  // Factory method to create a Router object from a Map
  factory Router.fromMap(Map<String, dynamic> map) {
    return Router(
      name: map['name'] as String,
      hasPwd: map['hasPwd'] as bool,
      pwd: map['pwd'] as String?,
      rssi: map['rssi'] as int,
    );
  }

  // Method to convert a Router object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hasPwd': hasPwd,
      'pwd': pwd,
      'rssi': rssi,
    };
  }

  @override
  String toString() {
    return 'Router(name: $name, hasPwd: $hasPwd, pwd: $pwd, rssi: $rssi)';
  }
}
