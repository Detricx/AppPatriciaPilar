import 'package:drh_project/screens/Utilizador/Documents/irs/screen_irs.dart';
import 'package:drh_project/screens/Utilizador/Documents/rv/screen_rv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:drh_project/widgets/fundo_app.dart';
import 'package:flutter/material.dart';

class DocsScreen extends StatefulWidget {
  final String nifEmpresa;
  const DocsScreen(this.nifEmpresa, { Key? key }) : super(key: key);
  
  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,

      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: fundoApp(
          'assets/fundos/fundo_docs.png',  
          0,
          Expanded(
            child: Column(
              children: <Widget>[
                TabBar(
                  labelPadding: const EdgeInsets.all(10),
                  tabs: [
                    Text(
                      t.reciboVenc,
                      style: const TextStyle(
                        fontFamily: 'DaysOne',
                        fontSize: 15,
                        color: Colors.white,
                      )
                    ),
                    Text(
                      t.reciboIRS,
                      style: const TextStyle(
                        fontFamily: 'DaysOne',
                        fontSize: 15,
                        color: Colors.white,
                      )
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ReciboVencimentoMenuScreen(nifEmpresa: widget.nifEmpresa),
                      IrsMenuScreen(nifEmpresa: widget.nifEmpresa),
                    ],
                  ),
                )
              ]
            )
          )
        )
      ),
    );
  }
}
