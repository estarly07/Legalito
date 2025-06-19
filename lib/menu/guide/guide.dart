class Guide {
  final String title;
  final String image;

  Guide({required this.title, required this.image});
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      image: json['img'],
      title: json['title'],
    );
  }
  static final guides = [
    Guide(
        image:
            "https://drive.google.com/uc?export=view&id=190QI4F_GTuhUtkh2SnvrQsCvrr2Ll5Wp",
        title: "Compre algo por internet y nunca llegó."),
    Guide(
        image:
            "https://drive.google.com/uc?export=view&id=1c9Gb7uHLaK30aw0vVJxH8jXNHQpya9MR",
        title: "Compre algo con garantia y no quieren responder."),
    Guide(
        image:
            "https://drive.google.com/uc?export=view&id=1oRyE-1t3OZu2gyR66m4YESONrixlMVIv",
        title: "Me despidieron sin justa causa."),
    Guide(
        image:
            "https://drive.google.com/uc?export=view&id=1ndKKDAoap1tP2j8sSViJg2udTNi4xntO",
        title: "Tengo unos inquilinos que no pagan y no se van."),
  ];
}
