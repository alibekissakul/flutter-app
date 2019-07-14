import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

void main() async {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Debts',
      theme: ThemeData(
          primarySwatch: Colors.yellow,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Color.fromRGBO(233, 239, 251, 1)),
      initialRoute: 'current',
      routes: {
        'current': (context) => MyHomePage(title: 'My Debts'),
        'add_finance': (context) => AddFinance(),
        'edit_finance': (context) => EditFinance(context)
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FutureBuilder<List<Debt>> _debtList() {
    DebtProvider debtProvider = DebtProvider();

    return FutureBuilder<List<Debt>>(
      future: debtProvider.all(),
      builder: (BuildContext context, AsyncSnapshot<List<Debt>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Debt debt = snapshot.data[index];

                return GestureDetector(
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Dismissible(
                            confirmDismiss: (DismissDirection direction) async {
                              switch (direction) {
                                case DismissDirection.vertical:
                                  // TODO: Handle this case.
                                  break;
                                case DismissDirection.horizontal:
                                  // TODO: Handle this case.
                                  break;
                                case DismissDirection.endToStart:
                                  return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                          title: Text('Are you sure delete this record?'),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              textColor: Colors.black38,
                                              child: Text('Cancel'),
                                            ),
                                            FlatButton(
                                              onPressed: () async {
                                                await debtProvider.delete(debt.id);
                                                setState(() {});

                                                return Navigator.pop(context);
                                              },
                                              textColor: Colors.red,
                                              child: Text('Delete'),
                                            )
                                          ],
                                        );
                                      });
                                  break;
                                case DismissDirection.startToEnd:
                                  Navigator.pushNamed(context, 'edit_finance', arguments: debt);
                                  break;
                                case DismissDirection.up:
                                  // TODO: Handle this case.
                                  break;
                                case DismissDirection.down:
                                  // TODO: Handle this case.
                                  break;
                              }
                            },
                            background: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              color: Colors.blueAccent,
                              child: Container(
                                margin: EdgeInsets.all(4.0),
                                color: Colors.blueAccent,
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                    padding: EdgeInsets.all(12.0), child: Icon(Icons.edit, color: Colors.white)),
                              ),
                            ),
                            secondaryBackground: Card(
                              color: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              child: Container(
                                  margin: EdgeInsets.all(4.0),
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Padding(
                                      padding: EdgeInsets.all(12.0), child: Icon(Icons.delete, color: Colors.white))),
                            ),
                            key: Key('dismissible-card-${debt.id}'),
                            child: Card(
                                elevation: 0.0,
                                key: Key('current-list-${debt.id}'),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(left: 8.0),
                                              child: Text.rich(TextSpan(
                                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0),
                                                  text: debt.user))),
                                          Spacer(),
                                          Column(children: <Widget>[
                                            Text(
                                                FlutterMoneyFormatter(
                                                        amount: debt.amount.toDouble(),
                                                        settings: MoneyFormatterSettings(symbol: '₸', fractionDigits: 0))
                                                    .output
                                                    .symbolOnRight,
                                                style: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400)),
                                          ])
                                        ]),
                                        Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.only(left: 8.0, top: 16.0),
                                          child: Text.rich(TextSpan(
                                              text: debt.comment,
                                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400))),
                                        )
                                      ],
                                    ))))),
                    onTap: () => null);
              });
        } else {
          return Center(child: Text('Nothing to show.'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Debts'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {});
                })
          ],
        ),
        body: _debtList(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, 'add_finance');
            },
            tooltip: 'Add New Record',
            child: Icon(Icons.add)),
        // This trailing comma makes auto-formatting nicer for build methods.
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }
}

class EditFinance extends StatefulWidget {
  final BuildContext context;

  EditFinance(this.context);

  @override
  _EditFinanceState createState() {
    Debt debt = ModalRoute.of(this.context).settings.arguments;
    return _EditFinanceState(debt);
  }
}

class _EditFinanceState extends State<EditFinance> {
  Debt debt;

  _EditFinanceState(this.debt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Finance'),
        ),
        body: EditFinanceForm(debt));
  }
}

class EditFinanceForm extends StatefulWidget {
  final Debt debt;

  EditFinanceForm(this.debt);

  @override
  State<StatefulWidget> createState() => _EditFinanceForm(debt);
}

class _EditFinanceForm extends State<EditFinanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = MoneyMaskedTextController(decimalSeparator: '', thousandSeparator: ',', precision: 0);
  final _commentController = TextEditingController();
  final Debt debt;

  _EditFinanceForm(this.debt) {
    _nameController.value = TextEditingValue(text: debt.user);
    _commentController.value = TextEditingValue(text: debt.comment);
    _amountController.value = TextEditingValue(text: debt.amount.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: Colors.teal, scaffoldBackgroundColor: Color.fromRGBO(233, 239, 251, 1)),
      child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'Enter Names', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter user names';
                    }

                    return null;
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                      labelText: 'How much money?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      suffixText: '₸'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter amount';
                    }
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                        labelText: 'Comment', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                    style: TextStyle(color: Colors.black),
                    maxLines: 4),
              ),
              Container(
                margin: EdgeInsets.only(top: 24.0),
                child: FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      print(_amountController.numberValue);
                      print(_amountController.text);

                      debt.amount = _amountController.numberValue.toInt();
                      debt.user = _nameController.text;
                      debt.comment = _commentController.text;

                      DebtProvider debtProvider = DebtProvider();
                      await debtProvider.update(debt);

                      if (debt.id > 0) {
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('New record successfully added.')));
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Save'),
                  color: Colors.yellow,
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(12.0)),
              )
            ],
          )),
    );
  }
}

class AddFinance extends StatefulWidget {
  @override
  _AddFinanceState createState() => _AddFinanceState();
}

class _AddFinanceState extends State<AddFinance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Finance Information'),
        ),
        body: AddFinanceForm());
  }
}

class AddFinanceForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddFinanceForm();
}

class _AddFinanceForm extends State<AddFinanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = MoneyMaskedTextController(decimalSeparator: '', thousandSeparator: ',', precision: 0);
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: Colors.teal, scaffoldBackgroundColor: Color.fromRGBO(233, 239, 251, 1)),
      child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'Enter Names', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter user names';
                    }

                    return null;
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                      labelText: 'How much money?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      suffixText: '₸'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter amount';
                    }
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                        labelText: 'Comment', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                    style: TextStyle(color: Colors.black),
                    maxLines: 4),
              ),
              Container(
                margin: EdgeInsets.only(top: 24.0),
                child: FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      print(_amountController.numberValue.toInt());

                      Debt debt = Debt(
                          amount: _amountController.numberValue.toInt(),
                          user: _nameController.text,
                          comment: _commentController.text);

                      DebtProvider debtProvider = DebtProvider();
                      debt = await debtProvider.insert(debt);

                      if (debt.id > 0) {
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('New record successfully added.')));
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Save'),
                  color: Colors.yellow,
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(12.0)),
              )
            ],
          )),
    );
  }
}

// Models
class Debt {
  int id;
  String user;
  int amount;
  String comment;
  String createdAt;
  String updatedAt;

  Debt({this.id, @required this.amount, @required this.user, @required this.comment, this.createdAt, this.updatedAt});

  Map<String, dynamic> toMap() {
    return {'id': id, 'user': user, 'amount': amount, 'comment': comment};
  }

  static Debt fromMap(Map<String, dynamic> map) {
    Debt debt = Debt(
        id: map['id'],
        amount: int.parse(map['amount'].toString()),
        user: map['user'],
        comment: map['comment'],
        createdAt: map['created_at'],
        updatedAt: map['updated_at']);

    return debt;
  }
}

class DebtProvider {
  Database db;
  final String _tableName = 'debts.db';

  Future<void> open() async {
    db = await openDatabase(join(await getDatabasesPath(), _tableName), version: 1,
        onCreate: (Database db, int version) {
      return db.execute("CREATE TABLE debts ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "user TEXT,"
          "amount INT,"
          "comment TEXT,"
          "created_at TEXT DEFAULT CURRENT_TIMESTAMP,"
          "updated_at TEXT DEFAULT CURRENT_TIMESTAMP"
          ")");
    });
  }

  DebtProvider() {
    open();
  }

  Future<int> update(Debt debt) async {
    await open();

    return await db.update('debts', debt.toMap(), where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<Debt> insert(Debt debt) async {
    await open();
    debt.id = await db.insert('debts', debt.toMap());
    return debt;
  }

  Future<List<Debt>> all() async {
    await open();
    List<Map> results = await db.query('debts', orderBy: 'created_at DESC');

    if (results.length > 0) {
      List<Debt> debts = results.map((result) {
        return Debt.fromMap(result);
      }).toList();

      return debts;
    }

    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<Debt> findFirst(int id) async {
    List<Map> results = await db.query('debts', where: 'id = ?', whereArgs: [id]);

    if (results.length > 0) {
      return Debt.fromMap(results.first);
    }

    return null;
  }

  Future close() async {
    await db.close();
  }
}
