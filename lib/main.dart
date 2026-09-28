import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FoodCrushApp());
}

class FoodCrushApp extends StatelessWidget {
  const FoodCrushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Food Crush',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFC107),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class MenuItem {
  final String name;
  final double price;
  final String category;
  final IconData icon;

  const MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.icon,
  });
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({
    required this.item,
    this.quantity = 1,
  });

  double get total => item.price * quantity;
}

const List<MenuItem> menuItems = [
  MenuItem(
    name: 'Masala Dosa',
    price: 80,
    category: 'Dosa',
    icon: Icons.restaurant,
  ),
  MenuItem(
    name: 'Plain Dosa',
    price: 60,
    category: 'Dosa',
    icon: Icons.circle,
  ),
  MenuItem(
    name: 'Vada Pav',
    price: 40,
    category: 'Fast Food',
    icon: Icons.lunch_dining,
  ),
  MenuItem(
    name: 'Pav Bhaji',
    price: 90,
    category: 'Fast Food',
    icon: Icons.fastfood,
  ),
  MenuItem(
    name: 'Veg Sandwich',
    price: 80,
    category: 'Fast Food',
    icon: Icons.breakfast_dining,
  ),
  MenuItem(
    name: 'Veg Burger',
    price: 100,
    category: 'Fast Food',
    icon: Icons.lunch_dining,
  ),
  MenuItem(
    name: 'Veg Noodles',
    price: 100,
    category: 'Chinese',
    icon: Icons.ramen_dining,
  ),
  MenuItem(
    name: 'Manchurian',
    price: 110,
    category: 'Chinese',
    icon: Icons.rice_bowl,
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<CartItem> cart = [];

  String selectedCategory = 'All';

  List<MenuItem> get filteredItems {
    if (selectedCategory == 'All') {
      return menuItems;
    }

    return menuItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  void addToCart(MenuItem item) {
    final existing = cart.where((e) => e.item.name == item.name).toList();

    setState(() {
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        cart.add(CartItem(item: item));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  int get cartCount {
    return cart.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Color(0xFFFFC107),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'The Food Crush',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(
                          cart: cart,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 3,
                    top: 3,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE FOOD CRUSH',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Fresh food.\nGood mood.',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Order your favourites now!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.fastfood,
                  size: 80,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                categoryButton('All'),
                categoryButton('Dosa'),
                categoryButton('Fast Food'),
                categoryButton('Chinese'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                return MenuCard(
                  item: item,
                  onAdd: () => addToCart(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryButton(String category) {
    final selected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAdd;

  const MenuCard({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C4),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  item.icon,
                  size: 65,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '₹${item.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'ADD',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onChanged;

  const CartPage({
    super.key,
    required this.cart,
    required this.onChanged,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get total {
    return widget.cart.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }

  void decrease(CartItem cartItem) {
    setState(() {
      if (cartItem.quantity > 1) {
        cartItem.quantity--;
      } else {
        widget.cart.remove(cartItem);
      }
    });

    widget.onChanged();
  }

  void increase(CartItem cartItem) {
    setState(() {
      cartItem.quantity++;
    });

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cartItem = widget.cart[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3C4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                cartItem.item.icon,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${cartItem.item.price.toStringAsFixed(0)} each',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      decrease(cartItem),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                  ),
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      increase(cartItem),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  cart: widget.cart,
                                  total: total,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'PROCEED TO CHECKOUT',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;
  final double total;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  String paymentMethod = 'COD';

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    if (nameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all customer details'),
        ),
      );
      return;
    }

    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc();

      final items = widget.cart.map((cartItem) {
        return {
          'name': cartItem.item.name,
          'price': cartItem.item.price,
          'quantity': cartItem.quantity,
          'total': cartItem.total,
        };
      }).toList();

      await orderRef.set({
        'orderId': orderRef.id,
        'customerName': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'address': addressController.text.trim(),
        'items': items,
        'total': widget.total,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentMethod == 'COD' ? 'pending' : 'pending',
        'orderStatus': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            name: nameController.text.trim(),
            total: widget.total,
            paymentMethod: paymentMethod,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),

            textField(
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 12),

            textField(
              controller: mobileController,
              label: 'Mobile Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 12),

            textField(
              controller: addressController,
              label: 'Delivery Address',
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            paymentTile(
              title: 'Cash on Delivery',
              subtitle: 'Pay when your order arrives',
              value: 'COD',
              icon: Icons.payments_outlined,
            ),

            const SizedBox(height: 10),

            paymentTile(
              title: 'UPI Payment',
              subtitle: 'Pay using QR code',
              value: 'UPI',
              icon: Icons.qr_code_2,
            ),

            if (paymentMethod == 'UPI') ...[
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'UPI QR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 180,
                      width: 180,
                      color: Colors.black12,
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 150,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'After payment, send screenshot on WhatsApp.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Text(
                    '₹${widget.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'CONFIRM ORDER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget paymentTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: paymentMethod,
        onChanged: (value) {
          setState(() {
            paymentMethod = value!;
          });
        },
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
      ),
    );
  }
}

class OrderSuccessPage extends StatelessWidget {
  final String name;
  final double total;
  final String paymentMethod;

  const OrderSuccessPage({
    super.key,
    required this.name,
    required this.total,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Thank you, $name!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'The Food Crush',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Total: ₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Payment: $paymentMethod',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'BACK TO MENU',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
