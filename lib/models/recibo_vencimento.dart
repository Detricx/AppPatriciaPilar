//Crio uma classe para receber os parâmetros dos Recivos de Vencimento
import 'package:drh_project/models/rv_desconto.dart';
import 'package:drh_project/models/rv_renumeracao.dart';

class ReciboVenc{

  //EMPRESA
  final String empresaNome;
  final String empresaMorada;
  final String empresaCodPostal;
  final String empresaLocalizacao;
  final String empresaContribuinte;

  //FUNCIONÁRIO
  final String funcionarioNome;
  final String funcionarioSeguro;
  final String funcionarioApolice;
  final String funcionarioNumero;
  final String funcionarioCustoAnalitico;
  final String funcionarioContribuinte;
  final String funcionarioBeneficiario;
  final String funcionarioCategoria;
  final String funcionarioVB;
  final String funcionarioValorHora;
  final String funcionarioDias;
  final String funcionarioNIB;

  //VALORES_TOTAIS
  final String valorTotalSujeito;
  final String valorTotalNaoSujeito;
  final String valorTotalDescontos;
  final String valorTotalLiquidoReceber;

  //RENUMERAÇÕES
  List<Renumeracao> renumeracoes;

  //DESCONTOS
  List<Desconto> descontos;

  //Data
  final String data;
  final String nRecibo;

  ReciboVenc(
    this.empresaNome, 
    this.empresaMorada, 
    this.empresaCodPostal,
    this.empresaLocalizacao, 
    this.empresaContribuinte, 
    this.funcionarioNome, 
    this.funcionarioSeguro, 
    this.funcionarioApolice, 
    this.funcionarioNumero, 
    this.funcionarioCustoAnalitico, 
    this.funcionarioContribuinte, 
    this.funcionarioBeneficiario, 
    this.funcionarioCategoria, 
    this.funcionarioVB, 
    this.funcionarioValorHora, 
    this.funcionarioDias, 
    this.funcionarioNIB, 
    this.valorTotalSujeito, 
    this.valorTotalNaoSujeito, 
    this.valorTotalDescontos, 
    this.valorTotalLiquidoReceber, 
    this.renumeracoes,
    this.descontos,
    this.data, 
    this.nRecibo
  );
}
