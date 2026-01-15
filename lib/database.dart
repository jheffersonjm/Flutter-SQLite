// Importa o pacote sqflite, responsável por manipular bancos de dados SQLite no Flutter
import 'package:sqflite/sqflite.dart';
// Importa o pacote path, utilizado para construir o caminho correto para armazenar o banco de dados
import 'package:path/path.dart';

// Classe que representa um produto no sistema
class Produto {
  // Atributos do produto: id pode ser nulo, os demais são obrigatórios
  int? id;
  String nome;
  int codigo;
  String detalhes;

  // Construtor da classe Produto com parâmetros nomeados
  Produto({this.id, required this.nome, required this.codigo, required this.detalhes});

  // Método que converte o objeto Produto em um Map, necessário para inserir no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'codigo': codigo,
      'detalhes': detalhes,
    };
  }
}

// Classe responsável por gerenciar o banco de dados
class DatabaseHelper {
  // Instância única da classe (padrão Singleton)
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  // Construtor fábrica que sempre retorna a mesma instância
  factory DatabaseHelper() => _instance;
  // Construtor interno privado
  DatabaseHelper._internal();

  // Atributo privado que armazenará a instância do banco de dados
  Database? _db;

  // Getter que retorna a instância do banco, inicializando se necessário
  Future<Database> get db async {
    // Se o banco já foi inicializado, retorna ele
    if (_db != null) return _db!;
    // Caso contrário, inicializa o banco
    _db = await _initDb();
    return _db!;
  }

  // Método privado que inicializa o banco de dados
  Future<Database> _initDb() async {
    // Define o caminho onde o banco será salvo, com o nome 'produtos.db'
    final path = join(await getDatabasesPath(), 'produtos.db');
    // Abre o banco de dados (ou cria, se não existir), e define o método _onCreate para ser executado na criação
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Método executado apenas na criação do banco. Cria a tabela 'produtos'
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        codigo INTEGER UNIQUE,
        detalhes TEXT
      )
    ''');
  }

  // Retorna uma lista com todos os produtos armazenados no banco
  Future<List<Produto>> getProdutos() async {
    final dbClient = await db; // Obtém a instância do banco
    // Realiza a consulta na tabela produtos
    final List<Map<String, dynamic>> maps = await dbClient.query('produtos');
    // Converte cada item do Map para um objeto Produto
    return List.generate(maps.length, (i) {
      return Produto(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        codigo: maps[i]['codigo'],
        detalhes: maps[i]['detalhes'],
      );
    });
  }

  // Insere um novo produto no banco de dados
  Future<int> insertProduto(Produto produto) async {
    final dbClient = await db; // Obtém o banco
    // Insere o produto convertendo para Map
    return await dbClient.insert('produtos', produto.toMap());
  }

  // Atualiza um produto já existente, com base no id
  Future<int> updateProduto(Produto produto) async {
    final dbClient = await db;
    return await dbClient.update(
      'produtos', // Nome da tabela
      produto.toMap(), // Novos dados
      where: 'id = ?', // Condição para atualização (id)
      whereArgs: [produto.id], // Argumento passado para substituir o '?'
    );
  }

  // Deleta um produto com base no id
  Future<int> deleteProduto(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'produtos', // Nome da tabela
      where: 'id = ?', // Condição de exclusão
      whereArgs: [id], // Valor do id a ser excluído
    );
  }

  // Verifica se já existe um produto com determinado código no banco
  Future<bool> codigoExiste(int codigo) async {
    final dbClient = await db;
    // Realiza uma consulta filtrando pelo código
    final result = await dbClient.query(
      'produtos',
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
    // Retorna true se encontrar algum resultado, ou false se não encontrar
    return result.isNotEmpty;
  }
}
