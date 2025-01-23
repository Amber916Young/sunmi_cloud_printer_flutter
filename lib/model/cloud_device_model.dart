class CloudPrinter {
  final String name;
  final String? macAddress;
  final String? ipAddress;
  final int? port;
  final bool isConnected;

  CloudPrinter({
    required this.name,
    this.macAddress,
    this.ipAddress,
    this.port,
    this.isConnected = false,
  });

  /// Factory method to create a `CloudPrinter` from a JSON object.
  factory CloudPrinter.fromJson(Map<String, dynamic> json) {
    return CloudPrinter(
      name: json['name'] as String,
      macAddress: json['macAddress'] as String?,
      ipAddress: json['ipAddress'] as String?,
      port: json['port'] as int?,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  /// Converts the `CloudPrinter` instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'port': port,
      'isConnected': isConnected,
    };
  }
}
