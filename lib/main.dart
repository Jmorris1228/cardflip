import 'package:flutter/material.dart';
import 'dart:math'; // For rotation animations
import 'package:provider/provider.dart'; // For state management

// Card Model
class CardModel {
  final String imageAsset; // Front image of the card
  bool isFaceUp; // Whether the card is flipped face-up
  bool isMatched; // If the card is matched

  CardModel({required this.imageAsset, this.isFaceUp = false, this.isMatched = false});
}

// Game Provider (State Management)
class GameProvider extends ChangeNotifier {
  List<CardModel> cards = []; // List of cards
  int flippedIndex = -1; // Tracks the first flipped card

  GameProvider() {
    _initializeCards();
  }

  // Initialize cards with shuffled pairs
  void _initializeCards() {
    List<String> images = [
      'assets/image/image1.png', 'assets/images/image2.png', 'assets/images/image3.png', 'assets/images/image4.png', 
      'assets/image/image1.png',
      'assets/images/back.png',
     //
    ];
    images.shuffle(); // Shuffle cards
    cards = images.map((image) => CardModel(imageAsset: image)).toList();
  }

  // card flipping
  void flipCard(int index) {
    if (cards[index].isMatched || cards[index].isFaceUp) return;

    if (flippedIndex == -1) {
      // First card flipped
      flippedIndex = index;
      cards[index].isFaceUp = true;
    } else {
      // Second card flipped
      cards[index].isFaceUp = true;

      if (checkForMatch(flippedIndex, index)) {
        // If the cards match, mark them as matched
        cards[flippedIndex].isMatched = true;
        cards[index].isMatched = true;
      } else {
        // If they don't match, flip them back after a delay
        Future.delayed(const Duration(seconds: 1), () {
          cards[flippedIndex].isFaceUp = false;
          cards[index].isFaceUp = false;
          notifyListeners();
        });
      }
      flippedIndex = -1; // Reset after two cards are flipped
    }
    notifyListeners();
  }

  // Check if two cards match
  bool checkForMatch(int firstIndex, int secondIndex) {
    return cards[firstIndex].imageAsset == cards[secondIndex].imageAsset;
  }
}

// Main App
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const CardMatchingGame(),
    ),
  );
}

// Card Matching Game 
class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Card Matching Game')),
        body: const GameGrid(),
      ),
    );
  }
}

// Game Grid (UI)
class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemCount: gameProvider.cards.length,
          itemBuilder: (context, index) {
            return CardWidget(card: gameProvider.cards[index], onTap: () {
              gameProvider.flipCard(index);
            });
          },
        );
      },
    );
  }
}

// Card Widget (UI + Animation)
class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const CardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: card.isFaceUp || card.isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        transform: Matrix4.rotationY(card.isFaceUp ? 0 : pi), // Flip animation
        child: card.isFaceUp || card.isMatched
            ? Image.asset(card.imageAsset) // Show front image if face-up or matched
            : Image.asset('assets/back.image.png'), // Show back design when face-down
      ),
    );
  }
}
