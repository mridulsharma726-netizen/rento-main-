import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Two-state filter: maintain original data separately
  List<ProductModel> _allProducts =
      []; // Original data - never modified by filter
  List<ProductModel> _filteredProducts = []; // Display data - filtered view
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _errorCode;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  int _offset = 0;
  bool _hasMore = true;
  static const int _limit = 20;

  // Return filtered products for display
  List<ProductModel> get products => _filteredProducts;
  // Getter for all products (original)
  List<ProductModel> get allProducts => _allProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String? get errorCode => _errorCode;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;

  // Apply category filter to display
  void _applyFilter() {
    final selectedCategory = _selectedCategory.toLowerCase();
    final query = _searchQuery.trim().toLowerCase();

    _filteredProducts = _allProducts.where((product) {
      final categoryMatches = selectedCategory == 'all' ||
          product.category.toLowerCase() == selectedCategory;
      final searchMatches = query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return categoryMatches && searchMatches;
    }).toList();

    notifyListeners();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      _allProducts = [];
      _filteredProducts = [];
    }
    if (!_hasMore && !refresh) return;
    if (_isLoading || _isLoadingMore) return;

    if (_offset == 0) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      // Always fetch ALL products, filter locally
      final res = await _api.getProducts(
        category: null, // Get all products, filter locally
        limit: _limit,
        offset: _offset,
      );
      final list = (res['products'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (refresh) {
        _allProducts = list;
      } else {
        _allProducts.addAll(list);
      }
      // Apply filter to display
      _applyFilter();
      _hasMore = list.length == _limit;
      _offset += list.length;
    } on ApiException catch (e) {
      _error = e.message;
      _errorCode = e.code;
    } catch (_) {
      _error = 'Failed to load products';
      _errorCode = null;
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadProduct(String id) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();
    try {
      final res = await _api.getProduct(id);
      final data = res['product'] as Map<String, dynamic>? ??
          res['data'] as Map<String, dynamic>? ??
          res;
      _selectedProduct = ProductModel.fromJson(data);
    } on ApiException catch (e) {
      _error = e.message;
      _errorCode = e.code;
    } catch (_) {
      _error = 'Failed to load product';
      _errorCode = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> createProduct(Map<String, dynamic> data,
      {List<int>? imageBytes, String? imageName}) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();
    try {
      final res = await _api.createProduct(data,
          imageBytes: imageBytes, imageName: imageName);
      final product =
          ProductModel.fromJson(res['product'] as Map<String, dynamic>);
      _allProducts.insert(0, product);
      _applyFilter();
      return product;
    } on ApiException catch (e) {
      _error = e.message;
      _errorCode = e.code;
      return null;
    } catch (_) {
      _error = 'Failed to create product';
      _errorCode = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> _myProducts = [];
  List<ProductModel> get myProducts => _myProducts;

  Future<void> loadMyProducts() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();
    try {
      final res = await _api.getMyProducts();
      _myProducts = (res['products'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
      _errorCode = e.code;
    } catch (_) {
      _error = 'Failed to load your products';
      _errorCode = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();
    try {
      await _api.deleteProduct(id);
      _allProducts.removeWhere((p) => p.id == id);
      _myProducts.removeWhere((p) => p.id == id);
      _applyFilter();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _errorCode = e.code;
      return false;
    } catch (_) {
      _error = 'Failed to delete product';
      _errorCode = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    // Filter from ALL original data, not just filtered data
    _applyFilter();
  }

  void setSearchQuery(String query) {
    final normalized = query.trimLeft();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    _applyFilter();
  }

  void clearSelected() => _selectedProduct = null;
  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }
}
