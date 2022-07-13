class Data {
  double sales;
  double tax;
  int trx;
  Data({required this.sales, required this.trx, required this.tax});
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(sales: json['sales'], tax: json['tax'], trx: json['trx']);
  }
}
