import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Access the primary color for consistency
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute( 
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Smooth rounded corners
          border: Border.all(color: Colors.grey.shade100), // Subtle border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Very soft shadow
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE SECTION
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background placeholder color
                    Container(color: Colors.grey.shade50),
                    // The Image
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(
                            child: Icon(
                              Icons.image_not_supported_outlined, 
                              color: Colors.grey.shade300
                            )
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, // Semi-bold is cleaner
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 6),

                  // Price Tag
                  Text(
                    "Rs. ${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w800, // Extra bold for price
                      fontSize: 15,
                    ),
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