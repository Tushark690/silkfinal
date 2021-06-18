import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
class Ledger extends StatefulWidget {
  final allData;
  Ledger(this.allData);
  @override
  _LedgerState createState() => _LedgerState(allData);
}

class _LedgerState extends State<Ledger> {
  String jsonAllData;
  List allData=[];
  _LedgerState(this.jsonAllData);
  Map<String,dynamic> map = Map();
  List<pw.Widget> list=[];
  double _totalPayment=0;
  @override
  void initState() {
    allData=jsonDecode(jsonAllData);
    for(var c in allData){
      for(var a in c["mat"]){
        map.update(a['materialName'], (value) => value+a["totalQty"],ifAbsent: () => a['totalQty'],);
      }

      for(var a in c["fab"]){
        map.update(a['fabricName'], (value) => value+a["totalQty"],ifAbsent: () => a['totalQty'],);
      }
    }
    for(var l in map.keys){
      list.add(
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex("D3D3D3"),
            borderRadius: pw.BorderRadius.circular(5)
          ),
          child: pw.Text(l+" "+map[l].toString(),style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold))
        )
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Print"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: PdfPreview(
        build: (format)=>_generatedPdf(),
        pdfFileName: "Invoice ",
      ),
    );
  }

  Future<Uint8List> _generatedPdf()async{
    final pdf = pw.Document();
    double _colWidth=PdfPageFormat.a4.portrait.width;
    pdf.addPage(
        pw.Page(
        pageFormat: PdfPageFormat.a4.portrait ,
        margin: pw.EdgeInsets.only(left: 10,right: 10,bottom: 5),
    build: (con){
    return pw.Column(
    children: [
      pw.Column(
        children: [
          pw.Text(allData[0]['partyName']),
          pw.Text(allData[0]['firstDate']+" - "+allData[0]['secondDate'])
        ]
      ),
      pw.ListView.builder(
        itemCount: allData.length,
        itemBuilder: (context,i){
          List<pw.Widget> data1=[];
          List<pw.Widget> data2=[];
          _totalPayment=_totalPayment+allData[i]['payment'];
          for(var a in allData[i]["mat"]){
            data1.add(
              pw.Container(
                padding: pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex("D3D3D3"),
                    borderRadius: pw.BorderRadius.circular(5)
                ),
                child: pw.Text(a['materialName'].toString()+" : "+a['totalQty'].toString(),style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold))
              ),
            );
          }
          for(var a in allData[i]["fab"]){
            data2.add(
              pw.Container(
                  padding: pw.EdgeInsets.all(4),
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex("D3D3D3"),
                      borderRadius: pw.BorderRadius.circular(5)
                  ),
                  child: pw.Text(a['fabricName'].toString()+" : "+a['totalQty'].toString(),style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold))
              ),
            );
          }
          return pw.Column(
            children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Row(
                      children: [
                        pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColor.fromHex("f2f2f2")),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text("Inv No. "+allData[i]['invoiceNo'].toString(),style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                                pw.Text(allData[i]['date'].toString(),style: pw.TextStyle(fontSize: 7,fontWeight: pw.FontWeight.bold)),
                                pw.Text(allData[i]['payment'].toString(),style: pw.TextStyle(fontSize: 7,fontWeight: pw.FontWeight.bold)),
                              ]
                          ),
                        ),
                        pw.SizedBox(width: 5),
                        pw.Container(
                          // height: 100,
                          width: 500,
                          child: pw.Column(
                            children: [
                              pw.GridView(
                                  crossAxisCount: 5,
                                  childAspectRatio: 0.18,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  children: data1
                              ),
                              pw.SizedBox(height: 5),
                              pw.GridView(
                                  crossAxisCount: 5,
                                  childAspectRatio: 0.18,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  children: data2
                              ),
                            ]
                          )
                        ),


                      ]
                  )
              ),
              pw.Divider(height: 0)
            ]
          );
        }
      ),
      pw.SizedBox(height: 5),
      pw.Row(
        children: [
          pw.Text("Total : ",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,)),
        ]
      ),
      pw.SizedBox(height: 5),
      pw.Row(
        children: [
          pw.Text("Payment : "+_totalPayment.toString(),style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold,)),
        ]
      ),
      pw.SizedBox(height: 5),
      pw.GridView(
        crossAxisCount: 5,
        childAspectRatio: 0.15,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: list
      )
    ]
    );
        }
        )
    );
    return pdf.save();
  }
}
