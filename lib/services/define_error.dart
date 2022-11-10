List<String> defineErros(int type, int msg){
  late List<String> erro;

  switch(type){
    case 1:
      erro = ['Erro de ligação','Comunicação interrompida, comunique com o setor informático'];
    break;

    case 3:
      erro = ['Ausência de parâmetros','Houve falta de dados para o pedido, comunique com o setor informático'];
    break;

    case 5:
      erro = ['Requisição errada','Para proceder ao processo deve apresentar a requisição correta, comunique com o setor informático'];
    break;

    case 7:
      erro = ['Sucesso','Ação executada'];
    break;

    case 9:
      erro = ['Ficheiro Inválido','Apenas é aceite ficheiros como. jpg e png'];
    break;

    case 11:
      erro = ['Caminho incorreto','Verifique se o ficheiro que quer usar está na pasta origem que o tirou'];
    break;

    case 13:
      if(msg == 14){
        erro = ['Processo encerrado','Algo correu mal na exportação do ficheiro, comunique com o setor infomático'];
      }
      else{
        erro = ['Processo encerrado','Algo correu mal a eliminar o ficheiro, comunique com o setor informático'];
      }
    break;

    case 16:
      erro = ['Autenticação inválida','Necessita validar a sua conta para acessar a estes dados'];
    break;

    case 18:
      if(msg == 19){
        erro = ['Processo encerrado','A requesição feita não retornou dados'];
      }
      else{
        erro = ['Processo encerrado','Contribuinte não está registado na empresa, comunique com os recursos humanos'];
      }
    break;

    case 21:
      erro = ['Identidade bloqueada','Ao que os nossos dados mostram, perdeu o acesso a este serviço'];
    break;

    default:
      erro = ['Erro inesperado','Por favor informe os serviços técnicos deste problema'];
    break;
  }
  return erro;
}