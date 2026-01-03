// Quantity Selector Widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/dashboard/quantity_button.dart';
import 'package:rechoice_app/models/model/cart_model.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';

class QuantitySelector extends StatelessWidget {
  final CartItem cartItem;

  const QuantitySelector({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final CartViewModel cartViewModel = Provider.of<CartViewModel>(
      context,
      listen: false,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button minus
          QuantityButton(
            icon: Icons.remove,
            onPressed: () => cartViewModel.decreaseQuantity(cartItem.items),
          ),
          Text(
            '${cartItem.quantity}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          // Button plus
          QuantityButton(
            icon: Icons.add,
            onPressed: () => cartViewModel.addToCart(cartItem.items),
          ),
        ],
      ),
    );
  }
}
