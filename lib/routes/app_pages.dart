import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bindings/detail_binding.dart';
import '../bindings/home_binding.dart';
import '../controllers/auth_controller.dart';
import '../controllers/character_controller.dart';
import '../controllers/favorite_controller.dart';
import '../models/character.dart';
import '../services/local_storage_service.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const detail = '/detail';
  static const bookmark = '/bookmark';
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final storage = Get.find<LocalStorageService>();

    final currentUser = storage.getSession();
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.home);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SpaceNews Explorer',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await authController.login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      Get.offAllNamed(AppRoutes.home);
                    } on Exception catch (error) {
                      Get.snackbar(
                        'Login gagal',
                        error.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Masuk'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Buat Akun'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await authController.register(
                    name: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  Get.back();
                  Get.snackbar(
                    'Berhasil',
                    'Akun berhasil dibuat.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } on Exception catch (error) {
                  Get.snackbar(
                    'Pendaftaran gagal',
                    error.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedNewsSite = 'Semua';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CharacterController>();
    final favoriteController = Get.find<FavoriteController>();
    final storage = Get.find<LocalStorageService>();
    final currentUser = storage.getSession();

    if (controller.characters.isEmpty && !controller.isLoading.value) {
      controller.fetchCharacters();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser?.name ?? 'SpaceNews Explorer'),
        actions: [
          IconButton(
            onPressed: () {
              favoriteController.loadFavorites();
              Get.toNamed(AppRoutes.bookmark);
            },
            icon: const Icon(Icons.favorite_rounded, color: Colors.pink),
          ),
          IconButton(
            onPressed: () async {
              final authController = Get.find<AuthController>();
              await authController.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.characters.isEmpty) {
          return const Center(child: Text('Tidak ada data berita.'));
        }

        final availableSources = <String>[
          'Semua',
          ...controller.characters
              .map((article) => article.newsSite)
              .where((source) => source.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort(),
        ];
        final selectedSource = availableSources.contains(_selectedNewsSite)
            ? _selectedNewsSite
            : 'Semua';
        final filteredList = controller.characters
            .where(
              (article) =>
                  selectedSource == 'Semua' ||
                  article.newsSite == selectedSource,
            )
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DropdownButtonFormField<String>(
                initialValue: selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Filter Sumber Berita',
                  border: OutlineInputBorder(),
                ),
                items: availableSources
                    .map(
                      (source) =>
                          DropdownMenuItem(value: source, child: Text(source)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedNewsSite = value);
                  }
                },
              ),
            ),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text('Tidak ada berita dari sumber ini.'),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final article = filteredList[index];
                        final isBookmarked = favoriteController.contains(
                          article,
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: article.image.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      article.image,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: Icon(Icons.newspaper, size: 36),
                                  ),
                            title: Text(
                              article.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  article.newsSite.isNotEmpty
                                      ? article.newsSite
                                      : 'Unknown Source',
                                ),
                                Text(
                                  article.publishedAt.isNotEmpty
                                      ? article.publishedAt
                                      : 'Unknown date',
                                ),
                              ],
                            ),
                            trailing: Icon(
                              isBookmarked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isBookmarked ? Colors.pink : Colors.grey,
                            ),
                            onTap: () => Get.toNamed(
                              AppRoutes.detail,
                              arguments: article,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final article =
        Get.arguments as Character? ??
        Character(id: 0, title: 'Unknown Article');
    final favoriteController = Get.find<FavoriteController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.displayTitle.isEmpty ? 'Detail Berita' : article.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: article.image.isEmpty
                  ? const _ArticleImagePlaceholder()
                  : Image.network(
                      article.image,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ArticleImagePlaceholder(),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              article.displayTitle.isEmpty
                  ? 'Judul berita tidak tersedia'
                  : article.displayTitle,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.source_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  article.newsSite.isNotEmpty
                      ? article.newsSite
                      : 'Unknown Source',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(_formatPublishedAt(article.publishedAt)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  article.author.isNotEmpty ? article.author : 'Unknown author',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              article.summary.isNotEmpty
                  ? article.summary
                  : 'Ringkasan berita tidak tersedia.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(article.url);
                  if (uri == null ||
                      !uri.isAbsolute ||
                      !{'http', 'https'}.contains(uri.scheme)) {
                    Get.snackbar(
                      'Gagal',
                      'Link artikel tidak tersedia atau tidak valid.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  try {
                    final launched = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      Get.snackbar(
                        'Gagal',
                        'Browser tidak dapat membuka artikel.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  } on Exception catch (error) {
                    Get.snackbar(
                      'Gagal membuka artikel',
                      error.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Read Full Article'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        final isBookmarked = favoriteController.favorites.any(
          (item) => item.id == article.id,
        );
        return FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () async {
            try {
              final added = await favoriteController.toggleFavorite(article);
              Get.snackbar(
                added ? 'Ditambahkan ke Bookmark' : 'Dihapus dari Bookmark',
                added
                    ? 'Berita berhasil disimpan.'
                    : 'Berita dihapus dari bookmark.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: added ? Colors.green : Colors.red,
                colorText: Colors.white,
              );
            } on Exception catch (error) {
              Get.snackbar(
                'Bookmark gagal diperbarui',
                error.toString(),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          child: Icon(
            isBookmarked ? Icons.favorite : Icons.favorite_border,
            color: isBookmarked ? Colors.pink : Colors.grey,
          ),
        );
      }),
    );
  }
}

class _ArticleImagePlaceholder extends StatelessWidget {
  const _ArticleImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, size: 48),
    );
  }
}

String _formatPublishedAt(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) {
    return value.isEmpty ? 'Tanggal publikasi tidak tersedia' : value;
  }

  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  return '$day/$month/${localDate.year}';
}

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();
    favoriteController.loadFavorites();

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: Obx(() {
        final items = favoriteController.favorites;
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada berita yang dibookmark.'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final article = items[index];
            return Dismissible(
              key: ValueKey(article.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) async {
                await favoriteController.removeBookmark(article.id);
                Get.snackbar(
                  'Berhasil',
                  'Bookmark dihapus.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: article.image.isNotEmpty
                      ? Image.network(
                          article.image,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.newspaper, size: 36),
                  title: Text(article.displayTitle),
                  subtitle: Text(
                    article.newsSite.isNotEmpty
                        ? article.newsSite
                        : 'Unknown Source',
                  ),
                  onTap: () =>
                      Get.toNamed(AppRoutes.detail, arguments: article),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPage(),
      binding: DetailBinding(),
    ),
    GetPage(name: AppRoutes.bookmark, page: () => const BookmarkPage()),
  ];
}
