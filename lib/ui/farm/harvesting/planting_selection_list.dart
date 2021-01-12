import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmassist/data/farm/utils/weather_strings.dart';
import 'package:farmassist/ui/farm/harvesting/form_storeHarvesting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:page_transition/page_transition.dart';

import '../../../app_theme.dart';

class PlantingSelectionList extends StatefulWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  _PlantingSelectionListState createState() => _PlantingSelectionListState();
}

class _PlantingSelectionListState extends State<PlantingSelectionList> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  final _monthOptions = ["January", "February"];
  var _option;
  String uid = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FormBuilderDropdown(
                  name: 'month',
                  // initialValue: "January",
                  decoration: InputDecoration(
                    labelText: 'Month',
                  ),
                  onChanged: (value) {
                    print(_option);
                    User user = _auth.currentUser;
                    setState(() {
                      _option = value;
                      uid = user.uid;
                    });
                    print(_option);
                    print(uid);
                  },
                  allowClear: true,
                  hint: Text('Select Month'),
                  validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.required(context)]),
                  items: _monthOptions
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text('$month'),
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ),
        leading: GFIconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          type: GFButtonType.transparent,
        ),
        title: Text(
          "Create Harvesting Entry",
          style: TextStyle(
            color: AppTheme.nearlyBlack,
          ),
        ),
        backgroundColor: AppTheme.nearlyWhite,
      ),
      body: _option != null
          ? (StreamBuilder<QuerySnapshot>(
              stream: widget.db
                  .collection("Planting")
                  .doc(uid)
                  .collection(_option)
                  .where('harvested', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Loading...');
                }
                return Column(
                  children: [
                    new Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              String docID = snapshot.data.docs[index].id;
                              String itemTitle =
                                  snapshot.data.docs[index]['name'];
                              String date = snapshot.data.docs[index]['date'];
                              String harvest =
                                  snapshot.data.docs[index]['harvestDate'];
                              String number =
                                  snapshot.data.docs[index]['noOfPlants'];
                              double est =
                                  snapshot.data.docs[index]['estimatedHarvest'];
                              int month = snapshot.data.docs[index]['month'];
                              return GFListTile(
                                padding: EdgeInsets.all(10.0),
                                titleText: Strings.toTitleCase(itemTitle),
                                subtitleText: date,
                                color: Colors.blueGrey[100],
                                icon: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType
                                              .leftToRightWithFade,
                                          child: StoreHarvesting(
                                            documentID: docID,
                                            plantName: itemTitle,
                                            plantNo: number,
                                            plantDate: date,
                                            plantEstimate: est,
                                            plantHarvest: harvest,
                                            plantMonth: month,
                                          )));
                                },
                              );
                            }))
                  ],
                );
              },
            ))
          : Container(
              child: Center(
                child: Text("Please select a month."),
              ),
            ),
    );
  }
}
