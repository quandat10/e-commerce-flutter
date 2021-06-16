import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/dummy_data/messengers.dart';
import 'package:active_ecommerce_flutter/screens/chat.dart';

class MessengerList extends StatefulWidget {
  @override
  _MessengerListState createState() => _MessengerListState();
}

class _MessengerListState extends State<MessengerList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: buildMessengerList(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "Messages",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  SingleChildScrollView buildMessengerList() {
    return SingleChildScrollView(
      child: ListView.builder(
        itemCount: messengerList.length,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(0.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
                top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
            child: buildMessengerItemCard(index),
          );
        },
      ),
    );
  }

  buildMessengerItemCard(index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Chat(
            messenger_name: messengerList[index].name,
            messenger_image: messengerList[index].image,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom:8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                  color: Color.fromRGBO(112, 112, 112, .3), width: 1),
              //shape: BoxShape.rectangle,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.asset( messengerList[index].image)),
          ),
          Container(
            height: 50,
            width: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    messengerList[index].name,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: MyTheme.medium_grey,
              size: 14,
            ),
          )
        ]),
      ),
    );
  }
}
