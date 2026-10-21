import 'package:flutter/material.dart';
import 'wardrobe_service.dart';
import 'product_service.dart';

class FavoriteItem {
  final String id;
  final String brand;
  final String name;
  final String price;
  final String size;
  final String fitMatch;
  final String imagePath;

  FavoriteItem({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.size,
    required this.fitMatch,
    required this.imagePath,
  });

  factory FavoriteItem.fromWardrobe(WardrobeItem w) {
    return FavoriteItem(
      id: w.productId.isNotEmpty ? w.productId : w.id,
      brand: w.productBrand,
      name: w.productName,
      price: w.productPrice,
      size: w.recSize,
      fitMatch: w.fitPercent,
      imagePath: w.productImage,
    );
  }
}

class FavoritesManager {
  static final FavoritesManager instance = FavoritesManager._internal();
  FavoritesManager._internal() {
    // Listen to WardrobeService so FavoritesManager is always 100% in sync
    WardrobeService.instance.wardrobeItemsNotifier.addListener(_syncFromWardrobe);
    _syncFromWardrobe();
  }

  final ValueNotifier<List<FavoriteItem>> favoriteItemsNotifier = ValueNotifier<List<FavoriteItem>>([]);

  void _syncFromWardrobe() {
    final wardrobeItems = WardrobeService.instance.wardrobeItemsNotifier.value;
    favoriteItemsNotifier.value = wardrobeItems.map((w) => FavoriteItem.fromWardrobe(w)).toList();
  }

  bool isFavorite(String id, {String? name}) {
    return WardrobeService.instance.isInWardrobe(id, productName: name);
  }

  void toggleFavorite(BuildContext context, FavoriteItem item) {
    final product = ProductModel(
      id: item.id,
      name: item.name,
      brand: item.brand,
      category: 'Vêtements',
      subCategory: '',
      gender: 'Femme',
      description: '',
      price: double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      isSale: false,
      imageUrl: item.imagePath,
      galleryImages: [item.imagePath],
      availableSizes: [item.size],
      availableColors: const [{'name': 'Couleur', 'hex': '#172554'}],
      recSize: item.size,
      fitPercent: item.fitMatch,
      fabricComposition: 'Matière Noble',
      silhouetteType: '',
      careInstructions: '',
      isFeatured: false,
      isTrending: false,
      isNewArrival: false,
      triedCountText: '',
      badge: item.fitMatch,
      badgeColor: '#16A34A',
      badgeBg: '#ECFDF5',
      inStock: true,
      stockQuantity: 1,
      partnerStoreName: '',
      partnerStoreUrl: '',
      storeReservationAvailable: false,
    );

    WardrobeService.instance.toggleWardrobe(product, context);
  }
}
