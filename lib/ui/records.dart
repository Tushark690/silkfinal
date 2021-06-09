import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:flutter/material.dart';
import 'package:silk/model/FabricModel.dart';
import 'package:silk/model/MaterialModel.dart';
import 'package:silk/ui/print-order.dart';

class Records extends StatefulWidget {
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<Records> {

  List<FabricModel> _fabricList=[];
  List<MaterialModel> _materialList=[];
  TextEditingController t1 = new TextEditingController();
  TextEditingController t2 = new TextEditingController();
  String _firstDate="",_secondDate="",_date="";
  Query _records=FirebaseFirestore.instance
      .collection("invoice")
      .orderBy("invoiceNo", descending: true);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Flutter DataTable Example'),
          ),
          body: ListView(children: <Widget>[
            _customDate(),
            Center(
                child: Text(
              'Records',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            )),
            StreamBuilder<QuerySnapshot>(
              stream: _records.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final services = snapshot.data.docs;
                  List<DataRow> serviceWidget = [];
                  for (var st in services) {
                    final invoiceNo = st.data()['invoiceNo'];
                    final date = st.data()['date'].toString();
                    final partyName = st.data()['partyName'];
                    final payment = st.data()['payment'];
                    // final material = st.data()['material'];
                    // final unit = st.data()['unit'];
                    // final materialQuantity = st.data()['materialQuantity'];
                    // final fabric = st.data()['fabric'];
                    // final shade = st.data()['shade'];
                    // final fabricQuantity = st.data()['fabricQuantity'];
                    // final address=st.data()['address'];
                    final sno = st.id;
                    final datas = buildRow(
                        invoiceNo,
                        date,
                        partyName,
                        payment,
                        st.id
                        // material,
                        // unit,
                        // materialQuantity,
                        // fabric,
                        // shade,
                        // fabricQuantity);
                    );
                    serviceWidget.add(datas);
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text('Invoice',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Date',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Party',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Amount',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Material',
                        //         style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Unit',
                        //         style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Quantity',
                        //         style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Fabric',
                        //         style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Shade',
                        //         style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold))),
                        // DataColumn(
                        //     label: Text('Quantity',
                        //         style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold))),
                      ],
                      rows: serviceWidget,
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ])),
    );
  }

  DataRow buildRow(
    invoiceNo,
    date,
    party,
    payment,
    id
    // material,
    // unit,
    // materialQuantity,
    // fabric,
    // shade,
    // fabricQuantity,
  ) {
    return DataRow(
      onSelectChanged: (bool){
        _bottomModalInvoice(id,invoiceNo.toString(),date.toString(),party.toString(),payment.toString());
      },
        cells: [
      DataCell(Text(invoiceNo.toString() == null ? "" : invoiceNo.toString())),
      DataCell(Text(date == null ? "" : date.toString())),
      DataCell(Text(party == null ? "" : party)),
      DataCell(Text(payment == null ? "" : payment.toString())),
      // DataCell(Text(material == null ? "" : material)),
      // DataCell(Text(unit == null ? "" : unit)),
      // DataCell(
      //     Text(materialQuantity == null ? "" : materialQuantity.toString())),
      // DataCell(Text(fabric == null ? "" : fabric)),
      // DataCell(Text(shade == null ? "" : shade)),
      // DataCell(Text(fabricQuantity == null ? "" : fabricQuantity.toString())),
    ]);
  }

  _bottomModalInvoice(id,invoiceNo,date,party,payment){
    List fabricDocs=[],materialDocs=[];
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5,),
                Text("Fabrics",style: TextStyle(fontWeight: FontWeight.w800),),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("fabricInvoice").where("invoice",isEqualTo: id).snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    fabricDocs=snapshot.data.docs;
                    return Container(
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        shrinkWrap: true,
                        primary: false,
                        itemBuilder: (context, index) {
                          FabricModel model = FabricModel();
                          model.fabricName=snapshot.data.docs[index].get("fabricName");
                          model.shade=snapshot.data.docs[index].get("shade");
                          model.allQty=snapshot.data.docs[index].get("allQty");
                          model.totalQty=snapshot.data.docs[index].get("totalQty");
                          _fabricList.add(model);
                          return ListTile(
                            leading: Text(snapshot.data.docs[index].get("fabricName")),
                            title: Text(snapshot.data.docs[index].get("allQty")),
                            trailing: Text(snapshot.data.docs[index].get("totalQty").toString()+" "+snapshot.data.docs[index].get("shade"),style: TextStyle(fontWeight: FontWeight.w800),),
                          );
                        },
                      )
                    );
                  }
                ),
                Text("Material",style: TextStyle(fontWeight: FontWeight.w800),),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("materialInvoice").where("invoice",isEqualTo: id).snapshots(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      materialDocs=snapshot.data.docs;

                      return Container(
                          child: ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              MaterialModel model = MaterialModel();
                              model.materialName=snapshot.data.docs[index].get("materialName");
                              model.unit=snapshot.data.docs[index].get("unit");
                              model.allQty=snapshot.data.docs[index].get("allQty");
                              model.totalQty=snapshot.data.docs[index].get("totalQty");
                              _materialList.add(model);
                              return ListTile(
                                leading: Text(snapshot.data.docs[index].get("materialName")),
                                title: Text(snapshot.data.docs[index].get("allQty")),
                                trailing: Text(snapshot.data.docs[index].get("totalQty").toString()+" "+snapshot.data.docs[index].get("unit"),style: TextStyle(fontWeight: FontWeight.w800),),
                              );
                            },
                          )
                      );
                    }
                ),
                SizedBox(height: 10,),
                RaisedButton(onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PrintOrder(party,date,invoiceNo,payment,_materialList,_fabricList),));
                },color: Colors.blue,
                child: Text("Print",style: TextStyle(color: Colors.white),),)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _customDate(){
    return Container(
      // width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              _selectFirstDate(context);
            },
            child: TextFormField(
              enabled: false,
              controller: t1,
              decoration: InputDecoration(
                hintText: "First Date",
                icon: Icon(
                  Icons.calendar_today,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _selectSecondDate(context);
            },
            child: TextFormField(
              enabled: false,
              controller: t2,
              decoration: InputDecoration(
                hintText: "Second Date",
                icon: Icon(
                  Icons.calendar_today,
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: RaisedButton(
                  child: Text("Search",style: TextStyle(color: Colors.white),),
                  color: Colors.blue,
                  onPressed: (){
                      setState(() {
                        _records=FirebaseFirestore.instance
                            .collection("invoice")
                            .where("reportDate",isGreaterThanOrEqualTo: _firstDate)
                            .where("reportDate",isLessThanOrEqualTo: _secondDate)
                            .orderBy("reportDate", descending: true);
                      });
                  },
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _selectFirstDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _firstDate = picked.toString();
        _firstDate = _firstDate.substring(0, 10);
        t1.text = _firstDate;
      });
    }
  }

  Future<Null> _selectSecondDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _secondDate = picked.toString();
        _secondDate = _secondDate.substring(0, 10);
        t2.text = _secondDate;
      });
    }
  }
}
