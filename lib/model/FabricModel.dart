class FabricModel{
  String fabricName;
  String allQty;
  double totalQty;
  String shade;
  double rate;

  FabricModel({this.fabricName, this.allQty, this.totalQty,this.shade});

  FabricModel.fromJson(Map<String, dynamic> json) {
    fabricName = json['fabricName'];
    allQty = json['allQty'];
    totalQty = json['totalQty'];
    shade = json['shade'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fabricName'] = this.fabricName;
    data['allQty'] = this.allQty;
    data['totalQty'] = this.totalQty;
    data['shade'] = this.shade;
    data['rate'] = this.rate;
    return data;
  }
}