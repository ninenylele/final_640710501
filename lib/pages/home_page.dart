import 'dart:html';
import 'dart:convert';
import '../helpers/api_caller.dart';
import '../helpers/my_list_tile.dart';
import '../helpers/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyListTile> _listTilesItems = [];
  final TextEditingController myController = TextEditingController();
  List<String> apiOptions = [];
  String? _selectedApi;

  void initState() {
    super.initState();
    fetchMyList(); // เรียกใช้งานเมื่อหน้าจอถูกโหลด
  }

  Future<void> fetchMyList() async {
    final response = await http.get(Uri.parse(
        'https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/web_types'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<MyListTile> loadedData = [];

      data.forEach((element) {
        loadedData.add(MyListTile.fromJson(element));
      });

      setState(() {
        _listTilesItems = loadedData;
      });
    } else {
      throw Exception('Failed to load web types');
    }
  }

  Future<void> _handleReportWebsite(MyListTile item) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/report_web'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'insertItem': {
            'id': 117,
            'url': 'http://www.verybadweb.com',
            'description': '',
            'type': 'gambling',
          },
          'summary': [
            {'title': 'เว็บพนัน', 'count': 44},
            {'title': 'เว็บปลอมแปลง เลียนแบบ', 'count': 9},
            {'title': 'เว็บข่าวมั่ว', 'count': 24},
            {'title': 'เว็บแชร์ลูกโซ่', 'count': 9},
            {'title': 'อื่นๆ', 'count': 14},
          ],
        }),
      );

      if (response.statusCode == 200) {
        // ส่ง API สำเร็จ โชว์ Dialog
        showOkDialog(
          context: context,
          title: 'Success',
          message: 'รายงานเว็บเลวสำเร็จ',
        );
      } else {
        throw Exception('Failed to report website');
      }
    } catch (e) {
      showOkDialog(
        context: context,
        title: 'Error',
        message: 'An error occurred: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Webby Fondue\nระบบรายงานเว็บเลวๆ',
          textAlign: TextAlign.center, // กำหนดให้ข้อความตรงกลาง
          style: TextStyle(
              color: Color.fromARGB(255, 238, 237, 235)), // กำหนดสีของข้อความ
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // กำหนดสีพื้นหลังของ AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 229, 243, 127), // กำหนดสีพื้นหลังเป็นเทา
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                  child:
                      Text('* ต้องกรอกข้อมูล', style: textTheme.titleMedium)),
              const SizedBox(height: 8.0),

              Center(
                child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'URL *', // ปรับเป็น hintText
                    contentPadding: const EdgeInsets.only(
                      left: 16.0,
                      bottom: 12.0,
                      top: 12.0,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              const SizedBox(height: 8.0),
              Text('ระบุประเภทเว็บเลว *', style: textTheme.titleMedium),

              Expanded(
                child: ListView.builder(
                  itemCount: _listTilesItems.length,
                  itemBuilder: (context, index) {
                    final item = _listTilesItems[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedApi = item.id;
                          });
                        },
                        child: Container(
                          color: _selectedApi == item.id
                              ? Colors.grey[200]
                              : Colors.transparent,
                          child: ListTile(
                            title: Text(item.id),
                            subtitle: Text(item.subtitle),
                            leading: Image.network(
                              'https://cpsu-api-49b593d4e146.herokuapp.com${item.imageUrl}',
                              width: 80,
                              height: 80,
                            ),
                            trailing: _selectedApi == item.id
                                ? Icon(Icons.check)
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24.0),

              // ปุ่มทดสอบ POST API
              ElevatedButton(
                onPressed: () {
                  if (_selectedApi != null && myController.text.isNotEmpty) {
                    // กรณีเลือกประเภทเว็บและกรอก URL ให้ทำการส่ง API
                    MyListTile selectedTile = _listTilesItems.firstWhere(
                      (tile) => tile.id == _selectedApi!,
                      orElse: () =>
                          MyListTile(id: '', subtitle: '', imageUrl: ''),
                    );
                    _handleReportWebsite(selectedTile);
                  } else {
                    // กรณีไม่เลือกประเภทเว็บหรือไม่กรอก URL ให้แสดงข้อความแจ้งเตือน
                    showOkDialog(
                      context: context,
                      title: "Error",
                      message:
                          "โปรดเลือกประเภทเว็บและกรอก URL ก่อนที่จะส่งข้อมูล",
                    );
                  }
                },
                child: Text('ส่งข้อมูล'),
              ),

              // ปุ่มทดสอบ OK Dialog

              //ElevatedButton(
              //onPressed: _handleShowDialog,
              //child: const Text('Show OK Dialog'),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
