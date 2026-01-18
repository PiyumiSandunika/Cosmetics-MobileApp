import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/product_model.dart';
import '../auth/login_screen.dart';
import 'product_card.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  final dbService = DatabaseService();

  // STATE VARIABLES
  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> categories = ["All", "Makeup", "Skincare", "Perfume"];

  @override
  Widget build(BuildContext context) {
    // Define primary color from theme
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 201, 220), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Left-aligned title is more modern
        title: const Text(
          "Glow Catalog",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800, // Extra Bold
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        // 2. Modern thin divider line instead of shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
        actions: [
          // Cart Icon
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          // Orders Icon
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
          // Wishlist Icon (FILLED RED as requested)
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
          // Logout Icon
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8), // Little extra padding at the end
        ],
      ),
      body: Column(
        children: [
          // 3. Search & Categories Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 228, 218, 225),
                    borderRadius: BorderRadius.circular(12),
                    // Soft shadow for depth
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 130, 127, 127)),
                      prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 130, 127, 127)),
                      border: InputBorder.none, // Removes default underline
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // CATEGORY CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: Colors.grey.shade50,
                          // Modern minimal border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : Colors.grey.shade200,
                            ),
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 4. Product Grid
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: dbService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          "No products found.",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final allProducts = snapshot.data!;

                // FILTER LOGIC
                final filteredProducts = allProducts.where((product) {
                  final matchesSearch = product.name.toLowerCase().contains(
                    searchQuery,
                  );
                  final matchesCategory =
                      selectedCategory == "All" ||
                      product.category == selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text("No items match your search."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16), // Outer padding
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16, // Increased spacing between columns
                    mainAxisSpacing: 16,  // Increased spacing between rows
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: filteredProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}