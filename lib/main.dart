import 'dart:ffi';

import 'package:flutter/material.dart';
import "package:dio/dio.dart";
import 'dart:io';
import "package:path_provider/path_provider.dart";
import 'package:palestine_console/palestine_console.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProgressBarScreen(),
    );
  }
}

class ProgressBarScreen extends StatefulWidget {
  const ProgressBarScreen({
    super.key,
  });
  @override
  State<ProgressBarScreen> createState() => _ProgressBarScreenState();
}

class _ProgressBarScreenState extends State<ProgressBarScreen> {
  final imgUrl =
      "https://images.pexels.com/photos/240040/pexels-photo-240040.jpeg?auto=compress";
  bool isDownloading = false;
  var progressStatus = "";
  String file = "";

  TextEditingController? _textEditingController;

  Future<void> downloadFile(imgUrl) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();

      await dio.download(
        imgUrl,
        "${dir.path}/myImage.jpg",
        onReceiveProgress: (current, total) {
          Print.white('Rec: $current , Total: $total');
          file = "${dir.path}/myImage.jpg";
          setState(() {
            isDownloading = true;
            progressStatus = ((current / total) * 100).toStringAsFixed(0) + "%";
          });
        },
      );
    } catch (e) {
      Print.red("$e");
    }

    setState(() {
      isDownloading = false;
      progressStatus = "Completed";
    });

    Print.white('Download completed');
  }

  Future<Widget> downloadWidget(String filePath) async {
    File file = File(filePath);
    bool isExist = await file.exists();
    //* 캐시 초기화
    //* 플러터는 빠른 이미지 처리를 위해 캐시에 같은 이름의 이미지가 있으면 이미지를 변경하지 않고 기존 이미지를 사용하는데,
    //* evict()를 사용하면 같은 이름이어도 이미지를 갱신합니다
    new FileImage(file).evict();

    if (isExist) {
      return Center(
        child: Column(
          children: [Image.file(File(filePath))],
        ),
      );
    } else {
      return Text("No Data");
    }
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = new TextEditingController(
        text:
            "https://images.pexels.com/photos/240040/pexels-photo-240040.jpeg?auto=compress");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textEditingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: "url 입력하십쇼"),
        ),
      ),
      body: Center(
        child: isDownloading
            ? Container(
                width: 200,
                height: 120,
                child: Card(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        "Downloading File: $progressStatus",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              )
            : FutureBuilder(
                future: downloadWidget(file!),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      Print.red("none");
                      return Text("데이터 없음");
                    case ConnectionState.waiting:
                      Print.green("waiting");
                      return CircularProgressIndicator();
                    case ConnectionState.active:
                      Print.green('active');
                      return CircularProgressIndicator();
                    case ConnectionState.done:
                      Print.green('done');
                      if (snapshot.hasData) {
                        return snapshot.data as Widget;
                      }
                      return Text('데이터 없음');
                  }
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          downloadFile(imgUrl);
        },
        child: Icon(Icons.file_download),
      ),
    );
  }
}
