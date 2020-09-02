import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  final BoxConstraints size;

  ImageSlider(this.size);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final List<List<String>> images = [
    ['assets/images/normal_grid.jpg', 'Normal Grid'],
    ['assets/images/dual_grid.jpg', 'Dual Grid'],
    ['assets/images/date_popup.jpg', 'Date Selection Popup'],
    ['assets/images/time_popup.jpg', 'Time Selection Popup'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(12),
      itemCount: images.length,
      itemBuilder: (ctx, index) {
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          margin: EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              children: [
                Image.asset(
                  images[index][0],
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 30,
                  left: 30,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white54,
                    ),
                    child: Text(
                      images[index][1],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
