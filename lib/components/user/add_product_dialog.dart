import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/model/category_model.dart';
import 'package:rechoice_app/models/services/local_storage_service.dart';
import 'package:rechoice_app/models/viewmodels/category_view_model.dart';
import 'package:rechoice_app/models/viewmodels/items_view_model.dart';

class AddProductDialog extends StatefulWidget {
  final int userId;

  const AddProductDialog({super.key, required this.userId});

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
  bool _isSubmitting = false;

  final _conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];

  List<ItemCategoryModel> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _brandCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categoryVM = context.read<CategoryViewModel>();

    if (categoryVM.categories.isEmpty) {
      await categoryVM.fetchCategories();
    }

    if (mounted) {
      setState(() {
        _categories = categoryVM.categories.isNotEmpty
            ? categoryVM.categories
            : _getFallbackCategories();
        _loadingCategories = false;
      });
    }
  }

  List<ItemCategoryModel> _getFallbackCategories() {
    return [
      ItemCategoryModel(
        categoryID: 1,
        name: 'Electronics',
        iconName: 'electronics',
      ),
      ItemCategoryModel(categoryID: 2, name: 'Clothing', iconName: 'clothing'),
      ItemCategoryModel(categoryID: 3, name: 'Books', iconName: 'books'),
      ItemCategoryModel(categoryID: 4, name: 'Home & Garden', iconName: 'home'),
      ItemCategoryModel(categoryID: 5, name: 'Sports', iconName: 'sports'),
    ];
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
    

      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_category == null) {
      _showError('Please select a category');
      return;
    }
    if (_condition == null) {
      _showError('Please select a condition');
      return;
    }
    if (_image == null) {
      _showError('Please add a product image');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final vm = context.read<ItemsViewModel>();

      final item = Items(
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
        sellerID: widget.userId, // replace with auth user id
        moderationStatus: ModerationStatus.pending,
      );

      final itemId = await vm.createItemWithImage(item, _image!);

      if (itemId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Failed to add item')),
        );

        setState(() => _isSubmitting = false);
        return;
      }
      print('Item created with ID: $itemId');
      // DEBUG
      try {
        final localStorage = Provider.of<LocalStorageService>(
          context,
          listen: false,
        );

        if (!await _image!.exists()) {
          print('ERROR: Image file no longer exists at ${_image!.path}');
          throw Exception('Image file not found');
        }

        final savedPath = await localStorage.saveItemImage(
          _image!,
          itemId.toString(),
        );
        print('Image saved locally with item ID: $itemId, at $savedPath');
      } catch (e, stackTrace) {
        print('Warning: Failed to save image locally: $e');
        print('Stack trace: $stackTrace');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      print('ERROR in _submit: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      _showError('Error: $e');
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      elevation: 20,
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black26,
              blurRadius: 25,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loadingCategories
                  ? Center(child: CircularProgressIndicator())
                  : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _imagePicker(),
            const SizedBox(height: 20),
            _field(_titleCtrl, 'Title'),
            _categoryDropdown(),
            _field(_brandCtrl, 'Brand'),
            _conditionDropdown(),
            Row(
              children: [
                Expanded(child: _field(_qtyCtrl, 'Quantity', number: true)),
                const SizedBox(width: 12),
                Expanded(child: _field(_priceCtrl, 'Price', decimal: true)),
              ],
            ),
            _field(_descCtrl, 'Description', lines: 3),
            const SizedBox(height: 24),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Add Product',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey.shade600,
            hoverColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Product'),
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        enabled: !_isSubmitting,
        maxLines: lines,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : number
            ? TextInputType.number
            : TextInputType.text,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';

          if (number || decimal) {
            final parsed = decimal ? double.tryParse(v) : int.tryParse(v);
            if (parsed == null) return 'Invalid number';
            if (parsed <= 0) return 'Must be greater than 0';
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixText: decimal ? '\RM ' : null,
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<ItemCategoryModel>(
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        initialValue: _category,
        validator: (v) => v == null ? 'Required' : null,
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
            .toList(),
        onChanged: _isSubmitting ? null : (v) => setState(() => _category = v),
      ),
    );
  }

  Widget _conditionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Condition',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        initialValue: _condition,
        validator: (v) => v == null ? 'Required' : null,
        items: _conditions
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: _isSubmitting ? null : (v) => setState(() => _condition = v),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: _image == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add image',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _image!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image error'));
                  },
                ),
              ),
      ),
    );
  }
}
