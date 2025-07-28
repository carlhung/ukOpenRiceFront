import 'package:flutter/material.dart';

class RestaurantHomePage extends StatelessWidget {
  const RestaurantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterBar(),
            SizedBox(height: 24),
            SectionTitle(title: 'Discover by Location'),
            SizedBox(height: 12),
            LocationList(),
            SizedBox(height: 24),
            SectionTitle(title: 'Popular Cuisines'),
            SizedBox(height: 12),
            CuisineList(),
            SizedBox(height: 24),
            SectionTitle(title: 'Featured Restaurants'),
            SizedBox(height: 12),
            FeaturedRestaurantCard(),
          ],
        ),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilterChipWidget(label: 'City'),
        FilterChipWidget(label: 'Cuisine'),
        FilterChipWidget(label: '★★★★☆'),
        FilterChipWidget(label: 'Price'),
        FilterChipWidget(label: 'Open Now'),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Apply Filters'),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;

  const FilterChipWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.grey.shade200,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class LocationList extends StatelessWidget {
  const LocationList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          LocationCard(imagePath: 'assets/london.jpg', name: 'London'),
          LocationCard(imagePath: 'assets/manchester.jpg', name: 'Manchester'),
          LocationCard(imagePath: 'assets/birmingham.jpg', name: 'Birmingham'),
          LocationCard(imagePath: 'assets/liverpool.jpg', name: 'Liverpool'),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String imagePath;
  final String name;

  const LocationCard({super.key, required this.imagePath, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class CuisineList extends StatelessWidget {
  const CuisineList({super.key});

  @override
  Widget build(BuildContext context) {
    final cuisines = ['Chinese', 'Cantonese', 'Sichuan', 'Japanese', 'Korean'];
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cuisines.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.brown.shade100,
                child: Text(
                  cuisines[index][0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Text(cuisines[index], style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedRestaurantCard extends StatelessWidget {
  const FeaturedRestaurantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/restaurant.jpg',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Yang Sing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star_half, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text('4.3 (217)'),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Manchester', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
