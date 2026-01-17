import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. GET ALL PRODUCTS
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. HELPER: Add Sample Data (Expanded)
  Future<void> addDummyData() async {
    final CollectionReference products = _db.collection('products');
    
    // Check if data exists first so we don't duplicate
    // var snapshot = await products.limit(1).get();
    // if (snapshot.docs.isNotEmpty) return;

    List<Map<String, dynamic>> dummyProducts = [
      // --- MAKEUP (6 Items) ---
      {
        "name": "Velvet Red Lipstick",
        "description": "A long-lasting matte lipstick with a rich red hue.",
        "price": 850.00,
        "category": "Makeup",
        "imageUrl": "https://static-01.daraz.lk/p/4a9dc90e43efb4d244edce47b902e24e.jpg",
      },
      {
        "name": "Rose Gold Palette",
        "description": "12 shimmer and matte shades for day and night looks.",
        "price": 1800.00,
        "category": "Makeup",
        "imageUrl": "https://lpagebeauty.com/wp-content/uploads/2023/11/hudarosegoldopen-jpg.webp",
      },
      {
        "name": "Volumizing Mascara",
        "description": "Intense black formula for dramatic lashes.",
        "price": 350.00,
        "category": "Makeup",
        "imageUrl": "https://soneesports.com/cdn/shop/products/2011562912104_1.jpg?v=1660796957",
      },
      {
        "name": "Liquid Foundation",
        "description": "Full coverage foundation with a natural finish.",
        "price": 950.00,
        "category": "Makeup",
        "imageUrl": "https://thesensation.lk/wp-content/uploads/2022/10/main-16-e1666682758172.jpg",
      },
      {
        "name": "Liquid Eyeliner",
        "description": "Waterproof precision liner for the perfect cat eye.",
        "price": 350.00,
        "category": "Makeup",
        "imageUrl": "https://www.inglotpk.com/cdn/shop/products/21_1200x.jpg?v=1755492152",
      },
      {
        "name": "Peachy Blush",
        "description": "Soft powder blush to give you a natural glow.",
        "price": 550.00,
        "category": "Makeup",
        "imageUrl": "https://karabeauty.com/cdn/shop/files/4_eb78345f-64d0-4396-a0c7-13e988ba77ab.png?v=1751317903",
      },

      // --- SKINCARE (4 Items) ---
      {
        "name": "Hydrating Face Serum",
        "description": "Infused with Vitamin C and Hyaluronic Acid.",
        "price": 1450.00,
        "category": "Skincare",
        "imageUrl": "https://image.made-in-china.com/202f0j00qKrcwPTMksbe/Rose-Face-Serum-Moisturizing-Serum-Hydrating-Face-Serum-Rose-Essence-with-Rose-Petals-Extract-Hyaluronic-Acid-Trehalose-B5-Vitamin-Alcohol-Free-Facial.webp",
      },
      {
        "name": "Daily Moisturizer",
        "description": "Lightweight, non-greasy formula for all skin types.",
        "price": 500.00,
        "category": "Skincare",
        "imageUrl": "https://pyxis.nymag.com/v1/imgs/f00/80e/91646303f15cd076394958b941e3c3e6f5.rsquare.w600.jpg",
      },
      {
        "name": "Foaming Cleanser",
        "description": "Gentle face wash that removes dirt and oil.",
        "price": 1250.00,
        "category": "Skincare",
        "imageUrl": "https://static.beautytocare.com/cdn-cgi/image/f=auto/media/catalog/product//c/e/cerave-foaming-cleanser-normal-to-oily-skin-236ml_3.jpg",
      },
      {
        "name": "Night Repair Cream",
        "description": "Rich cream to rejuvenate skin while you sleep.",
        "price": 750.00,
        "category": "Skincare",
        "imageUrl": "https://heavenlyhome.in/wp-content/uploads/2023/09/NIGHT-REPAIR-CREAM.webp",
      },

      // --- PERFUME (2 Items) ---
      {
        "name": "Floral Eau de Parfum",
        "description": "A fresh blend of jasmine, rose, and citrus.",
        "price": 2500.00,
        "category": "Perfume",
        "imageUrl": "https://pics.walgreens.com/prodimg/658123/900.jpg",
      },
      {
        "name": "Midnight Musk Cologne",
        "description": "Deep woody notes with a hint of vanilla.",
        "price": 3000.00,
        "category": "Perfume",
        "imageUrl": "https://wholesale.intenseoud.com/cdn/shop/files/1_d1849ae3-1da0-4126-921e-14b393fa33d9_1024x1024.jpg?v=1726346497",
      },
    ];

    for (var p in dummyProducts) {
      await products.add(p);
    }
  }

  // 3. PLACE ORDER
  Future<void> placeOrder(
    String userId,
    double total,
    List<dynamic> items,
  ) async {
    await _db.collection('orders').add({
      'userId': userId,
      'total': total,
      'status': 'Pending',
      'date': Timestamp.now(),
      'items': items,
    });
  }

  // 4. GET MY ORDERS
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // 5. ADD TO WISHLIST
  Future<void> addToWishlist(String userId, Product product) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id)
        .set(product.toMap());
  }

  // 6. REMOVE FROM WISHLIST
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  // 7. GET MY WISHLIST
  Stream<List<Product>> getWishlist(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // 8. ADD REVIEW
  Future<void> addReview(String productId, ReviewModel review) async {
    await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .add(review.toMap());
  }

  // 9. GET REVIEWS FOR A PRODUCT
  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReviewModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}