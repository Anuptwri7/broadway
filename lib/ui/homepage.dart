import 'dart:convert';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:classboradway/ui/productDetailPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../integration/googleLogin.dart';
import 'cartPage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'createProduct.dart';

// ca-app-pub-2967592892447323/6904609644
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  final String _appOpenAdUnitId = 'ca-app-pub-2967592892447323/8565768576';
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  void loadAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAd!.show();
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      loadAd();
      return;
    }
    if (_isShowingAd) {
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  final AuthService _authService = AuthService();
    TextEditingController searchController = TextEditingController();
  late YoutubePlayerController _controller;
  List<String> videoIds = [];
  String? selectedVideoId;
  final List<String> images = [
    'https://www.w3schools.com/w3images/lights.jpg',
    'https://www.w3schools.com/w3images/mountains.jpg',
    'https://www.w3schools.com/w3images/forest.jpg',
  ];

  final List<Map<String, dynamic>> products = [

  ];

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> filteredProducts = [];
  Future<void> fetchVideos() async {
    final snapshot = await FirebaseFirestore.instance.collection('videos').get();
    List<String> ids =[];
    for (var doc in snapshot.docs) {
      final List<dynamic> videoList = doc['videoId'];
      ids.addAll(videoList.map((e) => e.toString()));
    }

    setState(() {
      videoIds = ids;
      if (videoIds.isNotEmpty) {
        selectedVideoId = videoIds.first;
        _controller.loadVideoById(videoId: selectedVideoId!);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadCartItems();
    fetchVideos();
      loadAd();

    loadProfileImage();
    loadUserProducts();
    filteredProducts = products;

    _controller = YoutubePlayerController(
      params: YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'LtNbLer31fg',
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );

    _bannerAd = BannerAd(
          adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _startScanning() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: ScannerView(
            onBarcodeDetected: (String barcode) async {
              log(barcode);
             setState(() {
               searchController = TextEditingController(text: barcode);
                 filteredProducts = products.where((product) {
                   final nameMatch = product['name']
                       .toLowerCase()
                       .contains(barcode.toLowerCase());
                   final priceMatch = double.tryParse(barcode) != null &&
                       product['price'].toString().contains(barcode);
                   return nameMatch || priceMatch;
                 }).toList();

             });
             if(filteredProducts.isEmpty){
               Fluttertoast.showToast(msg: "No Product Found with this name");
             }
             Navigator.pop(context);

            },
          ),
        ),
      ),
    );
  }

  Future<void> loadUserProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final userProductStrings = prefs.getStringList("user_products") ?? [];

    final userProductMaps = userProductStrings
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .where((product) => product['isApproved'] == true)
        .toList();

    setState(() {
      products.clear();
      products.addAll(userProductMaps);
      filteredProducts = products;
    });
  }

  String? _imagePath;
  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => BottomSheet(
        onClosing: () {},
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Take Photo"),
              onTap: () async {
                final photo = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                final gallery = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, gallery);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final savedImage = await File(pickedFile.path).copy('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', savedImage.path);

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    setState(() {
      cartItems = cart.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    });
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    List<Map<String, dynamic>> cartList =
    cart.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();

    int index = cartList.indexWhere((item) => item['name'] == product['name']);
    log("got index:"+index.toString());
    if (index != -1) {
      cartList[index]['qty'] = (cartList[index]['qty']??1) + 1;
    } else {
      product['qty'] = 1;
      cartList.add(product);
      cartList.add(product);
    }
    await prefs.setStringList(
      'cart',
      cartList.map((item) => jsonEncode(item)).toList(),
    );

    loadCartItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.teal,
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              filteredProducts = products.where((product) {
                final nameMatch = product['name']
                    .toLowerCase()
                    .contains(value.toLowerCase());

                final priceMatch = double.tryParse(value) != null &&
                    product['price'].toString().contains(value);

                return nameMatch || priceMatch;
              }).toList();
            });
          },
        ),
        actions: [
          ElevatedButton(onPressed: (){
            // _startScanning();
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Createproduct()));
          }, child: Text("Scan")),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    ).then((_) => loadCartItems());
                  },
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:  AssetImage('assets/icon.jpg') ,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: (){},
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.camera_alt, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Cart"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                ).then((_) => loadCartItems());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
               _authService.signOut(context);
              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (_isAdLoaded)
                Container(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              Container(
                height: 200,
                width: 400,
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: videoIds.length,
                  itemBuilder: (context, index) {
                    final video = videoIds[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedVideoId = video;
                          log(selectedVideoId.toString());
                          _controller.loadVideoById(videoId: selectedVideoId!);
                        });
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              "https://img.youtube.com/vi/${videoIds[index]}/hqdefault.jpg",
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
              const SizedBox(height: 20),

              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                ),
                items: images.map((imageUrl) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              Container(
                height: 500,
                width: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetailPage(product: data,)));
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: data['image'] != null && data['image'] != ""
                                      ? Image.memory(
                                    base64Decode(data['image']),
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(Icons.image, size: 80),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['name'] ?? "No Name",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text("Price: Rs .${data['price'] ?? 'N/A'}"),
                                    ],
                                  ),
                                ),
                                ElevatedButton(onPressed: (){
                                  addToCart(data[index]);
                                }, child: Text("Add to cart"))

                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final double price;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file( File(image!), height: 80, width: 80, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Rs.${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.green)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onAddToCart,
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}

class ScannerView extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const ScannerView({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}
class _ScannerViewState extends State<ScannerView> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [

            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                if (_isProcessing) return;
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  setState(() => _isProcessing = true);
                  widget.onBarcodeDetected(barcodes.first.rawValue!);
                }
              },
            ),


            Container(
              decoration: ShapeDecoration(
                shape: ScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 12,
                  borderLength: 32,
                  borderWidth: 3,
                  cutOutSize: 250,
                ),
              ),
            ),


            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScannerLinePainter(
                      progress: _animation.value,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),


            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // ValueListenableBuilder(
                    //   valueListenable: controller.torchState,
                    //   builder: (context, state, child) {
                    //     return IconButton(
                    //       icon: Icon(
                    //         state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                    //         color: Colors.white,
                    //       ),
                    //       onPressed: () => controller.toggleTorch(),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),

            // Bottom Instructions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Align barcode within frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scanner will detect automatically',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _bannerAd.dispose();
    controller.dispose();
    super.dispose();
  }
}
class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color(0x80000000),
    this.borderRadius = 12.0,
    this.borderLength = 32.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize;
    final cutOutHeight = cutOutSize;
    final left = rect.left + (width - cutOutWidth) / 2;
    final top = rect.top + (height - cutOutHeight) / 3;
    final right = left + cutOutWidth;
    final bottom = top + cutOutHeight;

    final cutOutRect = Rect.fromLTRB(left, top, right, bottom);
    final backgroundPaint = Paint()..color = overlayColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        cutOutRect,
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(path, backgroundPaint);

    // Draw corners
    final borderOffset = borderWidth / 2;
    final cornerStart = borderLength;

    // Top left corner
    canvas.drawLine(
      Offset(left - borderOffset, top + cornerStart),
      Offset(left - borderOffset, top - borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left - borderOffset, top - borderOffset),
      Offset(left + cornerStart, top - borderOffset),
      borderPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(right - cornerStart, top - borderOffset),
      Offset(right + borderOffset, top - borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right + borderOffset, top - borderOffset),
      Offset(right + borderOffset, top + cornerStart),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(right + borderOffset, bottom - cornerStart),
      Offset(right + borderOffset, bottom + borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right + borderOffset, bottom + borderOffset),
      Offset(right - cornerStart, bottom + borderOffset),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(left + cornerStart, bottom + borderOffset),
      Offset(left - borderOffset, bottom + borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left - borderOffset, bottom + borderOffset),
      Offset(left - borderOffset, bottom - cornerStart),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}
class ScannerLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScannerLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0;

    final scanLineY = size.height * 0.3 + (size.height * 0.4 * progress);
    canvas.drawLine(
      Offset(size.width * 0.2, scanLineY),
      Offset(size.width * 0.8, scanLineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerLinePainter oldDelegate) => true;
}