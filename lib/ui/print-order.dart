import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:silk/model/FabricModel.dart';
import 'package:silk/model/MaterialModel.dart';

class PrintOrder extends StatefulWidget {
  final partyName,invoiceDate,invoiceNo,payment;
  final List materialDocs,fabricDocs;
  PrintOrder(this.partyName,this.invoiceDate,this.invoiceNo,this.payment,this.materialDocs,this.fabricDocs);
  @override
  _PrintOrderState createState() => _PrintOrderState(partyName,invoiceDate,invoiceNo,payment, materialDocs,fabricDocs);
}

class _PrintOrderState extends State<PrintOrder> {
  final partyName,invoiceDate,invoiceNo,payment;
  final List<MaterialModel> materialDocs;
  final List<FabricModel> fabricDocs;
  int _totalMat=0,_totalFab=0;
  _PrintOrderState(this.partyName,this.invoiceDate,this.invoiceNo,this.payment,this.materialDocs,this.fabricDocs);

  @override
  void initState() {
    print(invoiceDate.toString().split("\n")[1]);
    materialDocs.forEach((element) {
      _totalMat=_totalMat+element.totalQty;
    });

    fabricDocs.forEach((element) {
      _totalFab=_totalFab+element.totalQty;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Print"),
      ),
      body: PdfPreview(
        build: (format)=>_generatedPdf(),
        pdfFileName: "Invoice 1",
      ),
    );
  }

  Future<Uint8List> _generatedPdf()async{
    final pdf = pw.Document();
    double _colWidth=PdfPageFormat.a5.landscape.width;
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: pw.EdgeInsets.all(10),
        build: (con){
          return pw.Column(
            // crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text("YGP Silk",style: pw.TextStyle(fontSize: 30,fontWeight: pw.FontWeight.bold)),
                  pw.Spacer(),
                  pw.Text(partyName,style: pw.TextStyle(fontSize: 20,fontWeight: pw.FontWeight.bold))
                ]
              ),
              pw.Row(
                children: [
                  pw.Text("Date :"+invoiceDate.toString().split("\n")[1]+" "+invoiceDate.toString().split("\n")[0]),
                  pw.Spacer(),
                  pw.Text("Invoice No :"+invoiceNo.toString())
                ]
              ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Text("Amount : "+payment,style: pw.TextStyle(fontWeight: pw.FontWeight.bold),)
                ]
              ),
              pw.SizedBox(height: 10),
              pw.Text("Materials",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,decoration: pw.TextDecoration.underline)),
              pw.SizedBox(height: 10),
              pw.ListView.builder(
                itemCount: materialDocs.length,
                itemBuilder: (context, index) {
                  return pw.Container(
                   child: pw.Column(
                     children: [
                       pw.Row(
                           children: [
                             pw.Container(
                                 width: _colWidth*2/10,
                                 child: pw.Text(materialDocs[index].materialName.toString(),style: pw.TextStyle(fontSize: 9))
                             ),
                             pw.Container(
                                 width: _colWidth/2,
                                 child:  pw.Text(materialDocs[index].allQty.toString(),style: pw.TextStyle(fontSize: 8))
                             ),
                             pw.Container(
                                 alignment: pw.Alignment.centerRight,
                                 width: _colWidth*2/10,
                                 child: pw.Text(materialDocs[index].totalQty.toString(),style: pw.TextStyle(fontSize: 9))
                             ),
                           ]
                       ),
                       pw.Divider(color: PdfColor.fromHex("b7a5ae"),height: 1)
                     ]
                   )
                  );
                },
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text("Total : "+_totalMat.toString(),style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 10),
              pw.Text("Fabrics",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,decoration: pw.TextDecoration.underline)),
              pw.SizedBox(height: 10),
              pw.ListView.builder(
                itemCount: fabricDocs.length,
                itemBuilder: (context, index) {
                  return pw.Container(
                      child: pw.Column(
                          children: [
                            pw.Row(
                                children: [
                                  pw.Container(
                                      width: _colWidth*2/10,
                                      child: pw.Text(fabricDocs[index].fabricName.toString()+" "+fabricDocs[index].shade,style: pw.TextStyle(fontSize: 9))
                                  ),
                                  pw.Container(
                                      width: _colWidth/2,
                                      child: pw.Text(fabricDocs[index].allQty.toString(),style: pw.TextStyle(fontSize: 9))
                                  ),
                                  pw.Container(
                                      alignment: pw.Alignment.centerRight,
                                      width: _colWidth*2/10,
                                      child: pw.Text(fabricDocs[index].totalQty.toString(),style: pw.TextStyle(fontSize: 9))
                                  ),
                                ]
                            ),
                            pw.Divider(color: PdfColor.fromHex("b7a5ae"),height: 1)
                          ]
                      )
                  );
                },
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text("Total : "+_totalFab.toString(),style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 10),
            ]
          );
        }
      )
    );

    return pdf.save();
  }
}
