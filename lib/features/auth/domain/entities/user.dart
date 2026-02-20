class User {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ displayName.hashCode ^ emailVerified.hashCode;
}






