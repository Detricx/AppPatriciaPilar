import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Ferias{

  final PickerDateRange periodo;
  final int total;
  final int disponivel;
  final int utilizados;

  Ferias(
    this.periodo, 
    this.total, 
    this.disponivel, 
    this.utilizados
  );

  void recolherDados(){
    //Ausencia ausencia = Ausencia();
  }
}
