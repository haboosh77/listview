
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




import 'package:flutter/material.dart' ;
import 'package:watersupplyadmin/layout/widgets/vendors/vendors_details.dart';
import 'package:watersupplyadmin/services/firebase_services.dart';

class VendorDataTable extends StatefulWidget {

  @override
  State<VendorDataTable> createState() => _VendorDataTableState();
}

class _VendorDataTableState extends State<VendorDataTable> {
  @override
  Widget build(BuildContext context) {

    FirebaseServices _services=FirebaseServices();
    int tag = 0;
    List<String> options = [
      'All Vendors',
      'Active Vendors',
      'Inctive Vendors',
      'Top Picked',
      'Top Rated',
    ];

    bool? topPicked;
    bool? active;
    fliter(val){
      if(val==1){
        setState(() {
          active=true;
        });
      }
      if(val==2){
        setState(() {
          active=false;
        });
      }
      if(val==3){
        setState(() {
          topPicked=true;
        });
      }
      if(val==0){
        setState(() {
          topPicked=null;
          active=null;


        });
      }
    }



    return Column(
crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    ChipsChoice<int>.single(
    value: tag,
      onChanged: (val) {
      setState(() {
        tag=val;

      });
      fliter(val);

      },
      choiceItems: C2Choice.listFrom<int, String>(
       activeStyle: (i,v){
         return C2ChoiceStyle(
           brightness: Brightness.dark,
           color: Colors.black54
         );
       },
        source: options,
        value: (i, v) => i,
        label: (i, v) => v,
      ),
    ),
        Divider(thickness: 5,),
        StreamBuilder(
            stream: _services.vendors.where('isToppicked',isEqualTo: topPicked)
            .where('accVerified',isEqualTo: active)
               // .orderBy('shopName',descending: true)
                .snapshots() ,
            builder:(context,snapshot){
              if(snapshot.hasError){
                return Text('Somthing went wrong');
              }
              if(snapshot.connectionState==ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showBottomBorder: true,
                  dataRowHeight: 60,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                  columns:<DataColumn> [
                    DataColumn(
                        label: Text('Active /Inactive'),),
                    DataColumn(
                        label: Text('top picked'),),
                    DataColumn(
                      label: Text('Rating'),),
                    DataColumn(
                      label: Text('Total Sales'),),
                    DataColumn(
                      label: Text('Mobail'),),
                    DataColumn(
                      label: Text('Email'),),
                    DataColumn(
                      label: Text('View Details'),),


                  ],


                  rows: _vendorsDetailsRows(snapshot.data(),_services),

                ),
              );
            }
        ),
      ],
    );
  }

  List<DataRow> _vendorsDetailsRows(QuerySnapshot? snapshot, FirebaseServices services){
    List<DataRow> newList = snapshot!.docs.map((DocumentSnapshot document) {
      return DataRow(
        cells: [
          DataCell(
            IconButton(onPressed: () {
              services.updateVendorsStatus(
                id: document['uid'],
                status: document['accVerified'],
              );
            },
              icon: document['accVerified']?Icon(Icons.check_circle,color:Colors.green):Icon(Icons.remove_circle,color:Colors.red),),
          ),
           DataCell( IconButton(onPressed: () {
             services.updateVendorsStatus(
               id: document['uid'],
               status: document['isTopPicked'],
             );

           },
                icon: document['isTopPicked']
                  ?Icon(Icons.check_circle,
                  color:Colors.green,
              )
                  :Icon(null,),
          ),
           ),
          DataCell( Text(document['shopName']), ),
          DataCell(Row(
            children: [
              Icon(Icons.star,color: Colors.grey,),
              Text('3.5'),
            ],
          ) ),
             DataCell(Text('20.0000'),),
          DataCell( Text(document['mobile']),),
          DataCell( Text(document['email']),),

          DataCell( IconButton(icon:Icon(Icons.info_outline),
            onPressed: () {
            showDialog(context: context,
                builder: (BuildContext context){
              return VendorsDetailsbox(document['uid']);
                }
                );
            },
          )),

        ] );
    }).toList();
    return newList;
  }
}
