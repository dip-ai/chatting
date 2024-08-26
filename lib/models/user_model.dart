class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;
  List<String>? groupIds; // List of group IDs the user belongs to

  UserModel(
      {this.uid,
      this.fullName,
      this.email,
      this.profilePic,
      this.groupIds = const []});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    profilePic = map["profilePic"];
    groupIds = List<String>.from(map["groupIds"] ?? []);
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "profilePic": profilePic,
      "groupIds": groupIds,
    };
  }
}
