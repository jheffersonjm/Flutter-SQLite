// Importa o pacote de componentes visuais do Flutter
import 'package:flutter/material.dart';

// Importa o arquivo onde está a classe de acesso ao banco de dados local
import 'database.dart';

// Função principal do aplicativo, ponto de entrada do Flutter
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner:
          false, // Remove o banner de debug do canto superior direito
      home:
          ProdutoListScreen(), // Define a primeira tela que será exibida ao abrir o app
    ),
  );
}

// Criação da tela principal do aplicativo, com estado dinâmico
class ProdutoListScreen extends StatefulWidget {
  @override
  _ProdutoListScreenState createState() => _ProdutoListScreenState();
}

// Classe de estado da tela principal (onde ficam os dados e métodos que mudam com o tempo)
class _ProdutoListScreenState extends State<ProdutoListScreen> {
  final dbHelper = DatabaseHelper(); // Instância do helper de banco de dados
  List<Produto> produtos = []; // Lista que irá armazenar os produtos carregados

  // Método que é executado assim que o widget é criado
  @override
  void initState() {
    super.initState();
    _carregarProdutos(); // Carrega os produtos do banco de dados
  }

  // Método assíncrono para buscar os produtos no banco e atualizar a interface
  Future<void> _carregarProdutos() async {
    final lista = await dbHelper.getProdutos(); // Busca produtos
    setState(() {
      produtos = lista; // Atualiza a lista de produtos no estado
    });
  }

  // Método que mostra um alerta de confirmação antes de excluir um produto
  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('Deseja realmente excluir este produto?'),
        actions: [
          // Botão "Não" apenas fecha o diálogo
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Não'),
          ),
          // Botão "Sim" exclui o produto do banco e atualiza a lista
          TextButton(
            onPressed: () async {
              await dbHelper.deleteProduto(id); // Exclui do banco
              Navigator.pop(context); // Fecha o diálogo
              _carregarProdutos(); // Atualiza a lista
            },
            child: Text('Sim'),
          ),
        ],
      ),
    );
  }

  // Abre a tela de formulário para adicionar ou editar um produto
  void _abrirFormulario({Produto? produto}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProdutoFormScreen(produto: produto), // Envia o produto (ou null)
      ),
    );
    if (resultado == true) {
      _carregarProdutos(); // Atualiza a lista se algo foi salvo
    }
  }

  // Método que constrói a interface da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de produto'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.yellow], // Gradiente no AppBar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: produtos.length, // Quantidade de itens
        itemBuilder: (context, index) {
          final produto = produtos[index]; // Produto atual
          return ListTile(
            title: Text(
              produto.nome,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Código: ${produto.codigo}',
              style: TextStyle(fontSize: 13),
            ), //////////////////////////////paramo aqui
            onTap: () => _abrirFormulario(produto: produto), // Editar produto
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarExclusao(produto.id!), // Excluir
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(), // Adicionar novo produto
        child: Icon(Icons.add),
      ),
    );
  }
}

// Tela do formulário de cadastro/edição de produto
class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto; // Produto opcional (null para novo produto)

  ProdutoFormScreen({this.produto});

  @override
  _ProdutoFormScreenState createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave do formulário para validação
  final dbHelper = DatabaseHelper(); // Instância do helper de banco

  // Variáveis para armazenar os dados digitados
  late String nome;
  late int codigo;
  late String detalhes;

  // Controladores dos campos de texto
  late TextEditingController nomeCtrl;
  late TextEditingController codigoCtrl;
  late TextEditingController detalhesCtrl;

  @override
  void initState() {
    super.initState();
    // Inicializa os campos com os dados do produto (ou vazio se for novo)
    nomeCtrl = TextEditingController(text: widget.produto?.nome ?? '');
    codigoCtrl = TextEditingController(
      text: widget.produto?.codigo.toString() ?? '',
    );
    detalhesCtrl = TextEditingController(text: widget.produto?.detalhes ?? '');
  }

  // Método chamado ao clicar em "Salvar"
  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      // Cria objeto Produto com os dados do formulário
      final novoProduto = Produto(
        id: widget.produto?.id,
        nome: nomeCtrl.text,
        codigo: int.parse(codigoCtrl.text),
        detalhes: detalhesCtrl.text,
      );

      // Verifica se o código já existe no banco
      final codigoExistente = await dbHelper.codigoExiste(novoProduto.codigo);

      // Se for o mesmo código do produto sendo editado, está tudo certo
      final codigoIgualDoMesmoProduto =
          widget.produto != null &&
          widget.produto!.codigo == novoProduto.codigo;

      // Se já existe e é de outro produto, mostra erro
      if (codigoExistente && !codigoIgualDoMesmoProduto) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Código já existente!')));
        return;
        //////////////////////////////////////////////////// tamo aqui
      }

      // Insere ou atualiza no banco, dependendo se é novo ou edição
      if (widget.produto == null) {
        await dbHelper.insertProduto(novoProduto);
      } else {
        await dbHelper.updateProduto(novoProduto);
      }

      Navigator.pop(context, true); // Fecha o formulário com sucesso
    }
  }

  // Cancela a operação e volta sem salvar
  void _cancelar() {
    Navigator.pop(context, false);
  }

  // Monta a tela do formulário
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Chave de validação
          child: Column(
            children: [
              // Campo Nome
              TextFormField(
                controller: nomeCtrl,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              // Campo Código
              TextFormField(
                controller: codigoCtrl,
                decoration: InputDecoration(labelText: 'Código'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Informe o código' : null,
              ),
              // Campo Detalhes
              TextFormField(
                controller: detalhesCtrl,
                decoration: InputDecoration(labelText: 'Detalhes'),
              ),
              SizedBox(height: 20),
              // Botões Salvar e Cancelar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(onPressed: _salvar, child: Text('Salvar')),
                  ElevatedButton(
                    onPressed: _cancelar,
                    child: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
