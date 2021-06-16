import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/common_webview_screen.dart';
import 'package:active_ecommerce_flutter/screens/product_reviews.dart';
import 'package:active_ecommerce_flutter/ui_elements/list_product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/mini_product_card.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/addon_config.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:expandable/expandable.dart';
import 'dart:ui';
import 'package:flutter_html/flutter_html.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/repositories/wishlist_repository.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/color_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';

class ProductDetails extends StatefulWidget {
  int id;

  ProductDetails({Key key, this.id}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String _appbarPriceString = ". . .";
  int _currentImage = 0;
  CarouselController _imageCarouselController = CarouselController();
  ScrollController _mainScrollController = ScrollController();
  ScrollController _colorScrollController = ScrollController();
  ScrollController _variantScrollController = ScrollController();

  //init values
  bool _isInWishList = false;
  var _productDetailsFetched = false;
  var _productDetails = null;
  var _carouselImageList = [];
  var _colorList = [];
  int _selectedColorIndex = 0;
  var _selectedChoices = [];
  var _choiceString = "";
  var _variant = "";
  var _totalPrice;
  var _singlePrice;
  var _singlePriceString;
  int _quantity = 1;
  int _stock = 0;

  List<dynamic> _relatedProducts = [];
  bool _relatedProductInit = false;
  List<dynamic> _topProducts = [];
  bool _topProductInit = false;

  @override
  void initState() {
    fetchAll();
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _variantScrollController.dispose();
    _colorScrollController.dispose();
    super.dispose();
  }

  fetchAll() {
    //print("product id : ${widget.id}");
    fetchProductDetails();
    if (is_logged_in.value == true) {
      fetchWishListCheckInfo();
    }

    fetchRelatedProducts();
    fetchTopProducts();
  }

  fetchProductDetails() async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(id: widget.id);

    if (productDetailsResponse.detailed_products.length > 0) {
      _productDetails = productDetailsResponse.detailed_products[0];
    }

    setProductDetailValues();

    setState(() {});
  }

  fetchRelatedProducts() async {
    var relatedProductResponse =
        await ProductRepository().getRelatedProducts(id: widget.id);
    _relatedProducts.addAll(relatedProductResponse.products);
    _relatedProductInit = true;

    setState(() {});
  }

  fetchTopProducts() async {
    var topProductResponse =
        await ProductRepository().getTopFromThisSellerProducts(id: widget.id);
    _topProducts.addAll(topProductResponse.products);
    _topProductInit = true;
  }

  setProductDetailValues() {
    if (_productDetails != null) {
      _appbarPriceString = _productDetails.price_high_low;
      _singlePrice = _productDetails.calculable_price;
      _singlePriceString = _productDetails.main_price;
      calculateTotalPrice();
      _stock = _productDetails.current_stock;
      _productDetails.photos.forEach((photo) {
        _carouselImageList.add(photo);
      });
      _productDetails.choice_options.forEach((choice_opiton) {
        _selectedChoices.add(choice_opiton.options[0]);
      });
      _productDetails.colors.forEach((color) {
        _colorList.add(color);
      });

      setChoiceString();

      if (_productDetails.colors.length > 0 ||
          _productDetails.choice_options.length > 0) {
        fetchAndSetVariantWiseInfo(change_appbar_string: false);
      }
      _productDetailsFetched = true;

      setState(() {});
    }
  }

  setChoiceString() {
    _choiceString = _selectedChoices.join(",").toString();
    //print(_choiceString);
    setState(() {});
  }

  fetchWishListCheckInfo() async {
    var wishListCheckResponse =
        await WishListRepository().isProductInUserWishList(
      product_id: widget.id,
    );

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  addToWishList() async {
    var wishListCheckResponse =
        await WishListRepository().add(product_id: widget.id);

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  removeFromWishList() async {
    var wishListCheckResponse =
        await WishListRepository().remove(product_id: widget.id);

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  onWishTap() {
    if (is_logged_in.value == false) {
      ToastComponent.showDialog("You need to log in", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    if (_isInWishList) {
      _isInWishList = false;
      setState(() {});
      removeFromWishList();
    } else {
      _isInWishList = true;
      setState(() {});
      addToWishList();
    }
  }

  fetchAndSetVariantWiseInfo({bool change_appbar_string = true}) async {
    var color_string = _colorList.length > 0
        ? _colorList[_selectedColorIndex].toString().replaceAll("#", "")
        : "";

    /*print("color string: "+color_string);
    return;*/

    var variantResponse = await ProductRepository().getVariantWiseInfo(
        id: widget.id, color: color_string, variants: _choiceString);

    /*print("vr"+variantResponse.toJson().toString());
    return;*/

    _singlePrice = variantResponse.price;
    _stock = variantResponse.stock;
    if (_quantity > _stock) {
      _quantity = _stock;
      setState(() {});
    }

    _variant = variantResponse.variant;
    setState(() {});

    calculateTotalPrice();
    _singlePriceString = variantResponse.price_string;

    if (change_appbar_string) {
      _appbarPriceString = "${variantResponse.variant} ${_singlePriceString}";
    }

    setState(() {});
  }

  reset() {
    restProductDetailValues();
    _carouselImageList.clear();
    _colorList.clear();
    _selectedChoices.clear();
    _relatedProducts.clear();
    _topProducts.clear();
    _choiceString = "";
    _variant = "";
    _selectedColorIndex = 0;
    _quantity = 1;
    _productDetailsFetched = false;
    _isInWishList = false;
    setState(() {});
  }

  restProductDetailValues() {
    _appbarPriceString = " . . .";
    _productDetails = null;
    _carouselImageList.clear();
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  calculateTotalPrice() {
    _totalPrice = _singlePrice * _quantity;
    setState(() {});
  }

  _onVariantChange(_choice_options_index, value) {
    _selectedChoices[_choice_options_index] = value;
    setChoiceString();
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  _onColorChange(index) {
    _selectedColorIndex = index;
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  onPressBuyNow(context) {
    addToCart(mode: "buy_now", context: context);
  }

  addToCart({mode, context = null, snackbar = null}) async {
    if (is_logged_in.value == false) {
      ToastComponent.showDialog("You are not logged in", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      return;
    }

    print(widget.id);
    print(_variant);
    print(user_id.value);
    print(_quantity);

    var cartAddResponse = await CartRepository()
        .getCartAddResponse(widget.id, _variant, user_id.value, _quantity);

    if (cartAddResponse.result == false) {
      ToastComponent.showDialog(cartAddResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else {
      if (mode == "add_to_cart") {
        if (snackbar != null && context != null) {
          Scaffold.of(context).showSnackBar(snackbar);
        }
        reset();
        fetchAll();
      } else if (mode == 'buy_now') {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Cart(has_bottomnav: false);
        })).then((value) {
          onPopped(value);
        });
      }
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    SnackBar _addedToCartSnackbar = SnackBar(
      content: Text(
        'Added to cart',
        style: TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'SHOW CART',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Cart(has_bottomnav: false);
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: MyTheme.accent_color,
        disabledTextColor: Colors.grey,
      ),
    );
    return Scaffold(
        bottomNavigationBar: buildBottomAppBar(context, _addedToCartSnackbar),
        backgroundColor: Colors.white,
        appBar: buildAppBar(statusBarHeight, context),
        body: RefreshIndicator(
          color: MyTheme.accent_color,
          backgroundColor: Colors.white,
          onRefresh: _onPageRefresh,
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    0.0,
                    16.0,
                    0.0,
                  ),
                  child: buildProductImageCarouselSlider(),
                ),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      8.0,
                      16.0,
                      0.0,
                    ),
                    child: _productDetails != null
                        ? Text(
                            _productDetails.name,
                            style: TextStyle(
                                fontSize: 16,
                                color: MyTheme.font_grey,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                          )
                        : ShimmerHelper().buildBasicShimmer(
                            height: 30.0,
                          )),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    8.0,
                    16.0,
                    0.0,
                  ),
                  child: _productDetails != null
                      ? buildRatingAndWishButtonRow()
                      : ShimmerHelper().buildBasicShimmer(
                          height: 30.0,
                        ),
                ),
                Divider(
                  height: 24.0,
                ),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    8.0,
                    16.0,
                    0.0,
                  ),
                  child: _productDetails != null
                      ? buildMainPriceRow()
                      : ShimmerHelper().buildBasicShimmer(
                          height: 30.0,
                        ),
                ),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                AddonConfig.club_point_addon_installed
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          8.0,
                          16.0,
                          0.0,
                        ),
                        child: _productDetails != null
                            ? buildClubPointRow()
                            : ShimmerHelper().buildBasicShimmer(
                                height: 30.0,
                              ),
                      )
                    : Container(),
                Divider(
                  height: 24.0,
                ),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                _productDetails != null
                    ? buildChoiceOptionList()
                    : buildVariantShimmers(),
              ])),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    16.0,
                    0.0,
                  ),
                  child: _productDetails != null
                      ? (_colorList.length > 0 ? buildColorRow() : Container())
                      : ShimmerHelper().buildBasicShimmer(
                          height: 30.0,
                        ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    8.0,
                    16.0,
                    0.0,
                  ),
                  child: _productDetails != null
                      ? buildQuantityRow()
                      : ShimmerHelper().buildBasicShimmer(
                          height: 30.0,
                        ),
                ),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    16.0,
                    0.0,
                  ),
                  child: _productDetails != null
                      ? buildTotalPriceRow()
                      : ShimmerHelper().buildBasicShimmer(
                          height: 30.0,
                        ),
                ),
                Divider(
                  height: 24.0,
                ),
              ])),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    0.0,
                    16.0,
                    0.0,
                  ),
                  child: _productDetails != null
                      ? buildSellerRow(context)
                      : ShimmerHelper().buildBasicShimmer(
                          height: 50.0,
                        ),
                ),
                Divider(
                  height: 24,
                ),
              ])),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      0.0,
                      16.0,
                      0.0,
                    ),
                    child: Text(
                      "Descripiton:",
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      8.0,
                      0.0,
                      8.0,
                      8.0,
                    ),
                    child: _productDetails != null
                        ? buildExpandableDescription()
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: ShimmerHelper().buildBasicShimmer(
                              height: 60.0,
                            )),
                  ),
                  Divider(
                    height: 1,
                  ),
                  InkWell(
                    onTap: () {
                      ToastComponent.showDialog("Coming soon", context,
                          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                    },
                    child: Container(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          8.0,
                          0.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Video",
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(
                              Ionicons.ios_add,
                              color: MyTheme.font_grey,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ProductReviews(id:widget.id);
                      })).then((value) {
                        onPopped(value);
                      });
                    },
                    child: Container(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          8.0,
                          0.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Reviews",
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(
                              Ionicons.ios_add,
                              color: MyTheme.font_grey,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CommonWebviewScreen(
                          url:
                              "${AppConfig.RAW_BASE_URL}/mobile-page/sellerpolicy",
                          page_name: "Seller Policy",
                        );
                      }));
                    },
                    child: Container(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          8.0,
                          0.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Seller Policy",
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(
                              Ionicons.ios_add,
                              color: MyTheme.font_grey,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CommonWebviewScreen(
                          url:
                              "${AppConfig.RAW_BASE_URL}/mobile-page/returnpolicy",
                          page_name: "Return Policy",
                        );
                      }));
                    },
                    child: Container(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          8.0,
                          0.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Return Policy",
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(
                              Ionicons.ios_add,
                              color: MyTheme.font_grey,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CommonWebviewScreen(
                          url:
                              "${AppConfig.RAW_BASE_URL}/mobile-page/supportpolicy",
                          page_name: "Support Policy",
                        );
                      }));
                    },
                    child: Container(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          8.0,
                          0.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Support Policy",
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(
                              Ionicons.ios_add,
                              color: MyTheme.font_grey,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      16.0,
                      16.0,
                      0.0,
                    ),
                    child: Text(
                      "Products you may also like",
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      8.0,
                      16.0,
                      0.0,
                      0.0,
                    ),
                    child: buildProductsMayLikeList(),
                  )
                ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      16.0,
                      16.0,
                      0.0,
                    ),
                    child: Text(
                      "Top Selling Products from this seller",
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      16.0,
                      16.0,
                      0.0,
                    ),
                    child: buildTopSellingProductList(),
                  )
                ]),
              )
            ],
          ),
        ));
  }

  Row buildSellerRow(BuildContext context) {
    //print("sl:" + AppConfig.BASE_PATH + _productDetails.shop_logo);
    return Row(
      children: [
        _productDetails.added_by == "admin"
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(
                        color: Color.fromRGBO(112, 112, 112, .3), width: 0.5),
                    //shape: BoxShape.rectangle,
                  ),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: AppConfig.BASE_PATH + _productDetails.shop_logo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        Container(
          width: MediaQuery.of(context).size.width * (.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Seller",
                  style: TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1),
                  )),
              Text(
                _productDetails.shop_name,
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
        Spacer(),
        Visibility(
          visible: false,
          child: Container(
              child: Row(
            children: [
              InkWell(
                onTap: () {
                  ToastComponent.showDialog("Coming soon", context,
                      gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    "Chat with seller",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color.fromRGBO(7, 101, 136, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Icon(Icons.message,
                  size: 16, color: Color.fromRGBO(7, 101, 136, 1))
            ],
          )),
        )
      ],
    );
  }

  Row buildTotalPriceRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              "Total Price:",
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Text(
          _productDetails.currency_symbol + _totalPrice.toString(),
          style: TextStyle(
              color: MyTheme.accent_color,
              fontSize: 18.0,
              fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  Row buildQuantityRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              "Quantity:",
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          height: 36,
          width: 120,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Color.fromRGBO(222, 222, 222, 1), width: 1),
              borderRadius: BorderRadius.circular(36.0),
              color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildQuantityDownButton(),
              Container(
                  width: 36,
                  child: Center(
                      child: Text(
                    _quantity.toString(),
                    style: TextStyle(fontSize: 18, color: MyTheme.dark_grey),
                  ))),
              buildQuantityUpButton()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "(${_stock} available)",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Padding buildVariantShimmers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        0.0,
        8.0,
        0.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildChoiceOptionList() {
    return ListView.builder(
      itemCount: _productDetails.choice_options.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: buildChoiceOpiton(_productDetails.choice_options, index),
        );
      },
    );
  }

  buildChoiceOpiton(choice_options, choice_options_index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        8.0,
        16.0,
        0.0,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 75,
              child: Text(
                choice_options[choice_options_index].title,
                style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
              ),
            ),
          ),
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width - (75 + 40),
            child: Scrollbar(
              controller: _variantScrollController,
              isAlwaysShown: false,
              child: ListView.builder(
                itemCount: choice_options[choice_options_index].options.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: buildChoiceItem(
                        choice_options[choice_options_index].options[index],
                        choice_options_index,
                        index),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  buildChoiceItem(option, choice_options_index, index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          _onVariantChange(choice_options_index, option);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: _selectedChoices[choice_options_index] == option
                    ? MyTheme.accent_color
                    : Color.fromRGBO(224, 224, 225, 1),
                width: 1.5),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                    color: _selectedChoices[choice_options_index] == option
                        ? MyTheme.accent_color
                        : Color.fromRGBO(224, 224, 225, 1),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildColorRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              "Color:",
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width - (75 + 40),
          child: Scrollbar(
            controller: _colorScrollController,
            isAlwaysShown: false,
            child: ListView.builder(
              itemCount: _colorList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: buildColorItem(index),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  buildColorItem(index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          _onColorChange(index);
        },
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedColorIndex == index
                      ? Colors.purple
                      : Colors.white,
                  width: 1),
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromRGBO(222, 222, 222, 1), width: 1),
                  borderRadius: BorderRadius.circular(16.0),
                  color: ColorHelper.getColorFromColorCode(_colorList[index])),
              child: _selectedColorIndex == index
                  ? buildColorCheckerContainer()
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }

  buildColorCheckerContainer() {
    return Padding(
        padding: const EdgeInsets.all(3),
        child: /*Icon(FontAwesome.check, color: Colors.white, size: 16),*/
            Image.asset(
          "assets/white_tick.png",
          width: 16,
          height: 16,
        ));
  }

  Row buildClubPointRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              "Club Point:",
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: MyTheme.golden, width: 1),
              borderRadius: BorderRadius.circular(16.0),
              color: Color.fromRGBO(253, 235, 212, 1)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Text(
              _productDetails.earn_point.toString(),
              style: TextStyle(color: MyTheme.golden, fontSize: 12.0),
            ),
          ),
        )
      ],
    );
  }

  Row buildMainPriceRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              "Price:",
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        _productDetails.has_discount
            ? Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(_productDetails.stroked_price,
                    style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Color.fromRGBO(224, 224, 225, 1),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600)),
              )
            : Container(),
        Text(
          _singlePriceString,
          style: TextStyle(
              color: MyTheme.accent_color,
              fontSize: 18.0,
              fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 32.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: Text(
                _appbarPriceString,
                style: TextStyle(fontSize: 16, color: MyTheme.font_grey),
              ),
            )),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: MyTheme.dark_grey),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  buildBottomAppBar(BuildContext context, _addedToCartSnackbar) {
    return Builder(builder: (BuildContext context) {
      return BottomAppBar(
        child: Container(
          color: Colors.transparent,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                minWidth: MediaQuery.of(context).size.width / 2 - .5,
                height: 50,
                color: MyTheme.golden,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: Text(
                  "Add to Cart",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  onPressAddToCart(context, _addedToCartSnackbar);
                },
              ),
              SizedBox(
                width: 1,
              ),
              FlatButton(
                minWidth: MediaQuery.of(context).size.width / 2 - .5,
                height: 50,
                color: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: Text(
                  "Buy Now",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  onPressBuyNow(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }

  buildRatingAndWishButtonRow() {
    return Row(
      children: [
        RatingBar(
          itemSize: 18.0,
          ignoreGestures: true,
          initialRating: double.parse(_productDetails.rating.toString()),
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          ratingWidget: RatingWidget(
            full: Icon(FontAwesome.star, color: Colors.amber),
            empty:
                Icon(FontAwesome.star, color: Color.fromRGBO(224, 224, 225, 1)),
          ),
          itemPadding: EdgeInsets.only(right: 1.0),
          onRatingUpdate: (rating) {
            //print(rating);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "(" + _productDetails.rating_count.toString() + ")",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 14),
          ),
        ),
        Spacer(),
        _isInWishList
            ? InkWell(
                onTap: () {
                  onWishTap();
                },
                child: Icon(
                  FontAwesome.heart,
                  color: Color.fromRGBO(230, 46, 4, 1),
                  size: 20,
                ),
              )
            : InkWell(
                onTap: () {
                  onWishTap();
                },
                child: Icon(
                  FontAwesome.heart_o,
                  color: Color.fromRGBO(230, 46, 4, 1),
                  size: 20,
                ),
              )
      ],
    );
  }

  ExpandableNotifier buildExpandableDescription() {
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: 50, child: Html(data: _productDetails.description)),
            expanded: Container(child: Html(data: _productDetails.description)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) {
                  var controller = ExpandableController.of(context);
                  return FlatButton(
                    child: Text(
                      !controller.expanded ? "View More" : "Show Less",
                      style: TextStyle(color: MyTheme.font_grey, fontSize: 11),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }

  buildTopSellingProductList() {
    if (_topProductInit == false && _topProducts.length == 0) {
      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
        ],
      );
    } else if (_topProducts.length > 0) {
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: _topProducts.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: ListProductCard(
                id: _topProducts[index].id,
                image: _topProducts[index].thumbnail_image,
                name: _topProducts[index].name,
                price: _topProducts[index].base_price,
              ),
            );
          },
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text("No top selling products from this seller",
                  style: TextStyle(color: MyTheme.font_grey))));
    }
  }

  buildProductsMayLikeList() {
    if (_relatedProductInit == false && _relatedProducts.length == 0) {
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
    } else if (_relatedProducts.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 175,
          child: ListView.builder(
            itemCount: _relatedProducts.length,
            scrollDirection: Axis.horizontal,
            itemExtent: 120,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: MiniProductCard(
                  id: _relatedProducts[index].id,
                  image: _relatedProducts[index].thumbnail_image,
                  name: _relatedProducts[index].name,
                  price: _relatedProducts[index].base_price,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            "No related products",
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  buildQuantityUpButton() => SizedBox(
        width: 36,
        child: IconButton(
            icon: Icon(FontAwesome.plus, size: 16, color: MyTheme.dark_grey),
            onPressed: () {
              if (_quantity < _stock) {
                _quantity++;
                setState(() {});
                calculateTotalPrice();
              }
            }),
      );

  buildQuantityDownButton() => SizedBox(
      width: 36,
      child: IconButton(
          icon: Icon(FontAwesome.minus, size: 16, color: MyTheme.dark_grey),
          onPressed: () {
            if (_quantity > 1) {
              _quantity--;
              setState(() {});
              calculateTotalPrice();
            }
          }));

  buildProductImageCarouselSlider() {
    if (_carouselImageList.length == 0) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 190.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        height: 250,
        width: double.infinity,
        child: CarouselSlider(
          carouselController: _imageCarouselController,
          options: CarouselOptions(
              aspectRatio: 1,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: false,
              reverse: false,
              autoPlay: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImage = index;
                });
              }),
          items: _carouselImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Stack(
                  children: <Widget>[
                    Container(
                        width: double.infinity,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder_rectangle.png',
                          image: AppConfig.BASE_PATH + i,
                          fit: BoxFit.scaleDown,
                        )),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _carouselImageList.map((url) {
                          int index = _carouselImageList.indexOf(url);
                          return Flexible(
                            child: GestureDetector(
                              onTap: () {
                                //print(index);
                                return _imageCarouselController.animateToPage(
                                    index,
                                    curve: Curves.elasticOut);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _currentImage == index
                                          ? MyTheme.accent_color
                                          : Color.fromRGBO(112, 112, 112, .3),
                                      width: _currentImage == index ? 2 : 1),
                                  //shape: BoxShape.rectangle,
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        /*Image.asset(
                                        singleProduct.product_images[index])*/
                                        FadeInImage.assetNetwork(
                                      placeholder: 'assets/placeholder.png',
                                      image: AppConfig.BASE_PATH + url,
                                      fit: BoxFit.contain,
                                    )),
                              ),
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
        ),
      );
    }
  }
}
