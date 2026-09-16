abstract final class MockDashboard {
  // Mock nearby kitchens — real Lagos/Lekki area coordinates.
  static const List<MockKitchen> nearbyKitchens = [
    MockKitchen(
      id: '1',
      name: 'Farfallino Kitchen',
      emoji: '🍝',
      latitude: 6.4310,
      longitude: 3.4210,
    ),
    MockKitchen(
      id: '2',
      name: "Salma's Grill",
      emoji: '🔥',
      latitude: 6.4280,
      longitude: 3.4350,
    ),
    MockKitchen(
      id: '3',
      name: 'The Burger Hub',
      emoji: '🍔',
      latitude: 6.4350,
      longitude: 3.4180,
    ),
    MockKitchen(
      id: '4',
      name: 'Lagos Kitchen',
      emoji: '🍲',
      latitude: 6.4400,
      longitude: 3.4420,
    ),
  ];
}

class MockKitchen {
  const MockKitchen({
    required this.id,
    required this.name,
    required this.emoji,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String emoji;
  final double latitude;
  final double longitude;
}
