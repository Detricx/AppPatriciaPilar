import 'package:drh_project/models/recibo_vencimento.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReciboVencimentoScreen extends StatefulWidget {
  //Vou buscar o valor do NIF
  final ReciboVenc recibo;
  final String nifEmpresa;
  const ReciboVencimentoScreen({Key? key, required this.recibo, required this.nifEmpresa}) : super(key: key);

  @override
  State<ReciboVencimentoScreen> createState() => _ReciboVencimentoScreenState();
}

class _ReciboVencimentoScreenState extends State<ReciboVencimentoScreen> {
  
  PrintingInfo? printingInfo;
  
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async{
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
  }

  //Mostrar barra em baixo de download sucedido
  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download Realizado com Sucesso'),
      ),
    );
  }

  //Mostrar barra em baixo de partilha feita
  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partilha do Documento Realizada'),
      ),
    );
  }

 
  /*//! Salvar o documento do dispositivo
  Future<File> _saveAsFile(BuildContext context, LayoutCallback build, PdfPageFormat pageFormat) async {
    //Tamanho do ficheiro
    final bytes = await build(pageFormat);
    
    //Adquirir uma pasta para deixar este documento
    final appDocDir = await getApplicationDocumentsDirectory();
    
    //Caminho convertido para String
    final appDocPath = appDocDir.path;

    String nomeFicheiro = 'document';

    final file = File('$appDocPath/$nomeFicheiro.pdf');
    
    //Colocar toda a informação dentro do pdf
    await file.writeAsBytes(bytes);

    return file;
  }
  */

  Future<Uint8List> gerarDocument(PdfPageFormat format, ReciboVenc recibo, String empresa) async{
    final doc = pw.Document(pageMode: PdfPageMode.outlines);
    
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    //!Aplicar uma condição aqui !!!
    final ByteData bytes = await rootBundle.load('assets/icons/logos/$empresa.jpg');
    final Uint8List byteList = bytes.buffer.asUint8List();

    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: format.copyWith(
            marginBottom: 10,
            marginLeft: 10,
            marginRight: 10,
            marginTop: 10,
          ),
          orientation: pw.PageOrientation.portrait,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),
        build: (context) {
          return pw.Column(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Row(
                  children: [
                    //!Logo da Empresa
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: pw.Alignment.center,
                        child: pw.Image(
                          fit: pw.BoxFit.contain,
                          pw.MemoryImage(
                            byteList,
                          ),  
                        ),
                      )
                    ),

                    //!Informações sobre a empresa
                    pw.Expanded(
                      flex: 6,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              recibo.empresaNome,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            pw.Text(
                              recibo.empresaMorada,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            pw.Text(
                              recibo.empresaCodPostal,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            pw.Text(
                              recibo.empresaLocalizacao,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            pw.Text(
                              'NIF: ${recibo.empresaContribuinte}',
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            )
                          ]
                        ),
                      )
                    ),
        
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          //! Número do recibo
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                'RECIBO Nº  ',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold
                                ),
                              ),
                              pw.Text(
                                recibo.nRecibo,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold
                                  ),
                              )
                            ]
                          ),
                          pw.Text(
                            'Original',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              fontStyle: pw.FontStyle.italic,
                              
                            ),
                          ),
                          //! Data da submissão do documento
                          
                          pw.Text(
                            recibo.data.replaceAll("-", "."),
                            style: const pw.TextStyle(
                              fontSize: 12,
                            ),
                          )
                        ]
                      )
                    ),
                  ]
                ),
              ),
              pw.Divider(height: 7, thickness: 5, color: PdfColors.grey700),
              pw.Expanded(
                flex: 1,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Nome: ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          //! Nome de Utilizador
                          pw.TextSpan(
                            text: recibo.funcionarioNome,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Nº ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Número de Funcionário
                          pw.TextSpan(
                            text: recibo.funcionarioNumero,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),

              pw.Expanded(
                flex: 1,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Seguro: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Seguro
                          pw.TextSpan(
                            text: recibo.funcionarioSeguro,
                            style: const  pw.TextStyle(
                              fontSize: 11,
                              
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Apólice Nº: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Apólice
                          pw.TextSpan(
                            text: recibo.funcionarioApolice,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'C. Analítico: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Centro Analítico
                          pw.TextSpan(
                            text: recibo.funcionarioCustoAnalitico,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
              pw.Divider(height: 7, thickness: 5, color: PdfColors.grey700),
              pw.Expanded(
                flex: 1,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Nº Contribuinte: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Número de Contribuinte
                          pw.TextSpan(
                            text: recibo.funcionarioContribuinte,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Vencimento Base: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Vencimento Base
                          pw.TextSpan(
                            text: recibo.funcionarioVB,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
              pw.SizedBox(height: 5),
              pw.Expanded(
                flex: 1,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Nº Benefiário: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Nº Beneficiário
                          pw.TextSpan(
                            text: recibo.funcionarioBeneficiario,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Valor Hora: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Valor Hora
                          pw.TextSpan(
                            text: recibo.funcionarioValorHora,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
              pw.SizedBox(height: 5),
              pw.Expanded(
                flex: 1,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Categoria: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //!Categoria 
                          pw.TextSpan(
                            text: recibo.funcionarioCategoria,
                            style: const pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          const pw.TextSpan(
                            text: 'Nº Dias de Trabalho: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          //! Total de dias trabalhados
                          pw.TextSpan(
                            text: recibo.funcionarioDias,
                            style: const pw.TextStyle(
                            ),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
              
              //! Ganhos e perdas de ORDENANDO
              pw.Expanded(
                flex: 22,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 2)
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 10),
                              child: pw.Align(
                                child: pw.Text(
                                  'Renumerações',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.brown800,
                                  ),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.ListView.builder(
                                itemCount: recibo.renumeracoes.length,
                                itemBuilder: (context, i){
                                  return pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                                      child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          '${recibo.renumeracoes[i].renumeracaoDescricao}:',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                        //! Fazer listagem de valores
                                        pw.Text(
                                          recibo.renumeracoes[i].ervu ?? '',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                        pw.Text(
                                          recibo.renumeracoes[i].rqtt ?? '',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                        pw.Text(
                                          recibo.renumeracoes[i].ere,
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),                       
                                      ],
                                    )
                                  );
                                }
                              )
                            )
                          ],
                        ),
                      )
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 2)
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 10),
                              child: pw.Align(
                                child: pw.Text(
                                  'Descontos',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.brown800,
                                  ),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.ListView.builder(
                                itemCount: recibo.descontos.length,
                                itemBuilder: (context, i){
                                  return pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                      child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          '${recibo.descontos[i].descontoDescricao}:',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                        //! Fazer listagem de valores
                                        pw.Text(
                                          recibo.descontos[i].edvu ?? '',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                        pw.Text(
                                          recibo.descontos[i].dqtt ?? '',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                        pw.Text(
                                          recibo.descontos[i].ede,
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),                            
                                      ],
                                    )
                                  );
                                }
                              )
                            )
                          ],
                        ),
                      )
                    ),
                  ]
                )
              ),

              pw.Expanded(
                flex: 1,
                child: pw.Row(
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Depóosito na Conta: ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          //! NIB
                          pw.TextSpan(
                            text: recibo.funcionarioNIB,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
              
              pw.Expanded(
                flex: 3,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 1.5),
                          color: PdfColors.grey400,
                        ),
                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                              children: [
                                pw.Text(
                                  'Total sujeito',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                pw.Text(
                                  recibo.valorTotalSujeito,
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ]
                            ),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                              children: [
                                pw.Text(
                                  'Total não sujeito',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                pw.Text(
                                  recibo.valorTotalNaoSujeito,
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ]
                            ),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                              children: [
                                pw.Text(
                                  'Total de Descontos',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                pw.Text(
                                  recibo.valorTotalDescontos,
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ]
                            ),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                              children: [
                                pw.Text(
                                  'Líquido a Receber',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                pw.Text(
                                  recibo.valorTotalLiquidoReceber,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ]
                            )
                          ]
                        ) 
                      ) 
                    )                      
                  ]
                )
              ),
            ]
            
          );
        }
      )
    );

    return await doc.save();
  }

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = false;
    
    /*
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
      PdfPreviewAction(
        icon: const Icon(Icons.save),
        onPressed: _saveAsFile,
      )
    ];
    */
    
    pw.RichText.debug = true;
    ReciboVenc recibo = widget.recibo;
  
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: false,
      appBar: const CustomAppBar('R. Vencimento', 25, false, 300),
      body: MediaQuery.removeViewPadding(
        context: context,
        removeTop: false,
        removeBottom: false,
        child: PdfPreview(
          maxPageWidth: 700,
          canChangePageFormat: false,
          //! Remover após finalizar esta secção
          canDebug: true,
          build: (format) => gerarDocument(format, recibo, widget.nifEmpresa),
          //actions: actions,
          onPrinted: _showPrintedToast,
          onShared: _showSharedToast,
          scrollViewDecoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.green,
                Colors.lightGreen
              ],
            )
          ),
        ),
      )
    );
  }
}