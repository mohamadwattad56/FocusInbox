import 'dart:ui';

import 'package:contacts_service/contacts_service.dart';
import 'package:image_picker/image_picker.dart';

import 'package:string_validator/string_validator.dart';

import '../../../backend/models/cx_group_user_model.dart';
import '../../../backend/models/fi_user.dart';
import '../../../backend/upload/fi_images_manager.dart';
import '../../../utils/fi_image_data.dart';
import '../../../utils/fi_log.dart';
import '../../../utils/fi_resources.dart';
import 'fi_contacts_tab_widget.dart';

class FiContact {
  Contact? phoneContact;
  List<Contact>? duplicates;
  Image? _avatar;

  FiContactPageType type;
  String divider = "";
  bool isFavorite = false;
  String? _firstName;
  String? _lastName;
  String? convertedTitle;

  String? convertedFirstName ;
  String? convertedLastName ;
  FiImageData? _image;

  bool aggregated = false;

  //Map<String, List<CxConvertedValue>> convertedData = {};

  FiUser? user;
  CxGroupUserModel? groupUserModel ;

  FiContact({this.phoneContact, required this.type, FiUser? user, this.divider = ""}) {
    if (user != null) {
      this.user = user;
      List<String> names = user.username?.split(" ") ?? [];
      _firstName = names.isNotEmpty ? names[0] : null;
      _lastName = names.length > 1 ? names[1] : null;
      actualListPhones.add(Item(label: "email", value: user.email));
    }
  }


  XFile? get avatarImageFile => _image?.image;

  List<Item> actualListPhones = <Item>[];
  List<Item> actualListEmails = <Item>[];

  String get name {
    return phoneContact?.displayName ?? user?.username ?? firstName;
  }

  String get title {
    if (phoneContact != null && phoneContact!.jobTitle != null &&
        phoneContact!.jobTitle!.isNotEmpty) {
      return phoneContact!.jobTitle!;
    }
    return convertedTitle ?? localise("title");
  }


  void setFirstName(String value) {

  }

  void setLastName(String value) {

  }

  String get firstName {
    if (user != null && user!.username != null) {
      if (user!.username!.split(" ").length > 1) {
        return user!.username!.split(" ")[0];
      }
    }

    if (phoneContact != null && phoneContact!.givenName != null &&
        phoneContact!.givenName!.isNotEmpty) {
      _firstName = phoneContact!.givenName!;
    }
    if (_firstName == null) {
      List<String> array = name.split(" ");
      if (array.length > 1) {
        _firstName = array.first;
      } else {
        _firstName = name;
      }
    }
    return _firstName!;
  }

  String get lastName {
    if (user != null && user!.username != null) {
      if (user!.username!.split(" ").length > 1) {
        return user!.username!.split(" ")[1];
      }
    }

    if (phoneContact != null && phoneContact!.familyName != null &&
        phoneContact!.familyName!.isNotEmpty) {
      _firstName = phoneContact!.familyName!;
    }
    if (_lastName == null) {
      List<String> array = name.split(" ");
      if (array.length > 1) {
        _lastName = array.last;
      } else {
        _lastName = "";
      }
    }
    return _lastName!;
  }

  bool get isDivider => type == FiContactPageType.divider;

  String get phoneNumber =>
      actualListPhones.isNotEmpty ? actualListPhones.first.value ?? "" : "";

  bool get valid {
    return name.isNotEmpty && !isNumeric(name) &&
        phoneContact!.phones != null && phoneContact!.phones!.isNotEmpty;
  }

  int get phonesCount => actualListPhones.length;
  CxGroupUserModel? model ;

  bool isShared = false;
  String? id;

  List<String> get phonesAsString {
    List<String> all = <String>[];
    Iterator<Item> it = actualListPhones.iterator;
    if (it.moveNext()) {
      do {
        if (it.current.value != null) {
          if (phoneNumber != it.current.value) {
            all.add(it.current.value!);
          }
        }
      }
      while (it.moveNext());
    }
    return all;
  }

  List<String> get emailsAsString {
    List<String> all = <String>[];
    Iterator<Item> it = actualListEmails.iterator;
    if (it.moveNext()) {
      do {
        if (it.current.value != null) {
          all.add(it.current.value!);
        }
      }
      while (it.moveNext());
    }
    return all;
  }


/*  List<String> get calendarsAsString {
    List<String> all = <String>[];
    if (user != null) {
      Iterator<dynamic> it = user!.calendars.iterator;
      if (it.moveNext()) {
        do {
          all.add(it.current);
        }
        while (it.moveNext());
      }
    }
    return all;
  }*/
/*
  List<String> get whatsappAccountsAsString {
    List<String> all = <String>[];
    Iterator<Item> it = actualListSocial.iterator;
    if (it.moveNext()) {
      do {
        if (it.current.value != null) {
          all.add(it.current.value!);
        }
      }
      while (it.moveNext());
    }
    return all;
  }*/


  String phoneAtIndex(int index) => actualListPhones[index].value ?? "";

  loadData(VoidCallback completion) {
    _buildActualPhonesList();
    _buildActualEmailList();

    if (phoneContact != null && phoneContact!.avatar != null &&
        phoneContact!.avatar!.isNotEmpty) {
      decodeImageFromList(phoneContact!.avatar!, (image) {
        logger.d("Image decoded!");
        _avatar = image;
        _image = FiImageData(image: XFile.fromData(phoneContact!.avatar!),
            buffer: phoneContact!.avatar!);
        completion.call();
      });
    } else {
      completion.call();
    }

    convertedFirstName = firstName;
    convertedLastName = lastName;
    convertedTitle = title;
    //convertedCompany = company;
  }

  Image? get avatar => _avatar;

  String? get sharedBy => null;

  String? get localName => null;

  void _buildActualPhonesList() {
    Map<String, Item> checker = {};
    if (phoneContact != null && phoneContact!.phones != null &&
        phoneContact!.phones!.isNotEmpty) {
      for (var element in phoneContact!.phones!) {
        if (element.value != null) {
          String value = element.value!.replaceAll(RegExp(r'\D'), '');
          if (!checker.containsKey(value)) {
            checker[value] = element;
            actualListPhones.add(element);
          }
          logger.d("Phones of $name => $actualListPhones");
        }
      }
    }
  }

  void _buildActualEmailList() {
    Map<String, Item> checker = {};
    if (phoneContact != null && phoneContact!.emails != null &&
        phoneContact!.emails!.isNotEmpty) {
      for (var element in phoneContact!.emails!) {
        if (element.value != null) {
          String value = element.value!.replaceAll(RegExp(r'\D'), '');
          if (!checker.containsKey(value)) {
            checker[value] = element;
            actualListEmails.add(element);
          }
          logger.d("Emails of $name => $actualListEmails");
        }
      }
    }
  }

  Future<void> updateAvatar(XFile file, {VoidCallback? completion}) async {
    var buffer = await file.readAsBytes();
    decodeImageFromList(buffer, (image) {
      logger.d("Image decoded!");
      _avatar = image;
      _image = FiImageData(image: file, buffer: buffer);
      completion?.call();
    });
  }

  Future<void> uploadImage() async {
    if (id != null && _image != null) {
      await imagesApi.uploadImage(id!, _image!);
    }
  }



  CxGroupUserModel get fromPhoneContact {
    CxGroupUserModel model = CxGroupUserModel ();
    if(phoneContact != null){

      model.title = phoneContact!.jobTitle??"" ;
      if( (phoneContact!.givenName?.isEmpty??true) && (phoneContact!.familyName?.isEmpty??true) ){
        if(phoneContact?.displayName?.isEmpty??true){
          model.firstName=model.lastName = phoneNumber ;
        }
        else {
          model.firstName = firstName ;
          model.lastName = lastName ;
        }
      }
      else {
        model.firstName = phoneContact!.givenName??"" ;
        model.lastName = phoneContact!.familyName??"" ;
      }

      model.phones ??= <String>[];
      model.phones!.clear() ;
      if (actualListPhones.isNotEmpty) {
        for(Item item in actualListPhones){
          model.phones!.add(item.value!) ;
        }
      }

      model.emails ??= <String>[];
      model.emails!.clear() ;
      if (actualListEmails.isNotEmpty) {
        for(Item item in actualListEmails){
          model.emails!.add(item.value!) ;
        }
      }

     /* model.socials ??= <String>[];
      model.socials!.clear() ;*/
   /*   if (actualListSocial.isNotEmpty) {
        for(Item item in actualListSocial){
          model.emails!.add(item.value!) ;
        }
      }*/
     // model.company = phoneContact!.company??"" ;


    }
    return model ;
  }
}

