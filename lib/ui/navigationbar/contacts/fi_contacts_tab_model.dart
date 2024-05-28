
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/main/base/fi_model.dart';
import '../../../utils/fi_log.dart';
import '../../base/fi_base_state.dart';
import '../../launching/fi_launching_model.dart';
import 'fi_contacts_page_widget.dart';
import 'fi_contacts.dart';
import 'fi_contacts_tab_widget.dart';



class FiContactsTabModel extends FiModel {
  static final FiContactsTabModel _instance = FiContactsTabModel._internal();
  final List<FiContact> _privateContacts = <FiContact>[];
  final List<FiContact> _searchedContacts = <FiContact>[];
  final List<FiContact> _notSharedContacts = <FiContact>[];
  final List<FiContact> _sharedContacts = <FiContact>[];
  final List<FiContact> _favoriteBusinessContacts = <FiContact>[];
  final List<FiContact> _favoriteSharedContacts = <FiContact>[];
  final List<FiContact> _favoriteOrganizationContacts = <FiContact>[];

  final List<FiContact> _organizationContacts = <FiContact>[];
  List<FiContactsPageWidget> pages = <FiContactsPageWidget>[];
  final Map<FiContactPageType, FiBaseState> _states = {};

  late TextEditingController _searchController;

  TextEditingController get searchController => _searchController;
  int _currentPageIndex = 0;

  bool _inSearch = false;

  bool get inSearch => _inSearch;

  VoidCallback get stopSearch => () {
        updatePage(callback: () {
          _searchedContacts.clear();
          _inSearch = false;
          _searchController.text = "";
        });
      };





  setPageState(FiContactPageType type, FiBaseState? state) {
    if (state != null) {
      _states[type] = state;
    } else {
      _states.remove(type);
    }
  }

  updatePage({VoidCallback? callback}) => _states[currentType]?.updateState(callback: callback);

  updateAllPages({VoidCallback? callback}) {
    Iterator<FiBaseState> states = _states.values.iterator;
    if (states.moveNext()) {
      do {
        states.current.updateState(callback: callback);
      } while (states.moveNext());
    }
  }

  FiContactsTabModel._internal();

  factory FiContactsTabModel() {
    return _instance;
  }

  FiContactPageType get currentType {
   /* switch (_currentPageIndex) {
      case 1:
        return FiContactPageType.business;
      case 2:
        return FiContactPageType.shared;
      case 3:
        return FiContactPageType.organization;
    }
    if(_states.containsKey(FiContactPageType.addingToGroup)) {
      return FiContactPageType.addingToGroup;
    }*/
    return FiContactPageType.private;

  }

  int get privateContactsCount => _inSearch ? _searchedContacts.length : _privateContacts.length;

/*  int get businessContactsCount => _inSearch ? _searchedContacts.length : _notSharedContacts.length;

  int get sharedContactsCount => _inSearch ? _searchedContacts.length : _sharedContacts.length;

  int get organizationContactsCount => _inSearch ? _searchedContacts.length : _organizationContacts.length;*/

/*  int get favoritesCount {
    switch (_currentPageIndex) {
      case 1:
        return _favoriteBusinessContacts.length;
      case 2:
        return _favoriteSharedContacts.length;
      default:
        return _favoriteOrganizationContacts.length;
    }
  }*/

  ValueChanged<String> get onSearch => (text) {
        _inSearch = text.trim().isNotEmpty;
        Iterable<FiContact>? searched;
        logger.d("Searching: $text index $_currentPageIndex");
        switch (_currentPageIndex) {
          case 0:
            {
              searched = _privateContacts.where((element) => element.name.toLowerCase().contains(text.toLowerCase()) || element.phoneNumber.toLowerCase().contains(text.toLowerCase()));
              logger.d("Searching in private contacts count ${searched.length}");
            }
            break;
          case 1:
            {
              searched = _notSharedContacts.where((element) => element.name.toLowerCase().contains(text.toLowerCase()) || element.phoneNumber.toLowerCase().contains(text.toLowerCase()));
            }
            break;
          case 2:
            {
              searched = _sharedContacts.where((element) => element.name.toLowerCase().contains(text.toLowerCase()) || element.phoneNumber.toLowerCase().contains(text.toLowerCase()));
            }
            break;
          case 3:
            {
              searched = _organizationContacts.where((element) => element.name.toLowerCase().contains(text.toLowerCase()) || element.phoneNumber.toLowerCase().contains(text.toLowerCase()));
            }
            break;
        }

        if (_inSearch && searched != null && searched.isNotEmpty) {
          updatePage(callback: () {
            logger.d("Updated $_searchedContacts");
            _searchedContacts.clear();
            _searchedContacts.addAll(searched!);

          });
        } else {
          updatePage(callback: () {
            _searchedContacts.clear();
            _searchController.text = "";
          });
        }
      };

  set currentPageIndex(int currentPageIndex) {
    updateAllPages(callback: () {
      _searchedContacts.clear();
      _inSearch = false;
      _searchController.text = "";
      _currentPageIndex = currentPageIndex;
    });
  }

  Future<void> load() async {
    var status = await launchingModel.getContactPermission();
    if (status == PermissionStatus.granted) {
      List<Contact> phoneContacts = await ContactsService.getContacts();
      phoneContacts.sort((a, b)
      {
        if (a.displayName != null && b.displayName != null) {
          return a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase());
        }
        return 0;
      });
      String initialLetter = "";

      for (var element in phoneContacts) {
        FiContact contact = FiContact(type: FiContactPageType.private, phoneContact: element);
        if (contact.valid) {
          contact.loadData(() {
            String current = contact.name.characters.first.toUpperCase();
          if (current != initialLetter) {
              initialLetter = current;
              _privateContacts.add(FiContact(type: FiContactPageType.divider, divider: initialLetter));
            }
            _privateContacts.add(contact);
          });
        }
      }
    }

    pages.add( FiContactsPageWidget(FiContactPageType.private));
    _searchController = TextEditingController();
  }

  int get pageCount => pages.length;

  FiContactsPageWidget pageAtIndex(int index) =>  pages[0] ;//index < pageCount ? pages[index] : pages[0];

  AssetImage get myImage => const AssetImage("assets/images/nb_man_icon.png");

  FiContact contactAtIndex(int index, FiContactPageType type) {
    if (_inSearch) {
      return _searchedContacts[index];
    }

        return _privateContacts[index];

  }

  /*FiContact favoriteAtIndex(int index) {
    switch (_currentPageIndex) {
      case 1:
        return _favoriteBusinessContacts[index];
      case 2:
        return _favoriteSharedContacts[index];
      default:
        return _favoriteOrganizationContacts[index];
    }
  }
*/
  List<FiContact> get favorites {
    switch (_currentPageIndex) {
      case 1:
        return _favoriteBusinessContacts;
      case 2:
        return _favoriteSharedContacts;
      default:
        return _favoriteOrganizationContacts;
    }
  }


  String get favoriteKey  => "favorite_$_currentPageIndex" ;


  void setAsFavorite(FiContact contact) {
    if (!favorites.contains(contact)) {
      updatePage(callback: () {
        contact.isFavorite = true ;
        //contact.properties["favorite_$_currentPageIndex"] = true ;
        favorites.add(contact);
      });
    } else {
      updatePage(callback: () {
        contact.isFavorite = false ;
        //contact.properties["favorite_$_currentPageIndex"] = false ;
        favorites.remove(contact);
      });
    }
  }

/*  void updateData(CxGroup group) {

    if(group.memberModels.isNotEmpty){
      for(CxGroupUserModel model in group.memberModels){
        var contact = FiContact(type: FiContactPageType.organization, groupUserModel: model);
        if(group.type == CxGroupType.groupInOrganization) {
          if(!_exist(model.id,_organizationContacts)) {
            _organizationContacts.add(contact);
          }
        }
        if(contact.isShared){
          if(!_exist(model.id,_sharedContacts)) {
            _sharedContacts.add(contact);
          }
        }
        else {
          if(!_exist(model.id,_notSharedContacts)) {
            _notSharedContacts.add(contact);
          }
        }
      }
    }
  }*/

/*  bool _exist(String id,List<FiContact> list){
    return list.where((element) => (element.groupUserModel?.id??"") == id).isNotEmpty ;
  }*/
}

FiContactsTabModel contacts = FiContactsTabModel();
