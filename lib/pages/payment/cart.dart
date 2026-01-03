import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/cart/cart_card.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';

class CartPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const CartPage({super.key, this.onBackPressed});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, viewModel, child) {
        final product = viewModel.cartItems;
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              // Header Section with Blue Background
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF2196F3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (widget.onBackPressed != null) {
                                widget.onBackPressed!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        const Text(
                          'My Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${viewModel.uniqueItemCount} Items',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Content Section
              Expanded(
                child: product.isEmpty
                    ? _buildEmptyCart()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Delivery Address Card
                              _buildAddressCard(),
                              const SizedBox(height: 20),

                              // Cart Items
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return CartCard(cartItems: product[index]);
                                },
                                itemCount: product.length,
                              ),
                              const SizedBox(height: 24),

                              // Order Summary Card
                              _buildOrderSummary(viewModel.grandTotalPrice),
                            ],
                          ),
                        ),
                      ),
              ),
              // Bottom Checkout Section
              if (product.isNotEmpty)
                _buildCheckoutBar(context, viewModel.grandTotalPrice),
            ],
          ),
        );
      },
    );
  }
}

// Empty Cart Widget
Widget _buildEmptyCart() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_cart_checkout_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
        Text(
          'Your Cart is Empty',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

// Address Card widget
Widget _buildAddressCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade50,
          spreadRadius: 2,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Text(
              '(+60)1234567890',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            'Allamanda College,Universiti Malaysia Sarawak 94300,Kota Samarahan,Sarawak',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

//Order Summary Card
Widget _buildOrderSummary(double subtotal) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          spreadRadius: 2,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              'RM${subtotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Divider(color: Colors.grey[300], thickness: 1),
        const SizedBox(height: 20),
        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'RM${subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildCheckoutBar(BuildContext context, double totalAmount) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total Amount',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'RM${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/payment');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
