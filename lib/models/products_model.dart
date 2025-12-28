// import 'package:rechoice_app/models/category_model.dart';
// import 'package:rechoice_app/models/items_model.dart';

// class Products {
  
//   //list of available product
//   final List<Items> _products = [
//     // Perfumes (categoryID: 0)
//     Items(
//       itemID: 1,
//       title: 'Y EAU DE PARFUM',
//       category: categories[0],
//       brand: 'Yves Saint Laurent',
//       condition: 'Brand New',
//       price: 700,
//       quantity: 1,
//       description:
//           'Y Eau de Parfum is a bold, aromatic fougère perfume designed for the modern man who dares to chase his dreams. Created by the legendary perfumer Dominique Ropion, this intense fragrance blends fresh apple notes, vibrant bergamot, and spicy ginger with a heart of sage, geranium, and juniper berries, wrapped in a warm base of amberwood, vetiver, cedar, and tonka bean.',
//       status: 'Available',
//       imagePath: 'assets/images/perfumes/perfume_1.jpg',
//     ),
//     Items(
//       itemID: 2,
//       title: 'BLEU DE CHANEL',
//       category: categories[0],
//       brand: 'Chanel',
//       condition: 'Brand New',
//       price: 850,
//       quantity: 1,
//       description:
//           'An aromatic woody fragrance that embodies freedom. Fresh citrus notes meet woody cedar undertones, creating a timeless scent for the man who defies convention.',
//       status: 'Available',
//       imagePath: 'assets/images/perfumes/perfume_2.jpg',
//     ),
//     Items(
//       itemID: 3,
//       title: 'SAUVAGE',
//       category: categories[0],
//       brand: 'Dior',
//       condition: 'Brand New',
//       price: 780,
//       quantity: 1,
//       description:
//           'Radically fresh composition with raw, noble materials. Calabrian bergamot and Ambroxan create a powerful yet refined fragrance inspired by wide-open spaces.',
//       status: 'Available',
//       imagePath: 'assets/images/perfumes/perfume_3.jpg',
//     ),
//     Items(
//       itemID: 4,
//       title: 'ACQUA DI GIO',
//       category: categories[0],
//       brand: 'Giorgio Armani',
//       condition: 'Brand New',
//       price: 650,
//       quantity: 1,
//       description:
//           'Fresh aquatic fragrance inspired by the Mediterranean. Combines marine notes with bergamot, neroli, and rosemary for a crisp, invigorating scent.',
//       status: 'Available',
//       imagePath: 'assets/images/perfumes/perfume_5.jpg',
//     ),
//     Items(
//       itemID: 5,
//       title: 'ONE MILLION',
//       category: categories[0],
//       brand: 'Paco Rabanne',
//       condition: 'Brand New',
//       price: 720,
//       quantity: 1,
//       description:
//           'Provocative blend of grapefruit, mint, blood orange, rose, cinnamon, spice notes, amber, leather, and woody notes. A scent for the confident, modern man.',
//       status: 'Available',
//       imagePath: 'assets/images/perfumes/perfume_6.jpg',
//     ),

//     // Electronics (categoryID: 1)
//     Items(
//       itemID: 6,
//       title: 'CLASSIC WHITE TEE',
//       category: categories[1],
//       brand: 'Uniqlo',
//       condition: 'Brand New',
//       price: 120,
//       quantity: 1,
//       description:
//           '100% cotton crew neck t-shirt. Essential wardrobe staple with comfortable fit and breathable fabric. Perfect for everyday wear.',
//       status: 'Available',
//       imagePath: 'assets/images/electronics/electronics_1.png',
//     ),
//     Items(
//       itemID: 7,
//       title: 'POLO SHIRT',
//       category: categories[1],
//       brand: 'Ralph Lauren',
//       condition: 'Like New',
//       price: 450,
//       quantity: 1,
//       description:
//           'Classic polo shirt with signature embroidered pony. Made from soft cotton mesh with ribbed collar and cuffs.',
//       status: 'Available',
//       imagePath: 'assets/images/electronics/electronics_2.png',
//     ),
//     Items(
//       itemID: 8,
//       title: 'OVERSIZED HOODIE',
//       category: categories[1],
//       brand: 'H&M',
//       condition: 'Brand New',
//       price: 280,
//       quantity: 1,
//       description:
//           'Relaxed fit hoodie in cotton blend. Features drawstring hood, kangaroo pocket, and ribbed trim. Street style comfort.',
//       status: 'Available',
//       imagePath: 'assets/images/electronics/electronics_3.png',
//     ),
//     Items(
//       itemID: 9,
//       title: 'DENIM JACKET',
//       category: categories[1],
//       brand: "Levi's",
//       condition: 'Good',
//       price: 550,
//       quantity: 1,
//       description:
//           'Classic trucker jacket in premium denim. Features button closure, chest pockets, and adjustable side tabs. Timeless layering piece.',
//       status: 'Available',
//       imagePath: 'assets/images/electronics/electronics_4.png',
//     ),
//     Items(
//       itemID: 10,
//       title: 'STRIPED BUTTON-UP',
//       category: categories[1],
//       brand: 'Zara',
//       condition: 'Brand New',
//       price: 320,
//       quantity: 1,
//       description:
//           'Slim fit shirt with vertical stripes. Made from breathable cotton with button-down collar. Perfect for smart casual looks.',
//       status: 'Available',
//       imagePath: 'assets/images/electronics/electronics_5.png',
//     ),

//     // // Bottoms (categoryID: 2)
//     // Items(
//     //   itemID: 11,
//     //   title: 'SLIM FIT JEANS',
//     //   category: categories[2],
//     //   brand: "Levi's",
//     //   condition: 'Brand New',
//     //   price: 480,
//     //   quantity: 1,
//     //   description:
//     //       'Classic slim fit jeans in dark wash denim. Features five-pocket styling and comfortable stretch fabric. Versatile everyday essential.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 12,
//     //   title: 'CARGO PANTS',
//     //   category: categories[2],
//     //   brand: 'Carhartt',
//     //   condition: 'Like New',
//     //   price: 420,
//     //   quantity: 1,
//     //   description:
//     //       'Utility cargo pants with multiple pockets. Durable cotton twill construction with relaxed fit. Street style functionality.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 13,
//     //   title: 'CHINO SHORTS',
//     //   category: categories[2],
//     //   brand: 'GAP',
//     //   condition: 'Brand New',
//     //   price: 250,
//     //   quantity: 1,
//     //   description:
//     //       'Classic chino shorts in lightweight cotton. Features flat front and side pockets. Perfect for casual summer wear.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 14,
//     //   title: 'JOGGER PANTS',
//     //   category: categories[2],
//     //   brand: 'Nike',
//     //   condition: 'Brand New',
//     //   price: 380,
//     //   quantity: 1,
//     //   description:
//     //       'Tapered joggers in French terry fabric. Features elastic waistband with drawcord and zippered pockets. Athleisure comfort.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 15,
//     //   title: 'TAILORED TROUSERS',
//     //   category: categories[2],
//     //   brand: 'Zara',
//     //   condition: 'Brand New',
//     //   price: 520,
//     //   quantity: 1,
//     //   description:
//     //       'Slim fit dress pants with pressed crease. Made from wrinkle-resistant fabric with belt loops. Smart office attire.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),

//     // // Outerwear (categoryID: 3)
//     // Items(
//     //   itemID: 16,
//     //   title: 'PUFFER JACKET',
//     //   category: categories[3],
//     //   brand: 'The North Face',
//     //   condition: 'Brand New',
//     //   price: 980,
//     //   quantity: 1,
//     //   description:
//     //       'Insulated puffer jacket with water-resistant finish. Features down fill, zip pockets, and adjustable hood. Cold weather essential.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 17,
//     //   title: 'WOOL OVERCOAT',
//     //   category: categories[3],
//     //   brand: 'Burberry',
//     //   condition: 'Like New',
//     //   price: 2500,
//     //   quantity: 1,
//     //   description:
//     //       'Classic wool overcoat with notched lapels. Premium Italian wool construction with button closure. Sophisticated winter layering.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 18,
//     //   title: 'BOMBER JACKET',
//     //   category: categories[3],
//     //   brand: 'Alpha Industries',
//     //   condition: 'Brand New',
//     //   price: 780,
//     //   quantity: 1,
//     //   description:
//     //       'Classic MA-1 bomber jacket with nylon shell. Features zip closure, ribbed cuffs, and signature utility pocket. Military-inspired style.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 19,
//     //   title: 'WINDBREAKER',
//     //   category: categories[3],
//     //   brand: 'Patagonia',
//     //   condition: 'Brand New',
//     //   price: 650,
//     //   quantity: 1,
//     //   description:
//     //       'Lightweight windbreaker with packable design. Water-resistant ripstop fabric with adjustable hood. Perfect for outdoor activities.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 20,
//     //   title: 'LEATHER JACKET',
//     //   category: categories[3],
//     //   brand: 'AllSaints',
//     //   condition: 'Good',
//     //   price: 1800,
//     //   quantity: 1,
//     //   description:
//     //       'Genuine leather biker jacket with asymmetric zip. Features belted waist and zippered pockets. Timeless edge.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),

//     // // Undergarments (categoryID: 4)
//     // Items(
//     //   itemID: 21,
//     //   title: 'COTTON BOXER BRIEFS',
//     //   category: categories[4],
//     //   brand: 'Calvin Klein',
//     //   condition: 'Brand New',
//     //   price: 180,
//     //   quantity: 1,
//     //   description:
//     //       'Pack of 3 cotton boxer briefs with elastic waistband. Comfortable everyday essentials with logo elastic band.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 22,
//     //   title: 'ATHLETIC BRIEFS',
//     //   category: categories[4],
//     //   brand: 'Under Armour',
//     //   condition: 'Brand New',
//     //   price: 220,
//     //   quantity: 1,
//     //   description:
//     //       'Moisture-wicking performance briefs. Features anti-odor technology and 4-way stretch fabric. Perfect for active wear.',
//     //   status: 'Available',
//     //   imagePath: 'g',
//     // ),
//     // Items(
//     //   itemID: 23,
//     //   title: 'CREW NECK UNDERSHIRT',
//     //   category: categories[4],
//     //   brand: 'Uniqlo',
//     //   condition: 'Brand New',
//     //   price: 90,
//     //   quantity: 1,
//     //   description:
//     //       'Seamless undershirt in AIRism fabric. Breathable, quick-drying material with odor control. Invisible layering piece.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 24,
//     //   title: 'THERMAL BASE LAYER',
//     //   category: categories[4],
//     //   brand: 'Heattech',
//     //   condition: 'Brand New',
//     //   price: 280,
//     //   quantity: 1,
//     //   description:
//     //       'Heat-generating thermal wear for cold weather. Moisture-wicking fabric retains warmth. Perfect base layer for winter.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//     // Items(
//     //   itemID: 25,
//     //   title: 'COMPRESSION SHORTS',
//     //   category: categories[4],
//     //   brand: 'Nike',
//     //   condition: 'Brand New',
//     //   price: 320,
//     //   quantity: 1,
//     //   description:
//     //       'Dri-FIT compression shorts with flat seams. Provides muscle support during workouts. High-performance athletic wear.',
//     //   status: 'Available',
//     //   imagePath: '',
//     // ),
//   ];

//   /*

//     G E T T E R S

//   */

//   List<Items> get products => _products;

//   /*


//     O P E R A T I O N S 
//     //updateStatus()


//     //editDetails


//     //deleteItems()

//     //add to cart

//     //get total price of the cart

//     //clear cart

//     //get total number of items in cart
  

//   */

//   /*

//     H E L P E R S

//     //generate a receipt

//     //format double values into money

//   */
// }
