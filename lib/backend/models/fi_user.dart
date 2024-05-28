import 'package:json_annotation/json_annotation.dart';
part 'fi_user.g.dart';

@JsonSerializable()

class FiUser {
  String? uuid ;
  late String token;
  String?  username;
  late String email;
 // List<dynamic> groups = <String>[];
    List<dynamic>? groups;
  //List<dynamic> calendars = <String>[];
  //dynamic information ;
  Map<String,dynamic>? settings ;

  static FiUser fromJson(Map<String,dynamic> json) =>_$FiUserFromJson(json) ;

}