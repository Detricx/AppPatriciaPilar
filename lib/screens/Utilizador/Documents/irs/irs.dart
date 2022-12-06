import 'package:drh_project/models/recibo_irs.dart';
import 'package:drh_project/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IrsScreen extends StatefulWidget {
  //Vou buscar o valor do NIF
  final DeclaracaoIRS recibo;
  final String nifEmpresa;
  const IrsScreen({Key? key, required this.recibo, required this.nifEmpresa}) : super(key: key);

  @override
  State<IrsScreen> createState() => _IrsScreenState();
}

class _IrsScreenState extends State<IrsScreen> {
  
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

  Future<Uint8List> gerarDocument(PdfPageFormat format, DeclaracaoIRS recibo, String empresa) async{
    final doc = pw.Document(pageMode: PdfPageMode.outlines);
    
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();
    
    //!Aplicar uma condição aqui !!!
    final ByteData bytes = await rootBundle.load('assets/icons/logos/$empresa.jpg');
    bytes.buffer.asUint8List();

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
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding:  const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        border: pw.Border.all(color: PdfColors.black)
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            "DECLARAÇÃO DE RENDIMENTOS E DEDUÇÕES DE I.R.S EM EUROS",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            "ANO DE ${recibo.ano}",
                            textAlign: pw.TextAlign.center
                          )
                        ]
                      )
                    )
                  )
                ]
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding:  const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black)
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "DADOS DA EMPRESA",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(62, 5, 60, 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Nome:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded( 
                            child: pw.Padding(
                              padding:  const pw.EdgeInsets.symmetric(horizontal: 5),
                              child: pw.Text(
                                recibo.empresaNome,
                              ),
                            )
                          )
                        ]
                      )
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 60, bottom: 5, left: 53),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Morada:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Padding(
                              padding:  const pw.EdgeInsets.symmetric(horizontal: 5),
                              child: pw.Text(
                                recibo.empresaMorada,
                              ),
                            )
                          ),
                          pw.Text(
                            "Nº Esta - Esta",
                          ),
                        ]
                      )
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 151, bottom: 5, left: 20),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Código Postal:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Padding(
                              padding:  const pw.EdgeInsets.symmetric(horizontal: 5),
                              child: pw.Text(
                                recibo.empresaCodPostal,
                              ),
                            )
                          ),
                        ]
                      )
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 151, bottom: 5, left: 10),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Nº Contribuinte:",
                          ),
                          pw.SizedBox(width: 9),
                          pw.Expanded(
                            child: pw.Text(
                              recibo.empresaContribuinte,
                            ),
                          ),
                        ]
                      )
                    ),
                  ],
                )
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding:  const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black)
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "DADOS DO FUNCIONÁRIO",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(62, 5, 60, 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Nome:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Text(
                              recibo.funcionarioNome,
                            ),
                          ),
                          
                        ]
                      )
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 60, bottom: 5, left: 53),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Morada:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Text(
                              recibo.funcionarioMorada,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 60, bottom: 5, left: 20),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Código Postal:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Text(
                              recibo.funcionariocodPostal,
                            ),
                          ),
                        ]
                      )
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 60, bottom: 5, left: 10),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Nº Contribuinte:",
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Text(
                              recibo.funcionarioContribuinte,
                            ),
                          ),
                        ]
                      )
                    ),
                  ],
                )
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding:  const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black)
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Text('De acordo com o artigo 119 do C.I.R.S., declara-se que foram auferidos pelo funcionário acima referido, no ano de ${recibo.ano}, rendimentos de trabalho dependente nos seguintes valores, sobre os quais foram efetuados os descontos abaixo indicados:'),
                )
                
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding:  const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black)
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "RENDIMENTOS SUJEITOS A I.R.S",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Rendimento do Ano",
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.rendimentoAno} €",
                                  ),
                                ]
                              ),
                            ]
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Rendimentos dos Anos anteriores incluídos em 2021",
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.rendimentoAnosAnteriores} €",
                                  ),
                                ]
                              ),
                            ]
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "VALOR TOTAL DOS RENDIMENTOS SUJEITOS A I.R.S",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.totalRendimentos} €",
                                  ),
                                ]
                              ),
                            ]
                          )
                        ]
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      "DESCONTOS EFETUADOS",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Imposto s/ rendimento",
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.impostoRendimento} €",
                                  ),
                                ]
                              ),
                            ]
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Sobretaxa I.R.S (Lei nº 66-B/2012 de 31 de dezembro)",
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.sobretaxaIRS} €",
                                  ),
                                ]
                              ),
                            ]
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Segurança Social",
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.segurancaSocial} €",
                                  ),
                                ]
                              ),
                            ]
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "TOTAL I.R.S E SEGURANÇA SOCIAL",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.totalDescontos} €",
                                  ),
                                ]
                              ),
                            ]
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Quotizações Sindicais",
                              ),
                              pw.SizedBox(width: 5),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "${recibo.quotizacaoSindicais} €",
                                  ),
                                ]
                              ),
                            ]
                          )
                        ]
                      ),
                    ),
                  ]
                )
              )
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
    DeclaracaoIRS recibo = widget.recibo;
  
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: false,
      
      appBar: const CustomAppBar('R. IRS', 25, false, 300),
      body: MediaQuery.removeViewPadding(
        context: context,
        removeTop: false,
        removeBottom: false,
        child: PdfPreview(
          maxPageWidth: 700,
          canChangePageFormat: false,
          //! Remover após finalizar esta secção
          canDebug: false,
          build: (format) => gerarDocument(format, recibo,widget.nifEmpresa),
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