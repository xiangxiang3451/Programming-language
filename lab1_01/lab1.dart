
import 'dart:async';
import 'dart:io';

Future<void> downloadFile(String url) async {

  final uri = Uri.parse(url);

  final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
  final file = File(fileName);

  final client = HttpClient();

  int downloadedBytes = 0;

  Timer? progressTimer;
  progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    print('Загружено: $downloadedBytes байт');
  });

  try {
    final request = await client.getUrl(uri);
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP-запрос не удался, код состояния: ${response.statusCode}');
    }

    final sink = file.openWrite();

    await response.listen((chunk) {
      sink.add(chunk);
      downloadedBytes += chunk.length;
    }).asFuture(); 

    await sink.close(); 
    print('Загрузка завершена, файл сохранён как: $fileName');
  } catch (e) {
    print('Ошибка загрузки: $e');
  } finally {
    progressTimer.cancel();
    client.close();
  }
}

void main(List<String> arguments) async {

  if (arguments.isEmpty) {
    print('Использование: dart filename.dart <URL>');
    exit(1);
  }

  final url = arguments[0];
  await downloadFile(url);
}
