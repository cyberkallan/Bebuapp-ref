import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:talk_in/main.dart';

import 'iap_callback.dart';
import 'iap_receipt_data.dart';

class InAppPurchaseHelper {
  static final InAppPurchaseHelper _inAppPurchaseHelper = InAppPurchaseHelper._internal();

  InAppPurchaseHelper._internal();

  factory InAppPurchaseHelper() {
    return _inAppPurchaseHelper;
  }

  num discountAmount = 0;
  num discountPercentage = 0;
  String date = "";
  String time = "";
  double rupee = 0;
  int withoutTaxRupee = 0;
  String serviceId = "";
  String expertId = "";
  String userId = "";
  String paymentType = "";
  Callback onComplete = () {};
  List<String> productId = [];

  init({
    required double rupee,
    required String userId,
    required String paymentType,
    required List<String> productKey,
    required Callback callBack,
  }) {
    this.rupee = rupee;
    this.userId = userId;
    this.paymentType = paymentType;
    productId = productKey;
    onComplete = () => callBack.call();
  }

  final InAppPurchase _connection = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  IAPCallback? _iapCallback;

  initialize() {
    if (Platform.isAndroid) {
      // FIXED: The enablePendingPurchases() method has been deprecated and removed
      // Pending purchases are now enabled by default in newer versions
      // No action needed for Android initialization
      log("Android IAP initialized - pending purchases enabled by default");
    } else {
      SKPaymentQueueWrapper().restoreTransactions();
    }
  }

  ProductDetails? getProductDetail(String productID) {
    for (ProductDetails item in _products) {
      if (item.id == productID) {
        return item;
      }
    }
    return null;
  }

  List<String> getAvailableProducts() {
    return _products.map((product) => product.id).toList();
  }

  Future<void> debugProductLoading() async {
    log("=== IAP Debug Info ===");
    log("Product IDs to query: $productId");

    final bool isAvailable = await _connection.isAvailable();
    log("Store available: $isAvailable");

    if (!isAvailable) return;

    Set<String> productIds = productId.toSet();
    ProductDetailsResponse response = await _connection.queryProductDetails(productIds);

    log("Query error: ${response.error}");
    log("Products found: ${response.productDetails.length}");
    log("Not found product IDs: ${response.notFoundIDs}");

    for (var product in response.productDetails) {
      log("Found product: ${product.id} - ${product.title} - ${product.price}");
    }

    for (var notFound in response.notFoundIDs) {
      log("Not found product: $notFound");
    }
  }

  getAlreadyPurchaseItems(IAPCallback iapCallback) {
    _iapCallback = iapCallback;
    final Stream<List<PurchaseDetails>> purchaseUpdated = _connection.purchaseStream;
    _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          if (purchaseDetailsList.isNotEmpty) {
            purchaseDetailsList.sort((a, b) => a.transactionDate!.compareTo(b.transactionDate!));

            if (purchaseDetailsList[0].status == PurchaseStatus.restored) {
              getPastPurchases(purchaseDetailsList);
            } else {
              _listenToPurchaseUpdated(purchaseDetailsList);
            }
          }
        },
        cancelOnError: true,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          log("Purchase stream error: $error");
          handleError(error);
        });
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      _products = [];
      _purchases = [];
      _iapCallback?.onBillingError("Store not available");
      return;
    }

    // Fixed: Convert List to Set properly
    Set<String> productIds = productId.toSet();

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(productIds);

    if (productDetailResponse.error != null) {
      _products = [];
      _purchases = [];
      _iapCallback?.onBillingError(productDetailResponse.error);
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _products = [];
      _purchases = [];
      _iapCallback?.onBillingError("No products found");
      return;
    } else {
      _products = productDetailResponse.productDetails;
      _purchases = [];
      log("Products loaded: ${_products.length}");
    }

    await _connection.restorePurchases();
  }

  Future<void> getPastPurchases(List<PurchaseDetails> verifiedPurchases) async {
    verifiedPurchases.sort((a, b) => a.transactionDate!.compareTo(b.transactionDate!));

    if (Platform.isIOS) {
      if (verifiedPurchases.isNotEmpty) {
        await _verifyProductReceipts(verifiedPurchases);
      } else {
        log("You have not Purchased :::::::::::::::::::=>");
        _iapCallback?.onBillingError("You haven't purchase our product, so we can't restore.");
      }
    }

    if (verifiedPurchases.isNotEmpty) {
      _purchases = verifiedPurchases;
      log("You have already Purchased :::::::::::::::::::=>");

      for (var element in _purchases) {
        MyApp.purchaseStreamController.add(element);
        _iapCallback?.onSuccessPurchase(element);
      }
    } else {
      log("You have not Purchased :::::::::::::::::::=>");
      _iapCallback?.onBillingError("You haven't purchase our product, so we can't restore.");
    }
  }

  _verifyProductReceipts(List<PurchaseDetails> verifiedPurchases) async {
    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ),
    );

    Map<String, String> data = {};
    data.putIfAbsent("receipt-data", () => verifiedPurchases[0].verificationData.localVerificationData);

    try {
      // Step 1: Always start with production URL
      String productionUrl = 'https://buy.itunes.apple.com/verifyReceipt';

      final productionResponse = await dio.post<String>(productionUrl, data: data);
      Map<String, dynamic> productionProfile = jsonDecode(productionResponse.data!);

      // Check if we got error 21007 (sandbox receipt sent to production)
      if (productionProfile['status'] == 21007) {
        log("Sandbox receipt detected, retrying with sandbox URL");

        // Step 2: Retry with sandbox URL
        String sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
        final sandboxResponse = await dio.post<String>(sandboxUrl, data: data);
        Map<String, dynamic> sandboxProfile = jsonDecode(sandboxResponse.data!);

        // Process sandbox response
        await _processReceiptData(sandboxProfile, verifiedPurchases);
      } else {
        // Process production response
        await _processReceiptData(productionProfile, verifiedPurchases);
      }
    } catch (ex) {
      try {
        _iapCallback?.onBillingError("Receipt verification failed: $ex");
      } catch (e) {
        _iapCallback?.onBillingError("Receipt verification error");
        log(e.toString());
      }
    }
  }

  Future<void> _processReceiptData(Map<String, dynamic> profile, List<PurchaseDetails> verifiedPurchases) async {
    var receiptData = IapReceiptData.fromJson(profile);

    // Check receipt status
    if (receiptData.status != 0) {
      String errorMessage = _getReceiptStatusMessage(receiptData.status ?? -1);
      _iapCallback?.onBillingError("Receipt validation failed: $errorMessage");
      return;
    }

    if (receiptData.latestReceiptInfo != null && receiptData.latestReceiptInfo!.isNotEmpty) {
      receiptData.latestReceiptInfo!.sort((a, b) => b.expiresDateMs!.compareTo(a.expiresDateMs!));

      // Check if subscription is still valid
      if (int.parse(receiptData.latestReceiptInfo![0].expiresDateMs!) > DateTime.now().millisecondsSinceEpoch) {
        for (PurchaseDetails data in verifiedPurchases) {
          if (data.productID == receiptData.latestReceiptInfo![0].productId) {
            _purchases.clear();
            _purchases.add(data);

            if (_purchases.isNotEmpty) {
              for (var element in _purchases) {
                MyApp.purchaseStreamController.add(element);
                _iapCallback?.onSuccessPurchase(element);
              }
            } else {
              _iapCallback?.onBillingError("Purchase verification failed");
            }

            log("Already Purchased => ${receiptData.latestReceiptInfo![0].toJson()}");
            return;
          }

          if (data.pendingCompletePurchase) {
            await _connection.completePurchase(data);
          }
        }

        _iapCallback?.onBillingError("Product ID mismatch");
      } else {
        _iapCallback?.onBillingError("Purchase expired");
      }
    } else {
      _iapCallback?.onBillingError("No receipt info found");
    }
  }

  String _getReceiptStatusMessage(int status) {
    switch (status) {
      case 0:
        return "Valid receipt";
      case 21000:
        return "The request to the App Store was not made using the HTTP POST request method";
      case 21001:
        return "This status code is no longer sent by the App Store";
      case 21002:
        return "The data in the receipt-data property was malformed or the service experienced a temporary issue";
      case 21003:
        return "The receipt could not be authenticated";
      case 21004:
        return "The shared secret you provided does not match the shared secret on file for your account";
      case 21005:
        return "The receipt server was temporarily unable to provide the receipt";
      case 21006:
        return "This receipt is valid but the subscription has expired";
      case 21007:
        return "This receipt is from the test environment, but it was sent to the production environment";
      case 21008:
        return "This receipt is from the production environment, but it was sent to the test environment";
      case 21009:
        return "Internal data access error";
      case 21010:
        return "The user account cannot be found or has been deleted";
      default:
        return "Unknown error (status: $status)";
    }
  }

  Map<String, PurchaseDetails> getPurchases() {
    Map<String, PurchaseDetails> purchases = Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _connection.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    return purchases;
  }

  Future<void> finishTransaction() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();

      if (transactions.isNotEmpty) {
        for (final transaction in transactions) {
          try {
            if (transaction.transactionState != SKPaymentTransactionStateWrapper.purchasing) {
              await SKPaymentQueueWrapper().finishTransaction(transaction);
              if (transaction.originalTransaction != null) {
                await SKPaymentQueueWrapper().finishTransaction(transaction.originalTransaction!);
              }
            }
          } catch (e) {
            log("Error finishing transaction: $e");
            _iapCallback?.onBillingError(e);
          }
        }
      }
    }
  }

  buySubscription(ProductDetails productDetails, Map<String, PurchaseDetails> purchases) async {
    // Clear any pending iOS transactions first
    if (Platform.isIOS) {
      await clearTransactions();
    }

    PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      final oldSubscription = _getOldSubscription(productDetails, purchases);

      purchaseParam = GooglePlayPurchaseParam(
          productDetails: productDetails,
          applicationUserName: null,
          changeSubscriptionParam: (oldSubscription != null)
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: oldSubscription,
                )
              : null);
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    }

    // Use buyConsumable for coins/credits that can be purchased multiple times
    // Use buyNonConsumable for one-time purchases
    _connection.buyConsumable(purchaseParam: purchaseParam).catchError((error) async {
      handleError(error);
      log("Purchase error: $error");
    });
  }

  Future<void> clearTransactions() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        try {
          if (transaction.transactionState != SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
            if (transaction.originalTransaction != null) {
              await SKPaymentQueueWrapper().finishTransaction(transaction.originalTransaction!);
            }
          }
        } catch (e) {
          _iapCallback?.onBillingError(e);
          log("Error clearing transaction: $e");
        }
      }
    }
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    /// IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    _purchases.add(purchaseDetails);
    MyApp.purchaseStreamController.add(purchaseDetails);
    _iapCallback?.onSuccessPurchase(purchaseDetails);
  }

  void handleError(dynamic error) {
    log("IAP Error: $error");
    _iapCallback?.onBillingError(error);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    /// IMPORTANT!! Always verify a purchase before delivering the product.
    /// For the purpose of an example, we directly return true.
    /// In production, implement proper server-side verification
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    /// handle invalid purchase here if _verifyPurchase failed.
    log("Invalid purchase: ${purchaseDetails.productID}");
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails detailsPurchase in purchaseDetailsList) {
      if (detailsPurchase.status == PurchaseStatus.pending) {
        _iapCallback?.onPending(detailsPurchase);
      } else {
        if (detailsPurchase.status == PurchaseStatus.error) {
          handleError(detailsPurchase.error);
        } else if (detailsPurchase.status == PurchaseStatus.restored) {
          getPastPurchases(purchaseDetailsList);
        } else if (detailsPurchase.status == PurchaseStatus.canceled) {
          _iapCallback?.onBillingError("Purchase canceled");
        } else if (detailsPurchase.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(detailsPurchase);
          if (valid) {
            onComplete.call();
            deliverProduct(detailsPurchase);
          } else {
            _handleInvalidPurchase(detailsPurchase);
            return;
          }
        }
      }

      if (detailsPurchase.pendingCompletePurchase) {
        await _connection.completePurchase(detailsPurchase);
        await finishTransaction();
      }
    }
    await clearTransactions();
  }

  GooglePlayPurchaseDetails? _getOldSubscription(ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    return purchases[productDetails.id] as GooglePlayPurchaseDetails?;
  }
}
