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
        image: "assets/problem_one.png",
        title: "Compre algo por internet y nunca llegó."),
    Guide(
        image: "assets/problem_two.png",
        title: "Compre algo con garantia y no quieren responder."),
    Guide(
        image: "assets/problem_three.png",
        title: "Me despidieron sin justa causa."),
    Guide(
        image: "assets/problem_four.png",
        title: "Tengo unos inquilinos que no pagan y no se van."),
  ];
}

