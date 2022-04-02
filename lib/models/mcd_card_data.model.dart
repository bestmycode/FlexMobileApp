class McdCardData {
  McdCardData({
    required this.cvv,
    required this.pan,
  });

  final String cvv;
  final String pan;

  factory McdCardData.fromMap(Map<String, dynamic> json) => McdCardData(
        cvv: json["cvv"],
        pan: json["pan"],
      );
}
