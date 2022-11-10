class DeclaracaoIRS{

  //EMPRESA
  final String empresaNome;
  final String empresaMorada;
  final String empresaCodPostal;
  final String empresaContribuinte;

  //FUNCIONÁRIO
  final String funcionarioNome;
  final String funcionarioMorada;
  final String funcionariocodPostal;
  final String funcionarioContribuinte;
  final String funcionarioNumero;

  //DOCUMENTO
  final String ano;
  final String rendimentoAno;
  final String rendimentoAnosAnteriores;
  final String totalRendimentos;
  final String impostoRendimento;
  final String sobretaxaIRS;
  final String segurancaSocial;
  final String totalDescontos;
  final String quotizacaoSindicais;

  DeclaracaoIRS(
    this.empresaNome, 
    this.empresaMorada, 
    this.empresaCodPostal, 
    this.empresaContribuinte, 
    this.funcionarioNome, 
    this.funcionarioMorada, 
    this.funcionariocodPostal, 
    this.funcionarioContribuinte, 
    this.funcionarioNumero, 
    this.ano, 
    this.rendimentoAno, 
    this.rendimentoAnosAnteriores, 
    this.totalRendimentos, 
    this.impostoRendimento, 
    this.sobretaxaIRS, 
    this.segurancaSocial, 
    this.totalDescontos, 
    this.quotizacaoSindicais
  );
}
