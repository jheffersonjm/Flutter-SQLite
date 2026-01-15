# 📦 Sistema de Cadastro de Produtos - Flutter SQLite

Um aplicativo Flutter completo para cadastro, edição, listagem e exclusão de produtos utilizando banco de dados local SQLite.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
- [Estrutura do Código](#estrutura-do-código)
- [Como Usar](#como-usar)
- [Fluxo de Funcionamento](#fluxo-de-funcionamento)
- [Capturas de Tela](#capturas-de-tela)

## 🎯 Sobre o Projeto

Este é um aplicativo mobile desenvolvido em Flutter que implementa um sistema CRUD (Create, Read, Update, Delete) completo para gerenciamento de produtos. O projeto utiliza SQLite como banco de dados local, garantindo persistência dos dados mesmo após o fechamento do aplicativo.

O sistema foi desenvolvido com foco em:
- **Simplicidade**: Interface intuitiva e fácil de usar
- **Performance**: Uso eficiente do banco de dados local
- **Validação**: Verificação de dados duplicados e campos obrigatórios
- **Responsividade**: Atualizações em tempo real da interface

## ✨ Funcionalidades

### 🔍 Listagem de Produtos
- Exibição de todos os produtos cadastrados
- Visualização de nome e código do produto
- Lista dinâmica que atualiza automaticamente

### ➕ Cadastro de Produtos
- Adicionar novos produtos
- Campos: Nome, Código e Detalhes
- Validação de campos obrigatórios
- Verificação de código único (não permite duplicados)

### ✏️ Edição de Produtos
- Editar produtos existentes
- Pré-preenchimento dos campos com dados atuais
- Manutenção do mesmo código (permitido na edição)

### 🗑️ Exclusão de Produtos
- Remover produtos do banco de dados
- Confirmação antes de excluir
- Atualização automática da lista

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento mobile multiplataforma (v3.9.0+)
- **Dart**: Linguagem de programação
- **SQLite**: Banco de dados local (via pacote `sqflite ^2.4.2`)
- **Material Design**: Biblioteca de componentes visuais do Flutter

### Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.2
```

## 🏗️ Arquitetura do Projeto

O projeto segue uma arquitetura simples e organizada:

```
lib/
├── main.dart           # Tela principal e formulário
├── database.dart       # Camada de acesso ao banco de dados
└── ...
```

### Padrões Utilizados

1. **Singleton Pattern**: A classe `DatabaseHelper` utiliza o padrão Singleton para garantir uma única instância do banco de dados
2. **StatefulWidget**: Para gerenciamento de estado das telas
3. **Async/Await**: Para operações assíncronas com o banco de dados
4. **MVC Simplificado**: Separação entre visualização (main.dart) e modelo de dados (database.dart)

## 📦 Pré-requisitos

Antes de começar, você precisa ter instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.9.0 ou superior)
- [Dart SDK](https://dart.dev/get-dart) (incluído com Flutter)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/)
- Emulador Android/iOS ou dispositivo físico

### Verificar instalação do Flutter

```bash
flutter --version
flutter doctor
```

## 🚀 Instalação

### 1. Clone ou baixe o projeto

```bash
cd caminho/do/projeto
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Execute o aplicativo

```bash
# Em um emulador/dispositivo conectado
flutter run

# Para Android
flutter run -d android

# Para iOS (apenas no macOS)
flutter run -d ios

# Para Web
flutter run -d chrome
```

## 🗄️ Estrutura do Banco de Dados

### Tabela: `produtos`

| Campo    | Tipo    | Restrições               | Descrição                  |
|----------|---------|--------------------------|----------------------------|
| id       | INTEGER | PRIMARY KEY AUTOINCREMENT| Identificador único        |
| nome     | TEXT    | -                        | Nome do produto            |
| codigo   | INTEGER | UNIQUE                   | Código único do produto    |
| detalhes | TEXT    | -                        | Descrições adicionais      |

### SQL de Criação

```sql
CREATE TABLE produtos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT,
  codigo INTEGER UNIQUE,
  detalhes TEXT
)
```

### Localização do Banco

O banco de dados é criado automaticamente no primeiro uso:
- **Android**: `/data/data/com.exemplo.app_bd/databases/produtos.db`
- **iOS**: `Library/Application Support/produtos.db`

## 📂 Estrutura do Código

### 1. database.dart

Gerencia todas as operações com o banco de dados SQLite.

#### Classe `Produto`
```dart
class Produto {
  int? id;
  String nome;
  int codigo;
  String detalhes;
}
```

Representa um produto com seus atributos e métodos para conversão em Map.

#### Classe `DatabaseHelper`

**Padrão Singleton** para gerenciar uma única instância do banco.

##### Principais Métodos:

| Método | Descrição | Retorno |
|--------|-----------|---------|
| `db` | Getter que retorna ou inicializa o banco | `Future<Database>` |
| `_initDb()` | Inicializa o banco de dados | `Future<Database>` |
| `_onCreate()` | Cria a tabela produtos | `Future<void>` |
| `getProdutos()` | Busca todos os produtos | `Future<List<Produto>>` |
| `insertProduto()` | Insere novo produto | `Future<int>` |
| `updateProduto()` | Atualiza produto existente | `Future<int>` |
| `deleteProduto()` | Remove produto por ID | `Future<int>` |
| `codigoExiste()` | Verifica se código já existe | `Future<bool>` |

### 2. main.dart

Contém as telas e a lógica de interface do aplicativo.

#### Classe `ProdutoListScreen`

**Tela principal** que exibe a lista de produtos.

##### Principais Métodos:

| Método | Descrição |
|--------|-----------|
| `initState()` | Carrega produtos ao iniciar |
| `_carregarProdutos()` | Busca produtos no banco e atualiza UI |
| `_confirmarExclusao()` | Exibe diálogo de confirmação |
| `_abrirFormulario()` | Abre tela de cadastro/edição |

##### Elementos da Interface:
- **AppBar**: Título com gradiente (vermelho → amarelo)
- **ListView.builder**: Lista dinâmica de produtos
- **FloatingActionButton**: Botão para adicionar novo produto

#### Classe `ProdutoFormScreen`

**Tela de formulário** para cadastro e edição de produtos.

##### Principais Métodos:

| Método | Descrição |
|--------|-----------|
| `initState()` | Inicializa campos com dados do produto |
| `_salvar()` | Valida e salva produto no banco |
| `_cancelar()` | Fecha formulário sem salvar |

##### Validações Implementadas:
- ✅ Nome obrigatório
- ✅ Código obrigatório
- ✅ Código único (não duplicado)
- ✅ Permite mesmo código na edição do próprio produto

## 🎮 Como Usar

### Adicionar um Produto

1. Na tela principal, clique no botão flutuante **+** (canto inferior direito)
2. Preencha os campos:
   - **Nome**: Nome do produto (obrigatório)
   - **Código**: Código numérico único (obrigatório)
   - **Detalhes**: Informações adicionais (opcional)
3. Clique em **Salvar**
4. O produto será adicionado à lista

### Editar um Produto

1. Na lista, toque sobre o produto que deseja editar
2. Os campos serão preenchidos com os dados atuais
3. Modifique as informações desejadas
4. Clique em **Salvar**

### Excluir um Produto

1. Na lista, clique no ícone de **lixeira** (vermelho) ao lado do produto
2. Confirme a exclusão clicando em **Sim** no diálogo
3. O produto será removido do banco de dados

### Cancelar Operação

- No formulário, clique em **Cancelar** para voltar sem salvar

## 🔄 Fluxo de Funcionamento

### Fluxo de Inicialização

```
main() → MaterialApp → ProdutoListScreen
                               ↓
                         initState()
                               ↓
                    _carregarProdutos()
                               ↓
                    dbHelper.getProdutos()
                               ↓
                      setState(produtos)
                               ↓
                      ListView.builder()
```

### Fluxo de Cadastro

```
Botão + pressionado
         ↓
_abrirFormulario()
         ↓
ProdutoFormScreen(produto: null)
         ↓
Usuário preenche dados
         ↓
Clica em Salvar
         ↓
_salvar() valida formulário
         ↓
Verifica código duplicado
         ↓
dbHelper.insertProduto()
         ↓
Navigator.pop(true)
         ↓
_carregarProdutos()
```

### Fluxo de Edição

```
Toca no produto
         ↓
_abrirFormulario(produto: produtoSelecionado)
         ↓
ProdutoFormScreen(produto: existente)
         ↓
Campos pré-preenchidos
         ↓
Usuário modifica dados
         ↓
Clica em Salvar
         ↓
dbHelper.updateProduto()
         ↓
Lista atualizada
```

### Fluxo de Exclusão

```
Clica no ícone lixeira
         ↓
_confirmarExclusao(id)
         ↓
AlertDialog exibido
         ↓
Usuário confirma (Sim)
         ↓
dbHelper.deleteProduto(id)
         ↓
Navigator.pop()
         ↓
_carregarProdutos()
```

## 🎨 Capturas de Tela

### Tela Principal
- Lista de produtos com nome e código
- AppBar com gradiente vermelho/amarelo
- Botão flutuante para adicionar

### Formulário
- Campos de texto para Nome, Código e Detalhes
- Botões Salvar e Cancelar
- Validações em tempo real

### Diálogo de Confirmação
- Mensagem de confirmação
- Botões Sim e Não

## 📝 Observações Técnicas

### Gerenciamento de Estado

O aplicativo utiliza `StatefulWidget` e `setState()` para atualizar a interface quando:
- Produtos são carregados do banco
- Novos produtos são adicionados
- Produtos existentes são editados
- Produtos são removidos

### Operações Assíncronas

Todas as operações com o banco de dados são **assíncronas** (`async/await`):
- Evita bloqueio da interface
- Melhora a experiência do usuário
- Permite operações em background

### Validações

#### Validação de Código Único
```dart
final codigoExistente = await dbHelper.codigoExiste(novoProduto.codigo);
final codigoIgualDoMesmoProduto = 
    widget.produto != null && 
    widget.produto!.codigo == novoProduto.codigo;

if (codigoExistente && !codigoIgualDoMesmoProduto) {
  // Mostra erro
}
```

Garante que:
- Não existam códigos duplicados
- O mesmo código pode ser mantido ao editar
- Feedback imediato ao usuário

## 🔧 Possíveis Melhorias Futuras

- [ ] Adicionar busca/filtro de produtos
- [ ] Implementar ordenação (por nome, código)
- [ ] Adicionar categorias de produtos
- [ ] Incluir foto do produto
- [ ] Exportar/importar dados (CSV, JSON)
- [ ] Implementar temas claro/escuro
- [ ] Adicionar estatísticas e relatórios
- [ ] Implementar backup na nuvem
- [ ] Adicionar leitor de código de barras
- [ ] Implementar autenticação de usuário

## 🐛 Solução de Problemas

### Erro ao instalar dependências
```bash
flutter clean
flutter pub get
```

### Banco de dados corrompido
```bash
# No Android
adb shell
run-as com.exemplo.app_bd
rm -rf databases/
```

### App não compila
```bash
flutter doctor
flutter upgrade
```

## 📄 Licença

Este projeto é de código aberto e está disponível para uso educacional.

## 👥 Autor

Desenvolvido como projeto educacional para demonstrar:
- Uso de SQLite no Flutter
- Implementação de CRUD completo
- Boas práticas de desenvolvimento Flutter
- Padrões de projeto (Singleton)
- Validação de dados

---

**Versão**: 1.0.0  
**Data**: Janeiro 2026  
**Flutter**: 3.9.0+  
**Dart**: 3.9.0+