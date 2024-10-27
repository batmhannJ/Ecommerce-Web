import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/widget/buttons/custom_filled_button.dart';
import 'package:indigitech_shop/widget/product_list.dart';
import 'package:indigitech_shop/services/product_api_service.dart';
import 'package:indigitech_shop/model/product.dart';

class ShopTabView extends StatefulWidget {
  const ShopTabView({Key? key}) : super(key: key);

  @override
  State<ShopTabView> createState() => _ShopTabViewState();
}

class _ShopTabViewState extends State<ShopTabView>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _newCollectionsKey = GlobalKey();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductApiService.fetchProducts();
  }

  void _scrollToNewCollections() {
    final context = _newCollectionsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              const Color(0xfff8e2fb),
              const Color(0xfff8f3f9),
              const Color(0xffd0d5d1),
              AppColors.primary,
              AppColors.primary.withOpacity(.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const <double>[
              .03,
              .1,
              .225,
              .275,
              1,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ... (rest of the UI code remains the same)

            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No products available');
                }

                List<Product> allProducts = snapshot.data!;
                List<Product> newProducts =
                    allProducts.where((product) => product.isNew).toList();

                return Column(
                  children: [
                    SearchProductsWidget(products: allProducts),
                    const Gap(20),
                    CustomButton(
                      text: "Explore Latest Collection",
                      textStyle: AppTextStyles.button.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      command: _scrollToNewCollections,
                      height: 48,
                      fillColor: AppColors.red,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 30),
                      borderRadius: 30,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                      iconPadding: 8,
                    ),
                    const Gap(40),
                    Padding(
                      key: _newCollectionsKey,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Text(
                            "NEW COLLECTIONS",
                            style: AppTextStyles.headline5.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 100,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                color: AppColors.black,
                                height: 0,
                                thickness: 3,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: newProducts.length,
                            itemBuilder: (context, index) {
                              final product = newProducts[index];
                              return ListTile(
                                title: Text(product.name),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchProductsWidget extends StatefulWidget {
  final List<Product> products;

  const SearchProductsWidget({Key? key, required this.products})
      : super(key: key);

  @override
  _SearchProductsWidgetState createState() => _SearchProductsWidgetState();
}

class _SearchProductsWidgetState extends State<SearchProductsWidget> {
  String _searchQuery = '';
  List<Product> _filteredProducts = [];

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = widget.products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _filterProducts,
          decoration: const InputDecoration(
            labelText: 'Search Products',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: _searchQuery.isEmpty ? 0 : _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ListTile(
                title: Text(product.name),
                onTap: () {
                  // Handle product selection here
                  print('Selected product: ${product.name}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
