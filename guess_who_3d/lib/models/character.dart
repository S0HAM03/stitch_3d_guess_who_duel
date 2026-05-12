class Character {
  final String name;
  final String imageUrl;
  bool isKnockedDown;

  Character({
    required this.name,
    required this.imageUrl,
    this.isKnockedDown = false,
  });

  // Use name as a unique identifier
  String get id => name;

  Character copyWith({
    String? name,
    String? imageUrl,
    bool? isKnockedDown,
  }) {
    return Character(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isKnockedDown: isKnockedDown ?? this.isKnockedDown,
    );
  }
}
