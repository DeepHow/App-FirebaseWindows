import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_windows/firebase_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../debug_widget.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key, required this.app});

  final FirebaseApp app;

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final TextEditingController _debugTextEditingController =
      TextEditingController();
  final TextEditingController _textEditingController1 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final FocusNode _focusNode1 = FocusNode();

  late final FirebaseStorage _storage;

  String? mimeType;
  UploadTask? uploadTask;

  bool get canUpload =>
      _textEditingController1.text.isNotEmpty &&
      _textEditingController2.text.isNotEmpty;

  void selectFile() {
    _focusNode1.requestFocus();
  }

  void putFile() {
    File file = File(_textEditingController1.text);
    Reference reference = _storage.ref(_textEditingController2.text);
    SettableMetadata metadata = SettableMetadata(contentType: mimeType);
    log('bucket: ${reference.bucket}, fullPath: ${reference.fullPath}');
    try {
      int progress = 0;
      uploadTask = reference.putFile(file, metadata);
      uploadTask?.snapshotEvents.listen(
        (TaskSnapshot taskSnapshot) async {
          switch (taskSnapshot.state) {
            case TaskState.running:
              int newProgress = (100 *
                      taskSnapshot.bytesTransferred /
                      taskSnapshot.totalBytes)
                  .round();
              if (progress != newProgress) {
                progress = newProgress;
                log('putFile running, progress: $progress% (${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes} bytes sent)');
              }
              break;
            case TaskState.success:
              setState(() {
                uploadTask = null;
              });
              var url = await reference.getDownloadURL();
              var gs = "gs://${reference.bucket}/${reference.fullPath}";
              log('putFile success, download url: $url, gs: $gs');
              break;
            default:
          }
        },
        onError: (error) {
          setState(() {
            uploadTask = null;
          });
          log('[Error] putFile error: $error');
        },
      );
      setState(() {});
    } on FirebaseException catch (e) {
      log('[Error] e.code: ${e.code}, e.message: ${e.message}, $e');
    }
  }

  void cancelTask() {
    uploadTask?.cancel().then((value) => log('cancelTask isSuccess: $value'));
  }

  void onFocusChange() {
    if (_focusNode1.hasFocus) {
      FilePicker.platform
          .pickFiles(lockParentWindow: true)
          .then((result) => setState(() {
                PlatformFile? platformFile = result?.files.single;
                _textEditingController1.text = platformFile?.path ?? '';
                _textEditingController2.text = platformFile?.name ?? '';
                mimeType = platformFile != null
                    ? lookupMimeType(platformFile.name)
                    : null;
                log('MIME type is "$mimeType"');
              }));
    }
  }

  void log(String msg) {
    if (kDebugMode) print(msg);
    _debugTextEditingController.text += '$msg\n';
  }

  @override
  void initState() {
    super.initState();
    _storage = FirebaseStorage.instanceFor(app: widget.app);
    _focusNode1.addListener(onFocusChange);
  }

  @override
  void dispose() {
    _focusNode1.removeListener(onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage example page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              width: 600,
              child: TextField(
                readOnly: true,
                focusNode: _focusNode1,
                controller: _textEditingController1,
                decoration: const InputDecoration(
                  labelText: 'File Path',
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 600,
              child: TextField(
                controller: _textEditingController2,
                decoration: const InputDecoration(
                  labelText: 'Storage Path',
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Container(
              width: 600,
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: uploadTask == null ? selectFile : null,
                    child: const Text('Select file'),
                  ),
                  ElevatedButton(
                    onPressed: uploadTask == null && canUpload ? putFile : null,
                    child: const Text('Put file'),
                  ),
                  ElevatedButton(
                    onPressed: uploadTask != null ? cancelTask : null,
                    child: const Text('Cancel task'),
                  ),
                ],
              ),
            ),
            DebugWidget(controller: _debugTextEditingController),
          ],
        ),
      ),
    );
  }
}
