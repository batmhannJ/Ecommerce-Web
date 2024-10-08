import 'model/product.dart';
import 'model/review.dart';
import 'core/constant/paths.dart';

/*
TEMPLATE

// NOTE:
// categories: food, crafts, clothes

Product(
    name: 'dummy name',
    price: 0,
    discount: 0,
    description: 'dummy description',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'crafts',
    tags: ['dummy tag'],
    images: <String>[
      // Bale dito ilalagay 'yung image for example
      // pwede kahit ilan dito
      // Suggestion: 'yung path nung directory pwede gawin nalang variable
      "$categoriesPath$handicraftsPath$barmmPath$higaononPath${architecturePath}IMG_2519.JPG",
      "$categoriesPath$handicraftsPath$barmmPath$higaononPath${architecturePath}IMG_2520.JPG",
    ],
    // Used for new collection, set true to show in new collection
    isNew: true,
    isPopular: true,
  ),
*/

List<Product> products = <Product>[
  const Product(
    name: 'B1',
    price: 150,
    discount: 0,
    description: 'Basket',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'crafts',
    tags: ['basket'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$higaononPath${basketryPath}IMG_2521.JPG",
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'B2',
    price: 100,
    discount: 0,
    description: 'Basket',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'crafts',
    tags: ['basket'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$higaononPath${basketryPath}IMG_2522.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Bahag',
    price: 280,
    discount: 0,
    description:
        'A traditional loincloth for men, made from woven fabric, often adorned with intricate patterns and bright colors.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9012.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Tocino',
    price: 120,
    discount: 0,
    description:
        'It is known for its sweet and savory flavor, often achieved by marinating the meat in a mixture of sugar, salt, and various spices. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2613.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Toasted Pastillas',
    price: 80,
    discount: 0,
    description:
        'are made by toasting the candies to add a unique caramelized flavor and a slightly crispy texture on the outside. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2614.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'B3',
    price: 120,
    discount: 0,
    description: 'Basket',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'crafts',
    tags: ['Basket'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${basketryPath}IMG_2634.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'B4',
    price: 350,
    discount: 0,
    description: 'Basket',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'crafts',
    tags: ['basket'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${basketryPath}IMG_2633.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'P1',
    price: 350,
    discount: 0,
    description: 'Basket',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'crafts',
    tags: ['dummy tag'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2612.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Ube de Leche (Halaya)',
    price: 120,
    discount: 0,
    description:
        'also known as ube jam, is a popular Filipino dessert made from purple yam. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9023.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Espasol',
    price: 80,
    discount: 0,
    description: 'Espasol',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9024.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Special Arrowroot Cookies',
    price: 100,
    discount: 0,
    description: 'Cookies',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9025.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Crispy Pilinut',
    price: 70,
    discount: 0,
    description:
        'often referred to as "pili nuts," are a delicacy native to the Philippines. They come from the pili tree (Canarium ovatum), which is predominantly found in the Bicol region of the country. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9026.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Yema',
    price: 50,
    discount: 0,
    description:
        'sweet treat made from egg yolks, condensed milk, and sugar. It has a rich, creamy texture and is often shaped into small balls or wrapped in colorful cellophane. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9027.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Malong',
    price: 200,
    discount: 0,
    description:
        'A versatile tubular garment worn by both men and women. It can be used as a skirt, dress, blanket, or head covering.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9028.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'T nalak',
    price: 300,
    discount: 0,
    description:
        'A handwoven cloth made from abaca fibers, traditionally dyed using natural colors. It is worn by both men and women during special occasions.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9029.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Inaul',
    price: 330,
    discount: 0,
    description:
        'is a time-honored weaving tradition of the Maguindanao people usually made into malong ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9010.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Sawwal',
    price: 150,
    discount: 0,
    description:
        'Trousers worn by both men and women, usually paired with the badju lapi.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_9011.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Chicharon',
    price: 100,
    discount: 0,
    description: 'Its known for its crispy texture and savory flavor.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2615.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Strawberry Jam',
    price: 70,
    discount: 0,
    description:
        'is a sweet, fruity preserve made from fresh strawberries, sugar, and often a bit of lemon juice. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'food',
    tags: ['food'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2617.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Bicocho',
    price: 50,
    discount: 0,
    description:
        'is a type of Filipino biscuit that is typically baked twice to achieve a crisp and crunchy texture. ',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    category: 'food',
    tags: ['dummy tag'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2619.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Landap',
    price: 300,
    discount: 0,
    description:
        'A traditional Maranao attire, often featuring intricate patterns and bright colors, worn during important cultural events.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2630.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Tubao',
    price: 150,
    discount: 0,
    description:
        ' A headscarf or turban worn by Maranao men, often made from silk or cotton',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2631.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Seputangan',
    price: 100,
    discount: 0,
    description:
        ' A traditional blouse for women, often featuring colorful, geometric designs woven into the fabric.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2632.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
  Product(
    name: 'Patadyong',
    price: 100,
    discount: 0,
    description:
        ' A wraparound skirt, similar to the malong, worn by Subanen women.',
    // Optional
    reviews: [],
    // Optional
    sizes: [],
    // assume na food
    category: 'clothes',
    tags: ['clothes'],
    images: <String>[
      "$categoriesPath$handicraftsPath$barmmPath$lambangianPath${potteryPath}IMG_2633.JPG"
    ],
    isNew: true,
    isPopular: true,
  ),
];
