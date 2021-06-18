import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:silk/model/FabricModel.dart';
import 'package:silk/model/MaterialModel.dart';
import 'package:silk/ui/fabric-master.dart';
import 'package:silk/ui/material-master.dart';
import 'package:silk/ui/party-master.dart';
import 'package:silk/ui/print-order.dart';
import 'package:silk/ui/records.dart';
import 'package:silk/ui/shades-master.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().whenComplete(() {
    print("completed");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YGP Silk',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'YGP Silk Billing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _partyValue = "0";
  var _materialValue = "0";
  var _shadesValue = "0";
  var _fabricValue = "0";
  var _unitValue = "kg";
  bool _submitPressed = false;
  List<DropdownMenuItem> _units = [];
  TextEditingController _amount;
  TextEditingController _materialQuantity;
  TextEditingController _materialRate;
  TextEditingController _fabricQuantity;
  TextEditingController _fabricRate;

  double textSize = 0;
  double totalMaterial = 0;
  List<MaterialModel> _materialList = List.empty(growable: true);
  double _overallMaterial=0;
  double _totalMaterialRate=0;

  double _totalFabric = 0;
  List<FabricModel> _fabricList = List.empty(growable: true);
  double _overallFabric=0;
  double _totalFabricRate=0;

  TextEditingController t1;
  String _firstDate="";

  // Future<void> _createPDF() async {
  //   PdfDocument document = PdfDocument();
  //   document.pages.add();
  //
  //   List<int> bytes = document.save();
  //   document.dispose();
  //
  //   saveAndLaunchFile(bytes, 'Output.pdf');
  // }

  @override
  void initState() {
    _units.add(DropdownMenuItem(
      child: Text("Kg"),
      value: "kg",
    ));
    _amount = TextEditingController();
    _materialQuantity = TextEditingController();
    _fabricQuantity = TextEditingController();
    _fabricRate = TextEditingController();
    _materialRate=TextEditingController();
    t1=new TextEditingController(text: DateTime.now().toString().split(" ")[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // initialMaterialTotal = initialMaterialQuantityList.fold(
    //     0, (previousValue, element) => previousValue + element);
    // initialFabricTotal = initialFabricQuantityList.fold(
    //     0, (previousValue, element) => previousValue + element);
    textSize = MediaQuery.of(context).size.height * 0.02;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              ListTile(
                title: Text("Party Master"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PartyMaster(),
                  ));
                },
              ),
              ListTile(
                title: Text("Material Master"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MaterialMaster(),
                  ));
                },
              ),
              ListTile(
                title: Text("Fabric Master"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FabricMaster(),
                  ));
                },
              ),
              ListTile(
                title: Text("Shade Master"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ShadesMaster(),
                  ));
                },
              ),
              ListTile(
                title: Text("Records"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Records(),
                  ));
                },
              ),
            ],
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("invoice")
                            .limit(1)
                            .orderBy("invoiceNo", descending: true)
                            .snapshots(),
                        builder: (context,snap){
                          if(!snap.hasData){
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              snap.data.docs.length>0?Text("Invoice : "+(snap.data.docs[0].get("invoiceNo")+1).toString(),style: TextStyle(fontWeight: FontWeight.w800),)
                                  :Text("Invoice : 1"),
                              SizedBox(width: 200,),
                              Container(
                                  width: 200,
                                  height: 50,
                                  child: InkWell(
                                    onTap:(){
                                      _selectFirstDate(context);
                                    },
                                    child: TextFormField(
                                      enabled: false,
                                      controller: t1,
                                      decoration: InputDecoration(
                                        hintText: "Date",
                                        icon: Icon(
                                          Icons.calendar_today,
                                        ),
                                      ),
                                    ),
                                  )
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("partyMaster")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DropdownMenuItem> items = [];
                              final datas = snapshot.data.docs;
                              items.add(DropdownMenuItem(
                                child: Text(
                                  "Please select party",
                                  style: TextStyle(fontSize: textSize),
                                ),
                                value: "0",
                              ));
                              for (var st in datas) {
                                items.add(DropdownMenuItem(
                                  child: Text(
                                    st.data()['name'],
                                    style: TextStyle(fontSize: textSize),
                                  ),
                                  value: st.data()['name'],
                                ));
                              }
                              return Expanded(
                                  child: Container(
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
                              ));
                            } else {
                              return Text("Loading...");
                            }
                          })
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Receive Payment",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: textSize),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: "Amount in numbers",
                            hintStyle: TextStyle(fontSize: textSize)),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        "Material Given : ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: textSize),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("materialMaster")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DropdownMenuItem> items = [];
                              final datas = snapshot.data.docs;
                              items.add(DropdownMenuItem(
                                child: Text(
                                  "Please select material",
                                  style: TextStyle(fontSize: textSize),
                                ),
                                value: "0",
                              ));
                              for (var st in datas) {
                                items.add(DropdownMenuItem(
                                  child: Text(
                                    st.data()['name'],
                                    style: TextStyle(fontSize: textSize),
                                  ),
                                  value: st.data()['name'],
                                ));
                              }
                              return Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 2),
                                    borderRadius: BorderRadius.circular(5)),
                                child: DropdownButtonFormField(
                                  items: items,
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  value: _materialValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _materialValue = value;
                                    });
                                  },
                                ),
                              ));
                            } else {
                              return Text("Loading...");
                            }
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(5)),
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            items: _units,
                            // style: TextStyle(fontSize: textSize),
                            value: _unitValue,
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            onChanged: (value) {
                              setState(() {
                                _unitValue = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                _buildRow(),
                _totalMaterialTable(),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        "Fabric Received",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: textSize),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("fabricMaster")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DropdownMenuItem> items = [];
                              final datas = snapshot.data.docs;
                              items.add(DropdownMenuItem(
                                child: Text("Please select fabric"),
                                value: "0",
                              ));
                              for (var st in datas) {
                                items.add(DropdownMenuItem(
                                  child: Text(st.data()['name']),
                                  value: st.data()['name'],
                                ));
                              }
                              return Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 2),
                                    borderRadius: BorderRadius.circular(5)),
                                child: DropdownButtonFormField(
                                  items: items,
                                  // style: TextStyle(fontSize: textSize),
                                  value: _fabricValue,
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  onChanged: (value) {
                                    setState(() {
                                      _fabricValue = value;
                                    });
                                  },
                                ),
                              ));
                            } else {
                              return Text("Loading...");
                            }
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 140,
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _fabricQuantity,
                        decoration: InputDecoration(
                            hintText: "Total Quantity",
                            hintStyle: TextStyle(fontSize: textSize)),
                        onChanged: (value) {
                          _totalFabric=0;
                          for(var a in  value.split("+")){
                            setState(() {
                              if(a.trim().length>0){
                                _totalFabric = _totalFabric+double.parse(a);
                              }
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _fabricRate,
                        decoration: InputDecoration(
                            hintText: "Rate",
                            hintStyle: TextStyle(fontSize: textSize)),

                      ),
                    ),
                    SizedBox(width: 30,),
                    Expanded(
                      flex: 0,
                      child: ElevatedButton(
                        onPressed: () {
                          if(_fabricValue=="0"){
                            Fluttertoast.showToast(msg: "Please select fabric");
                          }else if(_fabricQuantity.text.trim().length<1){
                            Fluttertoast.showToast(msg: "Please enter fabric quantity");
                          }else{
                            setState(() {
                              FabricModel fabricModel = FabricModel();
                              fabricModel.fabricName=_fabricValue;
                              fabricModel.shade=_shadesValue;
                              fabricModel.allQty=_fabricQuantity.text;
                              fabricModel.totalQty=_totalFabric;
                              fabricModel.rate=_fabricRate.text.isEmpty?0:double.parse(_fabricRate.text);
                              _fabricList.add(fabricModel);
                              _fabricQuantity.clear();
                              _overallFabric=0;
                              _fabricRate.clear();
                              for(var a in _fabricList){
                                _overallFabric=_overallFabric+a.totalQty;
                                _totalFabricRate=_totalFabricRate+a.rate;
                              }
                            });
                          }
                        },
                        child: Text(
                          "Add More",
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                    ),
                    Expanded(flex: 2, child: Text("Total: "+_totalFabric.toStringAsFixed(3)))
                  ],
                ),
                _totalFabricTable(),
                SizedBox(
                  height: 40,
                ),
                Container(
                  height: 3,
                  width: double.infinity,
                  color: Colors.blue,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      child: Text("Save"),
                      onPressed: () {
                        _saveInvoice(false);
                      },
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                    ),
                    ElevatedButton(
                      child: Text("Save and Print"),
                      onPressed: () {
                        _saveInvoice(true);
                        // _createPDF();
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ));
  }

  Row _buildRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 140,
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _materialQuantity,
            decoration: InputDecoration(
                hintText: "Total Quantity",
                hintStyle: TextStyle(fontSize: textSize)),
            onChanged: (value) {
              // if(value.endsWith("+")){
              totalMaterial=0;
                for(var a in  value.split("+")){
                  setState(() {
                    if(a.trim().length>0){
                      totalMaterial = totalMaterial+double.parse(a);
                    }
                  });
                }
              // }
            },
          ),
        ),
        SizedBox(width: 10,),
        Expanded(
          flex: 1,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _materialRate,
            decoration: InputDecoration(
                hintText: "Rate",
                hintStyle: TextStyle(fontSize: textSize)),
          ),
        ),
        SizedBox(width: 30,),
        Expanded(
          flex: 0,
          child: ElevatedButton(
            onPressed: () {
              if(_materialQuantity.text.length<1){
                Fluttertoast.showToast(msg: "Please enter quantity");
              }else if(_materialValue=="0"){
                Fluttertoast.showToast(msg: "Please select material");
              }else{
                setState(() {
                  MaterialModel materialModel = MaterialModel();
                  materialModel.materialName=_materialValue;
                  materialModel.unit=_unitValue;
                  materialModel.allQty=_materialQuantity.text;
                  materialModel.totalQty=totalMaterial;
                  materialModel.rate=_materialRate.text.isEmpty?0:double.parse(_materialRate.text);
                  _materialList.add(materialModel);
                  _materialQuantity.clear();
                  _materialRate.clear();
                  _overallMaterial=0;
                  for(var a in _materialList){
                    _overallMaterial=_overallMaterial+a.totalQty;
                    _totalMaterialRate=_totalMaterialRate+a.rate;
                  }
                });
              }
            },
            child: Text(
              "Add More",
              style: TextStyle(fontSize: textSize),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.08,
        ),
        Expanded(flex: 2, child: Text("Total: "+totalMaterial.toStringAsFixed(3))),
      ],
    );
  }

  Widget _totalMaterialTable(){
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _materialList.length,
            itemBuilder: (context,i){
              return ListTile(
                leading: IconButton(icon: Icon(Icons.delete_forever),
                onPressed: (){
                  setState(() {
                    _materialList.removeAt(i);
                  });
                },),
                title: Text(_materialList[i].materialName+" "+_materialList[i].allQty),
                trailing: Text(
                    (_materialList[i].rate*_materialList[i].totalQty).toStringAsFixed(2)+"  "+
                  _materialList[i].totalQty.toStringAsFixed(3) + " "+_materialList[i].unit,style: TextStyle(fontWeight: FontWeight.w800),),
              );
            },
          ),
          ListTile(
            trailing: Text("Total : "+_overallMaterial.toStringAsFixed(3)+" KG",style: TextStyle(fontWeight: FontWeight.w800),),
          )
        ],
      ),
    );
  }

  Widget _totalFabricTable(){
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _fabricList.length,
            itemBuilder: (context,i){
              return ListTile(
                leading: IconButton(icon: Icon(Icons.delete_forever),
                  onPressed: (){
                    setState(() {
                      _fabricList.removeAt(i);
                    });
                  },),
                title: Text(_fabricList[i].fabricName+" "+_fabricList[i].allQty),
                trailing: Text(
                    (_fabricList[i].rate*_fabricList[i].totalQty).toStringAsFixed(2)+"  "+
                  _fabricList[i].totalQty.toStringAsFixed(3),style: TextStyle(fontWeight: FontWeight.w800),),
              );
            },
          ),
          ListTile(
            trailing: Text("Total : "+_overallFabric.toStringAsFixed(3),style: TextStyle(fontWeight: FontWeight.w800),),
          )
        ],
      ),
    );
  }

  _saveInvoice(isPrint) async {
    if (_partyValue == "0") {
      Fluttertoast.showToast(msg: "Please select party");
    } else {
      if (!_submitPressed) {
        _submitPressed = true;
        _otpSentAlertBox(context);
        int invoiceNo = 1;
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
        String rDate=DateFormat("yyyy-MM-dd").format(now);
        FirebaseFirestore.instance
            .collection("invoice")
            .limit(1)
            .orderBy("invoiceNo", descending: true)
            .get()
            .then((QuerySnapshot snapshot) {
          if (snapshot.size == 0) {
            FirebaseFirestore.instance
                .collection("invoice")
                .add(({
                  "partyName": _partyValue,
                  "payment": double.tryParse(_amount.text)==null?0:double.tryParse(_amount.text),
                  "invoiceNo": invoiceNo,
                  "date": formattedDate,
                  "timeStamp": now,
                  "reportDate":t1.text
                })).then((value) {
                  _materialList.forEach((element) {
                    FirebaseFirestore.instance.collection("materialInvoice").add({
                      "materialName":element.materialName,
                      "unit":element.unit,
                      "totalQty":element.totalQty,
                      "allQty":element.allQty,
                      "invoice":value.id,
                      "rate":element.rate
                    });
                  });
                  _fabricList.forEach((element) {
                    FirebaseFirestore.instance.collection("fabricInvoice").add({
                      "fabricName":element.fabricName,
                      "shade":element.shade,
                      "totalQty":element.totalQty,
                      "allQty":element.allQty,
                      "invoice":value.id,
                      "rate":element.rate
                    });
                  });
            }).whenComplete(() {
              Fluttertoast.showToast(msg: "Invoice Saved");
              _submitPressed = false;
              if(isPrint){
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder:(context) => PrintOrder(_partyValue, t1.text, invoiceNo, _amount.text, _materialList, _fabricList),)).then((value) {
                 setState(() {
                   _fabricList=[];
                   _materialList=[];
                   _amount.text="";
                   _materialRate.text="";
                   _fabricRate.text="";
                 });
                });
              }else{
                Navigator.of(context).pop();
                setState(() {
                  _fabricList=[];
                  _materialList=[];
                  _amount.text="";
                  _materialRate.text="";
                  _fabricRate.text="";
                });
              }

            });
          } else {
            snapshot.docs.forEach((element) {
              invoiceNo = element.data()["invoiceNo"] + 1;
              FirebaseFirestore.instance
                  .collection("invoice")
                  .add(({
                    "partyName": _partyValue,
                    "payment": double.tryParse(_amount.text),
                    "invoiceNo": invoiceNo,
                    "date": formattedDate,
                    "timeStamp": now,
                    "reportDate":t1.text
                  })).then((value) {
                _materialList.forEach((element) {
                  FirebaseFirestore.instance.collection("materialInvoice").add({
                    "materialName":element.materialName,
                    "unit":element.unit,
                    "totalQty":element.totalQty,
                    "allQty":element.allQty,
                    "invoice":value.id,
                    "rate":element.rate
                  });
                });
                _fabricList.forEach((element) {
                  FirebaseFirestore.instance.collection("fabricInvoice").add({
                    "fabricName":element.fabricName,
                    "shade":element.shade,
                    "totalQty":element.totalQty,
                    "allQty":element.allQty,
                    "invoice":value.id,
                    "rate":element.rate
                  });
                });
              })
                  .whenComplete(() {
                Fluttertoast.showToast(msg: "Invoice Saved");
                _submitPressed = false;
                if(isPrint){
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder:(context) => PrintOrder(_partyValue, t1.text, invoiceNo, _amount.text, _materialList, _fabricList),)).then((value) {
                    setState(() {
                      _fabricList=[];
                      _materialList=[];
                      _amount.text="";
                      _materialRate.text="";
                      _fabricRate.text="";
                    });
                  });
                }else{
                  Navigator.of(context).pop();
                  setState(() {
                    _fabricList=[];
                    _materialList=[];
                    _amount.text="";
                    _materialRate.text="";
                    _fabricRate.text="";
                  });
                }
                // _fabricList=[];
                // _materialList=[];
              });
            });
          }
        });
      } else {
        Fluttertoast.showToast(msg: "Please wait. Submitting the invoice");
      }
    }
  }

  _otpSentAlertBox(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black87),
          ),
          SizedBox(width: 20,),
          Text("Please Wait...")
        ],
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
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
}
