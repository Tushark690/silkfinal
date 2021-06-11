class MaterialModel{
  String materialName;
  String allQty;
  double totalQty;
  String unit;

  MaterialModel({this.materialName, this.allQty, this.totalQty,this.unit});

  MaterialModel.fromJson(Map<String, dynamic> json) {
    materialName = json['materialName'];
    allQty = json['allQty'];
    totalQty = json['totalQty'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['materialName'] = this.materialName;
    data['allQty'] = this.allQty;
    data['totalQty'] = this.totalQty;
    data['unit'] = this.unit;
    return data;
  }
}