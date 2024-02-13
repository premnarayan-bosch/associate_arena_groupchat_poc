import 'package:associate_arena_groupchat_poc/app_manager.dart';
import 'package:associate_arena_groupchat_poc/test/chat_page.dart';
import 'package:associate_arena_groupchat_poc/test/database_service.dart';
import 'package:associate_arena_groupchat_poc/test/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage1 extends StatefulWidget {
  const SearchPage1({Key? key}) : super(key: key);

  @override
  State<SearchPage1> createState() => _SearchPageState1();
}

class _SearchPageState1 extends State<SearchPage1> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  String employeeNumber = "";

  final List<MyData> _list = [];
  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await AppManager.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    await AppManager.getEmployeeNumberFromSF().then((value) {
      setState(() {
        employeeNumber = value!;
      });
    });
    initiateSearchMethod();
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 68, 218),
        title: const Text(
          "All Groups",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 68, 255, 236)),
                )
              : groupList(),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    await DatabaseService().searchName().then((snapshot) {
      setState(() {
        searchSnapshot = snapshot;

        isLoading = false;
        if (searchSnapshot != null) {
          if (searchSnapshot!.size > 0) {
            searchSnapshot!.docs.forEach((element) async {
              MyData myData = MyData();
              myData.groupId = element['groupId'];
              myData.groupName = element['groupName'];

              myData.admin = element['admin'];

              await DatabaseService(uid: employeeNumber)
                  .isUserJoined(
                      element['groupName'], element['groupId'], userName)
                  .then((value) {
                myData.isJoined = value;
              });
              _list.add(myData);
            });

            hasUserSearched = true;
          } else {
            hasUserSearched = false;
          }
        } else {
          hasUserSearched = false;
        }
      });
    });
  }

  groupList() {
    print("ogroupListbject ${_list.length}");
    return _list.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _list.length,
            itemBuilder: (context, index) {
              print("EmployeeNumber2 $employeeNumber"
                  "EmployeeName $userName"
                  "isjOined ${_list[index].isJoined!}"
                  "groupname ${_list[index].groupName!}");

              for (var element in _list) {
                print("DatabaseService length ${_list.length}"
                    "DatabaseService groupName ${element.groupName}"
                    "isJoined ${element.isJoined}");
              }

              MyData myData = _list[index];
              return groupTile(userName, myData.groupId!, myData.groupName!,
                  myData.admin!, myData.isJoined!, index);
            },
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: employeeNumber)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {});
  }

  Widget groupTile(String userName, String groupId, String groupName,
      String admin, bool isJoined, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: employeeNumber)
              .toggleGroupJoin(groupId, userName, groupName);
          if (!isJoined) {
            setState(() {
              _list[index].isJoined = !isJoined;
            });
            showSnackbar(
                context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              _list[index].isJoined = !isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Leave Group",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}

class MyData {
  String? groupId;
  String? groupName;
  String? admin;
  bool? isJoined;

  MyData({this.groupId, this.groupName, this.admin, this.isJoined});
}
