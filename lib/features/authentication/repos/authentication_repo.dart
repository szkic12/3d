import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationRepository {
  // firebase authentication provider 생성
  // main 에서 firebase initialize(Firebase.initializeApp) 하는 시점에 instance 를 만들면 firebase와 연결됨.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // initialize

  bool get isLoggedIn => user != null;

  // getter 에 value 를 넣어주면 그걸 property 처럼 사용 가능함.
  User? get user => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // create account
  Future<UserCredential> emailSignUp(String email, String password) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> githubSignIn() async {
    await _firebaseAuth.signInWithProvider(
      GithubAuthProvider(),
    );
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());

// user의 인증 상태 변경 감지 (sign-in, sign-out)
final authState = StreamProvider((ref) {
  final repo = ref.read(authRepo);
  return repo.authStateChanges();
});
