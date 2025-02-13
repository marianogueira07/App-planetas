import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/planeta.dart';

class ControlePlaneta {
  static Database? _bd;

  Future<Database> get bd async {
    if (_bd != null) return _bd!;
    _bd = await _initBD('planetas.db');
    return _bd!;
  }

  Future<Database> _initBD(String localArquivo) async {
    try {
      final caminhoBD = await getDatabasesPath();
      final caminho = join(caminhoBD, localArquivo);
      return await openDatabase(
        caminho,
        version: 1,
        onCreate: _criarBD,
      );
    } catch (e) {
      print('Erro ao abrir banco de dados: $e');
      rethrow; // Relança a exceção caso ocorra algum erro
    }
  }

  Future<void> _criarBD(Database bd, int versao) async {
    const sql = '''
    CREATE TABLE planetas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      tamanho REAL NOT NULL,
      distancia REAL NOT NULL,
      apelido TEXT
    );
    ''';
    await bd.execute(sql);
  }

  Future<List<Planeta>> lerPlanetas() async {
    final db = await bd;
    final resultado = await db.query('planetas');
    return resultado.map((item) => Planeta.fromMap(item)).toList();
  }

  Future<int> inserirPlaneta(Planeta planeta) async {
    final db = await bd;
    return await db.insert(
      'planetas',
      planeta.toMap(),
    );
  }

  Future<int> alterarPlaneta(Planeta planeta) async {
    final db = await bd;
    if (planeta.id == null) {
      throw Exception('ID do planeta não pode ser nulo para alteração');
    }
    return db.update(
      'planetas',
      planeta.toMap(),
      where: 'id = ?',
      whereArgs: [planeta.id],
    );
  }

  Future<int> excluirPlaneta(int id) async {
    final db = await bd;
    return await db.delete(
      'planetas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}