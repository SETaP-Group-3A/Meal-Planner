class Account {
  final String name;
  final String email;
  final String password;

  Account({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  String toString() {
    return 'Account(name: $name, email: $email)';
  }
}