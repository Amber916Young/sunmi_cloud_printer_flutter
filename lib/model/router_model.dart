class RouterModel {
  final String name;
  final bool hasPwd;
  final String? pwd;
  final int rssi;

  RouterModel({
    required this.name,
    required this.hasPwd,
    this.pwd,
    required this.rssi,
  });

  factory RouterModel.fromMap(Map<String, dynamic> map) {
    return RouterModel(
      name: map['name'] as String,
      hasPwd: map['hasPwd'] as bool,
      pwd: map['pwd'] as String?,
      rssi: map['rssi'] as int,
    );
  }

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
