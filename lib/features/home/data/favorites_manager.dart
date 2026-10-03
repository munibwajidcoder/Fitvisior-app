import 'package:flutter/material.dart';

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
}

class FavoritesManager {
  static final FavoritesManager instance = FavoritesManager._internal();
  FavoritesManager._internal();

  final ValueNotifier<List<FavoriteItem>> favoriteItemsNotifier = ValueNotifier([
    FavoriteItem(
      id: 'balmain_blazer',
      brand: "BALMAIN",
      name: "Blazer en Laine Grain de Poudre",
      price: "2.190 €",
      size: "FR 38",
      fitMatch: "98% Fit",
      imagePath: 'assets/images/hero_banner.jpg',
    ),
    FavoriteItem(
      id: 'the_row_slip',
      brand: "THE ROW",
      name: "Robe Longue en Soie Amalia",
      price: "1.650 €",
      size: "Taille S",
      fitMatch: "99% Fit",
      imagePath: 'assets/images/product_dress.jpg',
    ),
    FavoriteItem(
      id: 'bottega_pants',
      brand: "BOTTEGA VENETA",
      name: "Pantalon en Laine Plissé",
      price: "1.200 €",
      size: "IT 40",
      fitMatch: "96% Fit",
      imagePath: 'assets/images/product_pants.jpg',
    ),
    FavoriteItem(
      id: 'saint_laurent_trench',
      brand: "SAINT LAURENT",
      name: "Trench en Vinyle Ceinturé",
      price: "2.950 €",
      size: "FR 36",
      fitMatch: "94% Fit",
      imagePath: 'assets/images/product_suit.jpg',
    ),
    FavoriteItem(
      id: 'jacquemus_bahia',
      brand: "JACQUEMUS",
      name: "La Robe Bahia Drapée",
      price: "690 €",
      size: "FR 36",
      fitMatch: "97% Fit",
      imagePath: 'assets/images/product_sweater.jpg',
    ),
    FavoriteItem(
      id: 'toteme_coat',
      brand: "TOTEME",
      name: "Manteau Laine & Cachemire",
      price: "1.150 €",
      size: "Taille 8",
      fitMatch: "95% Fit",
      imagePath: 'assets/images/pose_profile.jpg',
    ),
  ]);

  bool isFavorite(String id, {String? name}) {
    final cleanId = id.toLowerCase().trim();
    final cleanName = name?.toLowerCase().trim();
    return favoriteItemsNotifier.value.any((item) {
      if (item.id.toLowerCase().trim() == cleanId) return true;
      if (cleanName != null && item.name.toLowerCase().contains(cleanName)) return true;
      if (cleanName != null && cleanName.contains(item.name.toLowerCase())) return true;
      return false;
    });
  }

  void toggleFavorite(BuildContext context, FavoriteItem item) {
    final current = List<FavoriteItem>.from(favoriteItemsNotifier.value);
    final cleanId = item.id.toLowerCase().trim();
    final cleanName = item.name.toLowerCase().trim();

    final index = current.indexWhere((i) {
      if (i.id.toLowerCase().trim() == cleanId) return true;
      if (i.name.toLowerCase().trim() == cleanName) return true;
      return false;
    });

    bool added = false;
    if (index >= 0) {
      current.removeAt(index);
      added = false;
    } else {
      current.insert(0, item);
      added = true;
    }
    favoriteItemsNotifier.value = current;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              added ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                added
                    ? "« ${item.name} » ajouté aux Favoris"
                    : "« ${item.name} » retiré des Favoris",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: added ? const Color(0xFFE11D48) : const Color(0xFF172554),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

