import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the cart data
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Shopping Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20,)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty! Time to shop."))
          : Column(
              children: [
                // LIST OF ITEMS
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return ListTile(
                        leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(product.name),
                        subtitle: Text("Rs.${product.price.toStringAsFixed(2)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            cart.removeFromCart(product);
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // TOTAL AND CHECKOUT BUTTON
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Rs.${cart.totalPrice.toStringAsFixed(2)}", 
                               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green for money/checkout
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("CHECKOUT NOW", style: TextStyle(fontSize: 18, color: Colors.white)),
                          onPressed: () async {
                            // 1. Get the current user
                            final user = FirebaseAuth.instance.currentUser;
                            
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please login to checkout")),
                              );
                              return;
                            }

                            // 2. Prepare the items list for database
                            // We only save the name and price to keep it simple
                            final orderItems = cart.items.map((item) => {
                              'name': item.name,
                              'price': item.price,
                              'imageUrl': item.imageUrl,
                            }).toList();

                            // 3. Save to Firebase
                            await DatabaseService().placeOrder(
                              user.uid, 
                              cart.totalPrice, 
                              orderItems
                            );

                            // 4. Clear the local cart
                            cart.clearCart();

                            // 5. Show success and maybe go to Orders screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Order Placed Successfully!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color.fromARGB(255, 32, 170, 165),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 3),
                              ),
                            );

                            // Optional: Navigator.pop(context); // Go back to home
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}