import 'dart:math';

class CustomFetchRandomName {
  static String onGet() {
    List<String> randomNames = [
      "Emily Johnson",
      "Liam Smith",
      "Isabella Martinez",
      "Noah Brown",
      "Sofia Davis",
      "Oliver Wilson",
      "Mia Anderson",
      "James Thomas",
      "Ava Robinson",
      "Benjamin Lee",
      "Charlotte Miller",
      "Lucas Garcia",
      "Amelia White",
      "Ethan Harris",
      "Harper Clark",
      "Alexander Lewis",
      "Evelyn Walker",
      "Daniel Hall",
      "Grace Young",
      "Michael Allen",
      "Samuel Scott",
      "Victoria Nelson",
      "David Adams",
      "Chloe Baker",
      "Henry Carter",
      "Madison Rogers",
      "Sebastian Murphy",
      "Ella Reed",
      "Jack Peterson",
      "Scarlett Brooks",
      "William Bennett",
      "Lily Rivera",
      "Joseph Foster",
      "Zoe Coleman",
      "Matthew Kelly",
      "Natalie Bailey",
      "Elijah Richardson",
      "Hannah Perry",
      "Mason Cox",
      "Layla Ramirez",
      "Logan Gray",
      "Aubrey Cooper",
      "Jayden Howard",
      "Aria Torres",
      "Gabriel Ward",
      "Lillian Bell",
      "Carter Mitchell",
      "Penelope Perez",
      "Dylan Parker",
      "Riley Evans"
    ];

    Random random = Random();
    return randomNames[random.nextInt(randomNames.length)];
  }
}

class CustomFetchRandomImage {
  static String onGet() {
    final randomImages = [
      "https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=600",
      "https://images.pexels.com/photos/1758144/pexels-photo-1758144.jpeg?auto=compress&cs=tinysrgb&w=600",
      "https://images.pexels.com/photos/1898555/pexels-photo-1898555.jpeg?auto=compress&cs=tinysrgb&w=600",
      "https://images.pexels.com/photos/1771383/pexels-photo-1771383.jpeg?auto=compress&cs=tinysrgb&w=600",
      "https://images.pexels.com/photos/3053485/pexels-photo-3053485.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
      "https://cdn.pixabay.com/photo/2019/11/03/20/11/portrait-4599553_1280.jpg"
    ];
    Random random = Random();
    return randomImages[random.nextInt(randomImages.length)];
  }
}
