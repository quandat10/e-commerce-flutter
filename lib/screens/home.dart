import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_selling_products.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/ui_sections/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title, this.show_back_button = false}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  bool show_back_button ;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  ScrollController _featuredProductScrollController;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: buildAppBar(statusBarHeight, context),
        drawer: MainDrawer(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    8.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: buildHomeCarouselSlider(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    8.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: buildHomeMenuRow(context),
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Featured Categories",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16.0,
                  16.0,
                  0.0,
                  0.0,
                ),
                child: SizedBox(
                  height: 154,
                  child: buildHomeFeaturedCategories(context),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Featured Products",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          4.0,
                          16.0,
                          8.0,
                          0.0,
                        ),
                        child: buildHomeFeaturedProducts(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                )
              ]),
            ),
          ],
        ));
  }

  buildHomeFeaturedProducts(context) {
    return FutureBuilder(
        future: ProductRepository().getFeaturedProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            /*print("product error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            //snapshot.hasData
            var featuredProductResponse = snapshot.data;
            return GridView.builder(
              // 2
              //addAutomaticKeepAlives: true,
              itemCount: featuredProductResponse.products.length,
              controller: _featuredProductScrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.618),
              padding: EdgeInsets.all(8),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // 3
                return ProductCard(
                  id: featuredProductResponse.products[index].id,
                  image:
                      featuredProductResponse.products[index].thumbnail_image,
                  name: featuredProductResponse.products[index].name,
                  price: featuredProductResponse.products[index].base_price,
                );
              },
            );
          } else {
            return ShimmerHelper().buildProductGridShimmer(
                scontroller: _featuredProductScrollController);
          }
        });
  }

  buildHomeFeaturedCategories(context) {
    return FutureBuilder(
        future: CategoryRepository().getFeturedCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //snapshot.hasError
            /*print("Home slider error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            //snapshot.hasData
            var featuredCategoryResponse = snapshot.data;
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredCategoryResponse.categories.length,
                itemExtent: 120,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () {
                        if (featuredCategoryResponse
                                .categories[index].number_of_children >
                            0) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CategoryList(
                              parent_category_name: featuredCategoryResponse
                                  .categories[index].name,
                            );
                          }));
                        } else {
                          ToastComponent.showDialog(
                              "No sub categories available", context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG);
                        }
                      },
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          side: new BorderSide(
                              color: MyTheme.light_grey, width: 1.0),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 0.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                //width: 100,
                                height: 100,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                        bottom: Radius.zero),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/placeholder.png',
                                      image: AppConfig.BASE_PATH +
                                          featuredCategoryResponse
                                              .categories[index].banner,
                                      fit: BoxFit.cover,
                                    ))),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                              child: Container(
                                height: 32,
                                child: Text(
                                  featuredCategoryResponse
                                      .categories[index].name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 11, color: MyTheme.font_grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
                Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
              ],
            );
          }
        });
  }

  buildHomeMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CategoryList(
                is_top_category: true,
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_categories.png"),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Top Categories",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Filter(
                selected_filter: "brands",
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/brands.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Brands",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TopSellingProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_sellers.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Top Sellers",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TodaysDealProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/todays_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Todays Deal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FlashDealList();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/flash_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Flash Deal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        )
      ],
    );
  }

  buildHomeCarouselSlider(context) {
    return FutureBuilder(
        future: SlidersRepository().getSliders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            /*print("Home slider error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            var sliderResponse = snapshot.data;
            var carouselImageList = [];
            sliderResponse.sliders.forEach((slider) {
              carouselImageList.add(slider.photo);
            });
            return CarouselSlider(
              options: CarouselOptions(
                  aspectRatio: 2.67,
                  viewportFraction: 1,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.easeInCubic,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current_slider = index;
                    });
                  }),
              items: carouselImageList.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      'assets/placeholder_rectangle.png',
                                  image: AppConfig.BASE_PATH + i,
                                  fit: BoxFit.fill,
                                ))),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: carouselImageList.map((url) {
                              int index = carouselImageList.indexOf(url);
                              return Container(
                                width: 7.0,
                                height: 7.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current_slider == index
                                      ? MyTheme.white
                                      : Color.fromRGBO(112, 112, 112, .3),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Shimmer.fromColors(
                baseColor: MyTheme.shimmer_base,
                highlightColor: MyTheme.shimmer_highlighted,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            );
          }
        });
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: widget.show_back_button
            ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 0.0),
                  child: Container(
                    child: Image.asset(
                      'assets/hamburger.png',
                      height: 16,
                      //color: MyTheme.dark_grey,
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ),
              ),
      ),
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 16.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
          child: Padding(
              padding:
                  const EdgeInsets.only(top: 14.0,bottom: 14, right:12), // when notification bell will be shown , the right padding will cease to exist.
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Filter();
                    }));
                  },
                  child: buildHomeSearchBox(context))),
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        InkWell(
          onTap: () {
            ToastComponent.showDialog("Coming soon", context,
                gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          },
          child: Visibility(
            visible: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              child: Image.asset(
                'assets/bell.png',
                height: 16,
                color: MyTheme.dark_grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return TextField(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Filter();
        }));
      },
      autofocus: false,
      decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.textfield_grey, width: 0.5),
            borderRadius: const BorderRadius.all(
              const Radius.circular(16.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.textfield_grey, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(16.0),
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              color: MyTheme.textfield_grey,
              size: 20,
            ),
          ),
          contentPadding: EdgeInsets.all(0.0)),
    );
  }
}
