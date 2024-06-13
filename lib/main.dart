// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://iebeahzekkscuulsvwen.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllYmVhaHpla2tzY3V1bHN2d2VuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDg2MDUyNjAsImV4cCI6MjAyNDE4MTI2MH0.ANIF-1Uq1BlgUldzHfpqByQ6RrcALkHSUfIjod5gc5Y',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Note App',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _notestream = supabase.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notestream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 10),
                        blurRadius: 5,
                        color: const Color.fromARGB(255, 183, 9, 189)
                            .withOpacity(.2))
                  ],
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 211, 136, 224),
                ),
                child: ListTile(
                    onLongPress: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: const Text('Update Note'),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              children: [
                                TextFormField(
                                  onFieldSubmitted: (val) async {
                                    await supabase
                                        .from('notes')
                                        .update({'body': val}).match(
                                            {'id': notes[index]['id']});
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    },
                    title: Text(notes[index]['body']),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await supabase
                            .from('notes')
                            .delete()
                            .match({'id': notes[index]['id']});
                      },
                    )),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('Add a Note'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    TextFormField(
                      onFieldSubmitted: (val) async {
                        await supabase.from('notes').insert({'body': val});
                      },
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
