import 'package:flutter/material.dart';
import 'package:rechoice_app/models/items_model.dart';
import 'package:rechoice_app/services/dummy_data.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  int _quantity = 1;
  bool _isFavourite = false;
  late Items currentItem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract argument here
    currentItem = ModalRoute.of(context)!.settings.arguments as Items;
  }

  @override
  void initState() {
    super.initState();
    currentItem = DummyData.getFeaturedProducts()[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //App Bar
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              iconSize: 20,
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                iconSize: 20,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1), // Colors.blue[900]
                Color(0xFF1976D2), // Colors.blue[700]
                Color(0xFF2196F3), // Colors.blue[500]
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      //Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Items image
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    currentItem.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Spacing
              // Row nama product icon love
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentItem.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _isFavourite = !_isFavourite;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 1),

              // Price
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RM ${currentItem.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //Option
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Option',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              //Option buttons
              const SizedBox(height: 16),
              // Row dengan 3 container
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(child: _CategoryButton(label: 'iPad Air')),
                  SizedBox(width: 8),
                  Expanded(child: _CategoryButton(label: 'iPad Pro')),
                  SizedBox(width: 8),
                  Expanded(child: _CategoryButton(label: 'iPad Mini')),
                ],
              ),
              const SizedBox(height: 16),

              //Quantity
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 1),

              // Quantity buttons
              _QuantitySelector(
                quantity: _quantity,
                onChanged: (newQuantity) {
                  setState(() {
                    _quantity = newQuantity;
                  });
                },
                maxQuantity: currentItem.quantity,
              ),

              const SizedBox(height: 16),

              //Description
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentItem.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      //Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 2 ikon kiri
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.smart_toy),
                  iconSize: 28,
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message),
                  iconSize: 28,
                  color: Colors.blue,
                ),
              ],
            ),
            // 2 item kanan
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  iconSize: 28,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//class option button
class _CategoryButton extends StatelessWidget {
  final String label;

  const _CategoryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade700,
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

//class quantity button
class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;
  final int maxQuantity;

  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
    required this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: quantity > 1 ? Colors.blue : Colors.grey,
          iconSize: 32,
        ),
        const SizedBox(width: 16),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: quantity < maxQuantity
              ? () => onChanged(quantity + 1)
              : null,
          icon: const Icon(Icons.add_circle_outline),
          color: quantity < maxQuantity ? Colors.blue : Colors.grey,
          iconSize: 32,
        ),
      ],
    );
  }
}
