import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FabricMaster extends StatefulWidget {
  @override
  _FabricMasterState createState() => _FabricMasterState();
}

class _FabricMasterState extends State<FabricMaster> {
  TextEditingController _name;
  // TextEditingController _address;
  bool _isAddedPressed=false;

  @override
  void initState() {
    _name=TextEditingController();
    // _address=TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fabric Master"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                          hintText: "Fabric Name"
                      ),
                    ),
                  )
                ],
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //         controller: _address,
              //         decoration: InputDecoration(
              //             hintText: "Party Address"
              //         ),
              //       ),
              //     )
              //   ],
              // ),
              SizedBox(height: 40,),
              ElevatedButton(
                child: Text("Add"),
                onPressed: ()async{
                  if(_name.text.trim().length<1){
                    Fluttertoast.showToast(msg: "Please enter name");
                  }else{
                    if(!_isAddedPressed){
                      _isAddedPressed=true;
                      await FirebaseFirestore.instance.collection("fabricMaster").add({
                        "name":_name.text
                      }).whenComplete(() {
                        Fluttertoast.showToast(msg: "Fabric Added Successfully");
                        _isAddedPressed=false;
                        _name.text="";
                      });

                    }else{
                      Fluttertoast.showToast(msg: "Please wait. Adding Fabric");
                    }
                  }
                },
              ),
              SizedBox(height: 40,),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("fabricMaster").snapshots(),
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    final services=snapshot.data.docs;
                    List<Widget> serviceWidget=[];
                    serviceWidget.add(headtingRow());
                    for(var st in services){
                      final name=st.data()['name'];
                      // final address=st.data()['address'];
                      final sno= st.id;
                      final datas=buildRow(name,sno);
                      serviceWidget.add(datas);
                    }
                    return ListView(
                      children: serviceWidget,
                      shrinkWrap: true,
                      primary: false,
                    );
                  }else{
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget headtingRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 100,
            padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Text("Action",style: TextStyle(fontWeight: FontWeight.w800),)
        ),
        Container(
            width: MediaQuery.of(context).size.width*4/10,
            padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Text("Fabric Name",style: TextStyle(fontWeight: FontWeight.w800),)
        ),
        // Container(
        //     width: MediaQuery.of(context).size.width*4/10,
        //     padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
        //     decoration: BoxDecoration(
        //         border: Border.all(color: Colors.black)
        //     ),
        //     child: Text("Party Address",style: TextStyle(fontWeight: FontWeight.w800),)
        // ),
      ],
    );
  }

  Widget buildRow(name,sno){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 100,
            height: 40,
            padding: EdgeInsets.only(left: 20,right: 20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: IconButton(
              icon: Icon(Icons.delete_forever,color: Colors.red,),
              onPressed: (){
                FirebaseFirestore.instance.collection("fabricMaster").doc(sno).delete().whenComplete(() {
                  Fluttertoast.showToast(msg: "Fabric Deleted");
                });
              },
            )
        ),
        Container(
            height: 40,
            width: MediaQuery.of(context).size.width*4/10,
            padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Text(name)
        ),
        // Container(
        //     height: 40,
        //     width: MediaQuery.of(context).size.width*4/10,
        //     padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
        //     decoration: BoxDecoration(
        //         border: Border.all(color: Colors.black)
        //     ),
        //     child: Text(address)
        // ),
      ],
    );
  }
}
