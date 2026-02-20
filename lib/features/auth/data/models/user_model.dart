import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.emailVerified = false,
  });

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      emailVerified: firebaseUser.emailVerified ?? false,
    );
  }

  factory UserModel.fromDomain(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }
}






