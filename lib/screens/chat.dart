import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/dummy_data/chats.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'dart:async';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';


class Chat extends StatefulWidget {
  Chat({
    Key key,
    this.messenger_name,
    this.messenger_image,
  }) : super(key: key);

  final String messenger_name;
  final String messenger_image;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatTextController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final lastKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body:    Stack(

          children: [
            CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: buildChatList(),
                    ),
                    Container(
                      height: 80,
                    )
                  ]),
                )
              ],
            ),
            //original
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.white54.withOpacity(0.6)),
                    height: 80,
                    //color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                      child: buildMessageSendingRow(context),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        child: Container(
            width: 350,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                          color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                      //shape: BoxShape.rectangle,
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.asset(widget.messenger_image)),
                  ),
                  Container(
                    width: 220,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        widget.messenger_name,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ])),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  SingleChildScrollView buildChatList() {
    return SingleChildScrollView(
      child: ListView.builder(
        key: lastKey,
        controller: _chatScrollController,
        itemCount: chatList.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: buildChatItem(index),
          );
        },
      ),
    );
  }

  buildChatItem(index) {
    return chatList[index].is_sender
        ? getSenderView(
            ChatBubbleClipper5(type: BubbleType.sendBubble),
            context,
            chatList[index].text,
            chatList[index].date,
            chatList[index].time)
        : getReceiverView(
            ChatBubbleClipper5(type: BubbleType.receiverBubble),
            context,
            chatList[index].text,
            chatList[index].date,
            chatList[index].time);
  }

  Row buildMessageSendingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 40,
          width: (MediaQuery.of(context).size.width - 32) * (4 / 5),
          child: TextField(
            autofocus: false,
            maxLines: null,
            controller: _chatTextController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(251,251, 251, 1),
                hintText: "Type your message here ...",
                hintStyle:
                    TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(35.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(35.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 16.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              //print('dd');
              var chatText = _chatTextController.text.toString();
              //print(chatText);
              if (chatText != "") {
                final DateTime now = DateTime.now();
                final DateFormat date_formatter = DateFormat('yyyy-MM-dd');
                final DateFormat time_formatter = DateFormat('hh:ss');
                final String formatted_date = date_formatter.format(now);
                final String formatted_time = time_formatter.format(now);
               /* print(chatText);
                print(formatted_date);
                print(formatted_time);
                print("--------------------");*/
                var a_chat_item = AChat(
                    text: chatText,
                    date: formatted_date,
                    time: formatted_time,
                    is_sender: true);
                setState(() {
                  chatList.add(a_chat_item);

                });

                //print(_chatScrollController.positions.elementAt(0).viewportDimension);


                  /*_chatScrollController.animateTo(
                      500,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);*/

                _chatScrollController.jumpTo(200);



              }
            },
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: MyTheme.accent_color,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                    color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                //shape: BoxShape.rectangle,
              ),
              child: Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getSenderView(
          CustomClipper clipper, BuildContext context, text, date, time) =>
      ChatBubble(
        elevation: 0.0,
        clipper: clipper,
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 10),
        backGroundColor: MyTheme.soft_accent_color,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            minWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: MyTheme.font_grey, fontSize: 13, wordSpacing: 1),
                ),
              ),
              Text(date+" "+time,
                  style: TextStyle(color: MyTheme.medium_grey, fontSize: 10)),

            ],
          ),
        ),
      );

  getReceiverView(
          CustomClipper clipper, BuildContext context, text, date, time) =>
      ChatBubble(
        elevation: 0.0,
        clipper: clipper,
        backGroundColor: Color.fromRGBO(239, 239, 239, 1),
        margin: EdgeInsets.only(top: 10),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            minWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: MyTheme.font_grey, fontSize: 13, wordSpacing: 1),
                ),
              ),
              Text(date+" "+time,
                  style: TextStyle(color: MyTheme.medium_grey, fontSize: 10)),

            ],
          ),
        ),
      );
}
