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
  var _partyValue = "0";
  List<FabricModel> _fabricList=[];
  List<MaterialModel> _materialList=[];
  TextEditingController t1 = new TextEditingController();
  TextEditingController t2 = new TextEditingController();
  String _firstDate="",_secondDate="",_date="";
  CollectionReference _records;
  var _data;
  List<DataRow> serviceWidget = [];

  _getRecords()async{
    try{
      _records=FirebaseFirestore.instance
          .collection("invoice");
    }catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    _data=_getRecords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Flutter DataTable Example'),
          ),
          body: FutureBuilder(
            future: _data,
            builder: (context, snap) {
             if(snap.connectionState==ConnectionState.done){
               return ListView(children: <Widget>[
                 _customDate(),
                 Center(
                     child: Text(
                       'Records',
                       style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                     )
                 ),
                 SingleChildScrollView(
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
                     ],
                     rows: serviceWidget,
                   ),
                 )
               ]);
             }else{
               return Center(
                 child: CircularProgressIndicator(),
               );
             }
            }
          )),
    );
  }

  DataRow buildRow(
    invoiceNo,
    date,
    party,
    payment,
    id
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
    ]);
  }

  _bottomModalInvoice(id,invoiceNo,date,party,payment){
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("partyMaster")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DropdownMenuItem> items = [];
                    final datas = snapshot.data.docs;
                    items.add(DropdownMenuItem(
                      child: Text("All party",),
                      value: "0",
                    ));
                    for (var st in datas) {
                      items.add(DropdownMenuItem(
                        child: Text(
                          st.data()['name'],),
                        value: st.data()['name'],
                      ));
                    }
                    return Container(
                      padding: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                          items: items,
                          value: _partyValue,
                          decoration: InputDecoration(
                              border: InputBorder.none),
                          onChanged: (value) {
                            setState(() {
                              _partyValue = value;
                            });
                          },
                        ),
                      ),
                    );
                  } else {
                    return Text("Loading...");
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: RaisedButton(
                  child: Text("Search",style: TextStyle(color: Colors.white),),
                  color: Colors.blue,
                  onPressed: (){
                    _getData();
                  // try{
                  //   String p=_partyValue.trim();
                  //   String f=_firstDate;
                  //   String s=_secondDate;
                  //   print(p);
                  //   if(p=="0"){
                  //     setState(() {
                  //       _records=q
                  //           .where("reportDate",isGreaterThanOrEqualTo: f,isLessThanOrEqualTo: s)
                  //           .orderBy("reportDate", descending: true);
                  //     });
                  //   }else{
                  //     setState(() {
                  //       _records=q.where("reportDate",isGreaterThanOrEqualTo: f,isLessThanOrEqualTo: s,)
                  //           .where("partyName",isEqualTo: p).orderBy("reportDate", descending: true);
                  //     });
                  //
                  //   }
                  // }catch(e){
                  //   print(e);
                  // }
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

  _getData(){
    serviceWidget=[];
    if(_partyValue=="0"){
      _records.where("reportDate",isGreaterThanOrEqualTo: _firstDate,isLessThanOrEqualTo: _secondDate)
         .orderBy("reportDate", descending: true).get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((element) {
          final invoiceNo = element.get('invoiceNo');
          final date =element.get('date').toString();
          final partyName = element.get('partyName');
          final payment = element.get('payment');
          final sno = element.id;
          final datas = buildRow(
              invoiceNo,
              date,
              partyName,
              payment,
              sno
          );
          setState(() {
            serviceWidget.add(datas);
          });
        });
      } );
    }else{
      _records.where("reportDate",isGreaterThanOrEqualTo: _firstDate,isLessThanOrEqualTo: _secondDate)
          .where("partyName",isEqualTo: _partyValue).orderBy("reportDate", descending: true).get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((element) {
          final invoiceNo = element.get('invoiceNo');
          final date =element.get('date').toString();
          final partyName = element.get('partyName');
          final payment = element.get('payment');
          final sno = element.id;
          final datas = buildRow(
              invoiceNo,
              date,
              partyName,
              payment,
              sno
          );
          setState(() {
            serviceWidget.add(datas);
          });
        });
      } );
    }

  }
}
