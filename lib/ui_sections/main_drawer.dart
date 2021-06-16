import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:active_ecommerce_flutter/screens/home.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wishlist.dart';
import 'package:active_ecommerce_flutter/screens/shipping_info.dart';
import 'package:active_ecommerce_flutter/screens/checkout.dart';
import 'package:active_ecommerce_flutter/screens/registration.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/messenger_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';



class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key key,
  }) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {

  onTapLogout(context) async {
    AuthHelper().clearUserData();

    /*
    var logoutResponse = await AuthRepository()
            .getLogoutResponse();


    if(logoutResponse.result == true){
         ToastComponent.showDialog(logoutResponse.message, context,
                   gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
         }
         */
    Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Login();
          }));
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Container(
        padding: EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              is_logged_in.value == true ? ListTile(
                  leading:  CircleAvatar(
                    backgroundImage: NetworkImage(

                                                        AppConfig.BASE_PATH +
                                                           "${avatar_original.value}",

                                                     ),
                  ),
                  title: Text("${user_name.value}"),
                  subtitle: user_email.value !="" && user_email.value !=null ? Text("${user_email.value}") : Text("${user_phone.value}")

              ):Text('Not logged in',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
              Divider(),
              ListTile(
               visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Image.asset("assets/home.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                title: Text('Home',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                onTap:(){
                    Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return Main();
                            }));
                    }
              ),
               is_logged_in.value == true ? ListTile(
             visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              leading: Image.asset("assets/profile.png",height:16,color:Color.fromRGBO(153,153,153,1)),
              title: Text('Profile',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
              onTap:(){
                  Navigator.push(
                              context, MaterialPageRoute(builder: (context) {
                            return Profile(show_back_button:true);
                          }));
                  }
            ):Container(),
              is_logged_in.value == true ? ListTile(
               visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Image.asset("assets/order.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                title: Text('Orders',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                onTap:(){
                    Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return OrderList(from_checkout:false);
                            }));
                    }
              ):Container(),
              is_logged_in.value == true ? ListTile(
                 visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset("assets/heart.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                  title: Text('My Wishlist',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                  onTap:(){
                      Navigator.push(
                                  context, MaterialPageRoute(builder: (context) {
                                return Wishlist();
                              }));
                      }
                ):Container(),
             (is_logged_in.value == true && false) ? ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                 leading: Image.asset("assets/chat.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                 title: Text('Messages',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                 onTap:(){
                     ToastComponent.showDialog("Coming soon", context,
                         gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                     return;
                     Navigator.push(
                                 context, MaterialPageRoute(builder: (context) {
                               return MessengerList();
                             }));
                     }
              ):Container(),
              is_logged_in.value == true ? ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                   leading: Image.asset("assets/wallet.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                   title: Text('Wallet',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                   onTap:(){
                       Navigator.push(
                                   context, MaterialPageRoute(builder: (context) {
                                 return Wallet();
                               }));
                       }
                ):Container(),

              Divider(height:24),
              is_logged_in.value == false ? ListTile(
               visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Image.asset("assets/login.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                title: Text('Login',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                onTap:(){
                      Navigator.push(
                                  context, MaterialPageRoute(builder: (context) {
                                return Login();
                              }));
                      }
              ):Container(),
              is_logged_in.value == true ? ListTile(
                 visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset("assets/logout.png",height:16,color:Color.fromRGBO(153,153,153,1)),
                  title: Text('Logout',style:TextStyle(color:Color.fromRGBO(153,153,153,1),fontSize:14)),
                onTap:(){
                    onTapLogout(context);
                  }
                ):Container(),

            ],
          ),
        ),
      ),
    );
  }
}
