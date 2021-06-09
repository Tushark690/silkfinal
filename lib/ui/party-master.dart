import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PartyMaster extends StatefulWidget {
  @override
  _PartyMasterState createState() => _PartyMasterState();
}

class _PartyMasterState extends State<PartyMaster> {
  TextEditingController _name;
  TextEditingController _address;
  bool _isAddedPressed=false;

  @override
  void initState() {
    _name=TextEditingController();
    _address=TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Party Master"),
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
                        hintText: "Party Name"
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _address,
                      decoration: InputDecoration(
                          hintText: "Party Address"
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 40,),
              ElevatedButton(
                child: Text("Add"),
                onPressed: ()async{
                  if(_name.text.trim().length<1){
                    Fluttertoast.showToast(msg: "Please enter name");
                  }else if(_address.text.trim().length<1){
                    Fluttertoast.showToast(msg: "Please enter address");
                  }else{
                    if(!_isAddedPressed){
                      _isAddedPressed=true;
                      await FirebaseFirestore.instance.collection("partyMaster").add({
                        "name":_name.text,
                        "address": _address.text
                      }).whenComplete(() {
                        Fluttertoast.showToast(msg: "Party Added Successfully");
                        _isAddedPressed=false;
                        _name.text="";
                        _address.text="";
                      });

                    }else{
                      Fluttertoast.showToast(msg: "Please wait. Adding party");
                    }
                  }
                },
              ),
              SizedBox(height: 40,),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("partyMaster").snapshots(),
                builder: (context,snapshot){
                    if(snapshot.hasData){
                      final services=snapshot.data.docs;
                      List<Widget> serviceWidget=[];
                      serviceWidget.add(headtingRow());
                      for(var st in services){
                        final name=st.data()['name'];
                        final address=st.data()['address'];
                        final sno= st.id;
                        final datas=buildRow(name,address,sno);
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
            child: Text("Party Name",style: TextStyle(fontWeight: FontWeight.w800),)
        ),
        Container(
            width: MediaQuery.of(context).size.width*4/10,
            padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Text("Party Address",style: TextStyle(fontWeight: FontWeight.w800),)
        ),
      ],
    );
  }
  
  Widget buildRow(name,address,sno){
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
                FirebaseFirestore.instance.collection("partyMaster").doc(sno).delete().whenComplete(() {
                  Fluttertoast.showToast(msg: "Party Deleted");
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
        Container(
            height: 40,
            width: MediaQuery.of(context).size.width*4/10,
            padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black)
            ),
            child: Text(address)
        ),
      ],
    );
  }
}
