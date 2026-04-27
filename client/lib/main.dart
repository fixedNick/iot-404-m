import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//
import 'package:client/models/anemometr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'kostudio IoT',
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightBlue)),
          home: const MyHomePage(title: 'Home Assistant'),
        );
      },
      child: const MyHomePage(title: 'Home Assistant'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Icon(Icons.all_inclusive_sharp, color: Colors.black87),
            const SizedBox(width: 10),
            Text(
              widget.title,
              style: GoogleFonts.aBeeZee(color: Colors.black87),
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.wind_power_rounded),
              title: const Text('Анемометр'),
              subtitle: const Text(
                'Текущая скорость ветра',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnemometerPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.thermostat_auto_sharp),
              title: const Text('Основные датчики'),
              subtitle: const Text(
                'Температура и влажность воздуха',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainSensorsPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_enhance_outlined),
              title: const Text('Камеры'),
              subtitle: const Text(
                'Проверка камер',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnemometerPage extends StatefulWidget {
  const AnemometerPage({super.key});

  @override
  State<AnemometerPage> createState() => _AnemometerPageState();
}

class _AnemometerPageState extends State<AnemometerPage> {
  late Future<WindData> _windDataFuture;

  @override
  void initState() {
    super.initState();
    _windDataFuture = AnemometerRepository()
        .fetchCurrentWeather(); // Твой метод получения данных
  }

  // Метод для ручного обновления (кнопка Refresh)
  void _refresh() {
    setState(() {
      _windDataFuture = AnemometerRepository().fetchCurrentWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Анемометр'),
      ),
      // CustomScrollView позволяет смешивать обычные блоки и сетки
      body: CustomScrollView(
        slivers: [
          // 1. Блок со скоростью на всю ширину
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: FutureBuilder<WindData>(
                    future: _windDataFuture,
                    builder: (context, snapshot) {
                      // 1. СОСТОЯНИЕ ЗАГРУЗКИ
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 50.r,
                              width: 50.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                              ), // Анимация загрузки
                            ),
                            SizedBox(height: 15.h),
                            const Text("Получение данных с датчика..."),
                          ],
                        );
                      }

                      // 2. СОСТОЯНИЕ ОШИБКИ (Таймаут, нет сети и т.д.)
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 50.r,
                              color: Colors.red,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              textAlign: TextAlign.center,
                              "Ошибка получения данных",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text("Попробовать снова"),
                            ),
                          ],
                        );
                      }

                      // 3. ДАННЫЕ УСПЕШНО ПОЛУЧЕНЫ
                      final data = snapshot.data!;
                      if (data.message != null) {
                        return Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 50.r,
                              color: Colors.red,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              'Ошибка: ${data.message}',
                              style: TextStyle(
                                fontFamily: "AppleSanFrancisco",
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.pink.withAlpha(15),
                                ),
                              ),
                              onPressed: _refresh,
                              child: const Text(
                                textAlign: TextAlign.center,
                                "Попробовать снова",
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Icon(Icons.air, size: 60.r, color: Colors.blue),
                          Text(
                            "Текущая скорость ветра",
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          Text(
                            "${data.speed} м/с (${data.voltage}V)",
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Обновлено в ${data.timestamp!.hour}:${data.timestamp!.minute}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 2. Сетка с кнопками действий
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            sliver: SliverGrid.count(
              crossAxisCount: width > 360 ? 2 : 1, // Адаптивность колонок
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: width > 360
                  ? .8
                  : 1.5, // Чтобы карточки не были слишком высокими
              children: [
                _buildActionCard(
                  icon: Icons.refresh,
                  title: "Обновить данные",
                  subtitle: "Запрос к ESP8266",
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.restart_alt_rounded,
                  title: "Перезапустить устройство",
                  isWarning: false,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.memory_sharp,
                  title: "Настроить",
                  isWarning: true,
                  warningText: "Установка СМС команд",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Выносим создание карточки в отдельный метод, чтобы не дублировать код
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isWarning = false,
    String? warningText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(5.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30.r, color: Colors.blue),
              SizedBox(height: 10.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              if (isWarning && warningText != null)
                Text(
                  warningText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Камеры'),
      ),
      body: const Center(
        child: Text('Coming soon...', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class MainSensorsPage extends StatelessWidget {
  const MainSensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Основные датчики'),
      ),
      body: const Center(
        child: Text('Coming soon...', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
