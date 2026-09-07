class Doctor {
  final int id;
  final String name;
  final String specialization;
  final String? email;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    this.email,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'email': email,
    };
  }
}
