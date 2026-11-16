class AppUser {
  const AppUser({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}
