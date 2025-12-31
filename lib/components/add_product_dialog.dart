import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/model/category_model.dart';
import 'package:rechoice_app/models/viewmodels/items_view_model.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  ItemCategoryModel? _category;
  String? _condition;
  File? _image;

  final _picker = ImagePicker();

  final _conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];

  final List<ItemCategoryModel> _categories = [
    ItemCategoryModel(
      categoryID: 1,
      name: 'Electronics',
      iconName: 'electronics',
    ),
    ItemCategoryModel(categoryID: 2, name: 'Clothing', iconName: 'clothing'),
    ItemCategoryModel(categoryID: 3, name: 'Books', iconName: 'books'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _brandCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _image = File(file.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _condition == null) return;

    final vm = context.read<ItemsViewModel>();

    final item = Items(
      // itemID is meaningless here – Firestore generates ID
      itemID: 0,
      title: _titleCtrl.text.trim(),
      category: _category!,
      brand: _brandCtrl.text.trim(),
      condition: _condition!,
      price: double.parse(_priceCtrl.text),
      quantity: int.parse(_qtyCtrl.text),
      description: _descCtrl.text.trim(),
      status: 'available',
      imagePath: _image?.path ?? '',
      postedDate: DateTime.now(),
      sellerID: 1, // replace with auth user id
      moderationStatus: ModerationStatus.pending,
    );

    final itemId = await vm.createItem(item);

    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Failed to add item')),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_titleCtrl, 'Title'),
                _categoryDropdown(),
                _field(_brandCtrl, 'Brand'),
                _conditionDropdown(),
                _field(_qtyCtrl, 'Quantity', number: true),
                _field(_priceCtrl, 'Price', decimal: true),
                _imagePicker(),
                _field(_descCtrl, 'Description', lines: 3),
                const SizedBox(height: 16),
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    return Consumer<ItemsViewModel>(
      builder: (_, vm, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: vm.isLoading ? null : _submit,
              child: vm.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    int lines = 1,
    bool number = false,
    bool decimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: lines,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : number
            ? TextInputType.number
            : TextInputType.text,
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<ItemCategoryModel>(
        decoration: const InputDecoration(labelText: 'Category'),
        value: _category,
        validator: (v) => v == null ? 'Required' : null,
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
            .toList(),
        onChanged: (v) => setState(() => _category = v),
      ),
    );
  }

  Widget _conditionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Condition'),
        value: _condition,
        validator: (v) => v == null ? 'Required' : null,
        items: _conditions
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => setState(() => _condition = v),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: _image == null
            ? const Center(child: Text('Tap to add image'))
            : Image.file(_image!, fit: BoxFit.cover),
      ),
    );
  }
}
