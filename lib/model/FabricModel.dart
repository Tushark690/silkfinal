class FabricModel{
  String fabricName;
  String allQty;
  int totalQty;
  String shade;

  FabricModel({this.fabricName, this.allQty, this.totalQty,this.shade});

  FabricModel.fromJson(Map<String, dynamic> json) {
    fabricName = json['fabricName'];
    allQty = json['allQty'];
    totalQty = json['totalQty'];
    shade = json['shade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fabricName'] = this.fabricName;
    data['allQty'] = this.allQty;
    data['totalQty'] = this.totalQty;
    data['shade'] = this.shade;
    return data;
  }
}