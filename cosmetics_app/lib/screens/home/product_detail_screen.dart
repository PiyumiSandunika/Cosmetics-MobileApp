import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart'; // Import Review Model
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  // Helper to show the "Write Review" Dialog with Clickable Stars
  void _showReviewDialog(BuildContext context) {
    final commentCtrl = TextEditingController();
    double selectedRating = 0.0; // Default starts at 5

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder allows us to update the stars INSIDE the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Write a Review", style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Tap a star to rate:"),
                  const SizedBox(height: 10),

                  // INTERACTIVE STARS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          // If index is less than rating, show filled star
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          // Update the rating when clicked
                          setState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      hintText: "Your comment...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && commentCtrl.text.isNotEmpty) {
                      final newReview = ReviewModel(
                        id: '',
                        userName: user.email!.split('@')[0],
                        rating: selectedRating, // Now uses the selected stars!
                        comment: commentCtrl.text.trim(),
                        date: DateTime.now(),
                      );

                      await DatabaseService().addReview(product.id, newReview);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Review Added!")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
    extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        // REPLACE THE ENTIRE actions: [] BLOCK WITH THIS:
        actions: [
          StreamBuilder<List<Product>>(
            stream: dbService.getWishlist(FirebaseAuth.instance.currentUser?.uid ?? ""),
            builder: (context, snapshot) {
              // Check if THIS product is currently in the wishlist data
              bool isInWishlist = false;
              if (snapshot.hasData) {
                isInWishlist = snapshot.data!.any((p) => p.id == product.id);
              }

              return IconButton(
                // Toggle icon: Filled if true, Border if false
                icon: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border),
                // Toggle color: Red if true, Pink if false
                color: isInWishlist ? const Color.fromARGB(255, 194, 29, 18) : const Color(0xFFFF82AB),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    if (isInWishlist) {
                      // Remove it
                      await dbService.removeFromWishlist(user.uid, product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Removed from Wishlist", style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                            backgroundColor: const Color.fromARGB(255, 145, 36, 72),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                      );
                    } else {
                      // Add it
                      await dbService.addToWishlist(user.uid, product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Added to Wishlist!", style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                          backgroundColor: const Color.fromARGB(255, 145, 36, 72),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. IMAGE
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),

            // 2. PRODUCT INFO
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "Rs. ${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // ADD TO CART BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        "ADD TO CART",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        context.read<CartProvider>().addToCart(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${product.name} added to cart!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            backgroundColor: const Color.fromARGB(255, 32, 170, 165),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },

                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),

                  // 3. REVIEWS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Write Review"),
                        onPressed: () => _showReviewDialog(context),
                      ),
                    ],
                  ),

                  // REVIEWS LIST
                  StreamBuilder<List<ReviewModel>>(
                    stream: dbService.getProductReviews(product.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      // <--- CHANGE 1: If empty, SHOW THE TEXT AGAIN
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            "No reviews yet. Be the first!",
                            style: TextStyle(
                              color: Color.fromARGB(255, 137, 134, 134),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true, 
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(), 
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final review = snapshot.data![index];
                          
                          // <--- CHANGE 2: Added Container with Color
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10), // Spacing between reviews
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 243, 197, 215),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color.fromARGB(255, 237, 139, 173)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromARGB(255, 243, 96, 154),
                                child: Icon(Icons.person, color: Colors.grey.shade400),
                              ),
                              title: Text(
                                review.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(review.comment),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      review.rating.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
