import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Ausencia{

  final PickerDateRange periodo;
  final String categoria;
  final String desconto;
  final String? motivo;
  final int id;
  final List<dynamic>? documentos;
  final int nivel;

  Ausencia(
    this.periodo,
    this.categoria,
    this.desconto,
    this.motivo,
    this.id,
    this.documentos,
    {
      this.nivel = 0
    }
    
  );
}
