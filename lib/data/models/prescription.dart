class Prescription {
  final int id;
  final int doctorId;
  final int patientId;
  final String medicationDetails;
  final String? imageUrl;
  final int status; // 0 = Pending, 1 = Dispensed, etc.

  Prescription({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.medicationDetails,
    this.imageUrl,
    this.status = 0,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] ?? 0,
      doctorId: json['doctorId'] ?? 0,
      patientId: json['patientId'] ?? 0,
      medicationDetails: json['medicationDetails'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'medicationDetails': medicationDetails,
      'imageUrl': imageUrl,
      'status': status,
    };
  }
}
