
import 'dart:async';
import 'dart:io';

Future<void> downloadFile(String url) async {
  // Разбор URL
  final uri = Uri.parse(url);

  // Получение имени файла, по умолчанию "downloaded_file"
  final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
  final file = File(fileName);

  // Открытие HTTP-клиента
  final client = HttpClient();

  // Отслеживание количества загруженных байт
  int downloadedBytes = 0;

  // Таймер для вывода прогресса загрузки каждую секунду
  Timer? progressTimer;
  progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    print('Загружено: $downloadedBytes байт');
  });

  try {
    // Отправка HTTP GET-запроса
    final request = await client.getUrl(uri);
    final response = await request.close();

    // Проверка статуса ответа
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP-запрос не удался, код состояния: ${response.statusCode}');
    }

    // Создание потока для записи в файл
    final sink = file.openWrite();

    // Асинхронное чтение данных из ответа и запись в файл
    await response.listen((chunk) {
      sink.add(chunk);
      downloadedBytes += chunk.length;
    }).asFuture(); // Ожидание завершения потока

    await sink.close(); // Закрытие потока файла
    print('Загрузка завершена, файл сохранён как: $fileName');
  } catch (e) {
    print('Ошибка загрузки: $e');
  } finally {
    // Остановка таймера прогресса
    progressTimer?.cancel();
    client.close();
  }
}

void main(List<String> arguments) async {
  // Проверка аргументов командной строки
  if (arguments.isEmpty) {
    print('Использование: dart wget_minimal.dart <URL>');
    exit(1);
  }

  final url = arguments[0];
  await downloadFile(url);
}
