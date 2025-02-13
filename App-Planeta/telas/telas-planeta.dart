import 'package:flutter/material.dart';
import '../controles/controle_planeta.dart';
import '../modelos/planeta.dart';

class TelaPlaneta extends StatefulWidget {
  final bool isIncluir;
  final Planeta planeta;
  final Function() onFinalizado;

  const TelaPlaneta({
    super.key,
    required this.isIncluir,
    required this.planeta,
    required this.onFinalizado,
  });

  @override
  State<TelaPlaneta> createState() => _TelaPlanetaState();
}

class _TelaPlanetaState extends State<TelaPlaneta> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _tamanhoController = TextEditingController();
  final TextEditingController _distanciaController = TextEditingController();
  final TextEditingController _apelidoController = TextEditingController();

  final ControlePlaneta _controlePlaneta = ControlePlaneta();

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.planeta.nome;
    _tamanhoController.text = widget.planeta.tamanho.toString();
    _distanciaController.text = widget.planeta.distancia.toString();
    _apelidoController.text = widget.planeta.apelido ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tamanhoController.dispose();
    _distanciaController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Criando um novo objeto para garantir que os dados sejam atualizados corretamente
    final novoPlaneta = Planeta(
      id: widget.isIncluir ? null : widget.planeta.id,
      nome: _nomeController.text,
      tamanho: double.parse(_tamanhoController.text),
      distancia: double.parse(_distanciaController.text),
      apelido: _apelidoController.text.isNotEmpty ? _apelidoController.text : null,
    );

    if (widget.isIncluir) {
      await _controlePlaneta.inserirPlaneta(novoPlaneta);
    } else {
      await _controlePlaneta.alterarPlaneta(novoPlaneta);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dados do planeta foram ${widget.isIncluir ? 'incluídos' : 'alterados'} com sucesso!'),
      ),
    );

    Navigator.of(context).pop();
    widget.onFinalizado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cadastrar Planeta'),
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value == null || value.isEmpty || value.length < 3)
                      ? 'Por favor, informe o nome do planeta (3 ou mais caracteres)'
                      : null,
                ),
                TextFormField(
                  controller: _tamanhoController,
                  decoration: const InputDecoration(labelText: 'Tamanho (em km)'),
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null)
                      ? 'Insira um valor numérico válido'
                      : null,
                ),
                TextFormField(
                  controller: _distanciaController,
                  decoration: const InputDecoration(labelText: 'Distância (em km)'),
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null)
                      ? 'Insira um valor numérico válido'
                      : null,
                ),
                TextFormField(
                  controller: _apelidoController,
                  decoration: const InputDecoration(labelText: 'Apelido'),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}