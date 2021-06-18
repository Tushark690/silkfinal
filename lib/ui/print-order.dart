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
  double _totalMat=0,_totalFab=0;
  double _netMat=0,_netFab=0;
  _PrintOrderState(this.partyName,this.invoiceDate,this.invoiceNo,this.payment,this.materialDocs,this.fabricDocs);

  @override
  void initState() {
    materialDocs.forEach((element) {
      _totalMat=_totalMat+element.totalQty;
      _netMat=_netMat+(element.rate*element.totalQty);
    });

    fabricDocs.forEach((element) {
      _totalFab=_totalFab+element.totalQty;
      _netFab=_netFab+(element.rate*element.totalQty);
    });
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
        pdfFileName: "Invoice "+invoiceNo,
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
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("YGP Silk",style: pw.TextStyle(fontSize: 30,fontWeight: pw.FontWeight.bold)),
                  // pw.Spacer(),
                  pw.Text("Purchase Memo 786/92"),
                  // pw.Spacer(),
                  pw.Text(partyName,style: pw.TextStyle(fontSize: 20,fontWeight: pw.FontWeight.bold))
                ]
              ),
              pw.Row(
                children: [
                  pw.Text("Date : "+invoiceDate.toString()),
                  pw.Spacer(),
                  pw.Text("Invoice No : "+invoiceNo.toString())
                ]
              ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Text(payment==null?"Amount : 0":payment=="null"?"Amount : 0":"Amount : "+payment,style: pw.TextStyle(fontWeight: pw.FontWeight.bold),)
                ]
              ),
              pw.SizedBox(height: 10),
              pw.Text("Materials",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,decoration: pw.TextDecoration.underline)),
              pw.SizedBox(height: 10),
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex("D0D0D0")
                ),
                padding: pw.EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                child: pw.Row(
                    children: [
                      pw.Container(
                          width: _colWidth*1.5/10,
                          child: pw.Text("Name",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Container(
                          width: _colWidth*5.5/10,
                          child:  pw.Text("All Qty",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Container(
                          alignment: pw.Alignment.centerRight,
                          width: _colWidth*0.5/10,
                          child: pw.Text("Rate",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Container(
                          alignment: pw.Alignment.centerRight,
                          width: _colWidth*1/10,
                          child: pw.Text("Total Amount",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Container(
                          alignment: pw.Alignment.centerRight,
                          width: _colWidth*1/10,
                          child: pw.Text("Total Qty",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold))
                      ),
                    ]
                ),
              ),
              pw.ListView.builder(
                itemCount: materialDocs.length,
                itemBuilder: (context, index) {
                  return pw.Container(
                   child: pw.Column(
                     children: [
                       pw.Row(
                           children: [
                             pw.Container(
                                 width: _colWidth*1.5/10,
                                 child: pw.Text(materialDocs[index].materialName.toString(),style: pw.TextStyle(fontSize: 9))
                             ),
                             pw.Container(
                                 width: _colWidth*5.5/10,
                                 child:  pw.Text(materialDocs[index].allQty.toString(),style: pw.TextStyle(fontSize: 8))
                             ),
                             pw.Container(
                                 alignment: pw.Alignment.centerRight,
                                 width: _colWidth*0.5/10,
                                 child: pw.Text((materialDocs[index].rate).toString(),style: pw.TextStyle(fontSize: 9))
                             ),
                             pw.Container(
                                 alignment: pw.Alignment.centerRight,
                                 width: _colWidth*1/10,
                                 child: pw.Text((materialDocs[index].rate*materialDocs[index].totalQty).toString(),style: pw.TextStyle(fontSize: 9))
                             ),
                             pw.Container(
                                 alignment: pw.Alignment.centerRight,
                                 width: _colWidth*1/10,
                                 child: pw.Text(materialDocs[index].totalQty.toStringAsFixed(3),style: pw.TextStyle(fontSize: 9))
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
                  pw.Text("Net Amount : "+_netMat.toStringAsFixed(2),style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text("Total : "+_totalMat.toStringAsFixed(3),style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 2),
              pw.Text("Fabrics",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,decoration: pw.TextDecoration.underline)),
              pw.SizedBox(height: 2),
              pw.ListView.builder(
                itemCount: fabricDocs.length,
                itemBuilder: (context, index) {
                  return pw.Container(
                      child: pw.Column(
                          children: [
                            pw.Row(
                                children: [
                                  pw.Container(
                                      width: _colWidth*1.5/10,
                                      child: pw.Text(fabricDocs[index].fabricName.toString()+" "+fabricDocs[index].shade,style: pw.TextStyle(fontSize: 9))
                                  ),
                                  pw.Container(
                                      width: _colWidth*5.5/10,
                                      child: pw.Text(fabricDocs[index].allQty.toString(),style: pw.TextStyle(fontSize: 8))
                                  ),
                                  pw.Container(
                                      alignment: pw.Alignment.centerRight,
                                      width: _colWidth*0.5/10,
                                      child: pw.Text((fabricDocs[index].rate).toString(),style: pw.TextStyle(fontSize: 9))
                                  ),
                                  pw.Container(
                                      alignment: pw.Alignment.centerRight,
                                      width: _colWidth*1/10,
                                      child: pw.Text((fabricDocs[index].rate*fabricDocs[index].totalQty).toString(),style: pw.TextStyle(fontSize: 9))
                                  ),
                                  pw.Container(
                                      alignment: pw.Alignment.centerRight,
                                      width: _colWidth*1/10,
                                      child: pw.Text(fabricDocs[index].totalQty.toStringAsFixed(3),style: pw.TextStyle(fontSize: 9))
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
                  pw.Text("Net Amount : "+_netFab.toStringAsFixed(2),style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text("Total : "+_totalFab.toStringAsFixed(3),style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("YGP Silk",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("Signature",),
                      ]
                  )
                ]
              ),
            ]
          );
        }
      )
    );

    return pdf.save();
  }
}
