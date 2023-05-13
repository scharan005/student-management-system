class SopUser {
  String uid;
  final String name;
  final String bitsid;
  final String email;
  final String cgpa;
  final String worktitle;
  final bool admin;


  SopUser({
    required this.uid,
    required this.name,
    required this.bitsid,
    required this.email,
    required this.cgpa,
    required this.worktitle,
    this.admin = false,
  });

  factory SopUser.fromJson(Map<String, dynamic> json) {
    return SopUser(
      uid: json["uid"],
      name:json["name"],
      bitsid: json["bitsid"],
      cgpa: json["cgpa"],
      email: json["email"],
      worktitle: json["worktitle"],
      admin:json["admin"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "bitsid": bitsid,
      "email": email,
      "cgpa": cgpa,
      "worktitle": worktitle,
      "admin":admin,
    };
  }
}

