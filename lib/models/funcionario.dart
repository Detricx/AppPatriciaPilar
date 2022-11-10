import 'package:drh_project/models/ausencia.dart';
import 'package:drh_project/models/ferias.dart';

class Funcionario{

  String nif;
  String nome;
  List<Ausencia>? periodoAusencias;
  List<Ferias>? periodoFerias;
  
  Funcionario(
    this.nif,
    this.nome, 
    {
      this.periodoAusencias,
      this.periodoFerias,
    }
  );
}
