// screens/admin/admin_manage_users.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_user_detail.dart'; // <-- THÊM IMPORT MỚI

class AdminManageUsersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-users';
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  late Future<void> _fetchUsersFuture;
  late Future<void> _fetchStatsFuture; // Thêm Future cho thống kê

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Gọi cả hai API
    _fetchUsersFuture = adminProvider.fetchUsers(token);
    _fetchStatsFuture = adminProvider.fetchUserStats(token);
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc muốn xóa tài khoản $userName?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token!;
        await Provider.of<AdminProvider>(context, listen: false)
            .deleteUser(userId, token);
      } catch (e) {
        await _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tài khoản'), // Khóa Tiếng Việt
      ),
      body: Column( // Bọc nội dung trong Column
        children: [
          // === WIDGET THỐNG KÊ MỚI ===
          _buildStatsCard(),

          // === DANH SÁCH USER (bọc trong Expanded) ===
          Expanded(
            child: FutureBuilder(
              future: _fetchUsersFuture, // Chỉ build danh sách user
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (adminProvider.isLoadingUsers) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (adminProvider.errorUsers != null) {
                      return Center(child: Text(adminProvider.errorUsers!));
                    }
                    if (adminProvider.users.isEmpty) {
                      return const Center(
                        child: Text('Không tìm thấy tài khoản user nào.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: adminProvider.users.length,
                      itemBuilder: (ctx, index) {
                        final user = adminProvider.users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.email[0].toUpperCase()),
                            ),
                            title: Text(user.email),
                            subtitle: Text('ID: ${user.id}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () =>
                                  _confirmDelete(user.id, user.email),
                            ),
                            // === THÊM ONTAP ĐỂ XEM CHI TIẾT ===
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AdminUserDetailStatsScreen.routeName,
                                arguments: user, // Truyền cả object user
                              );
                            },
                            // ===================================
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET HELPER CHO THỐNG KÊ ===
  Widget _buildStatsCard() {
    return FutureBuilder(
      future: _fetchStatsFuture, // Dùng future của thống kê
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Dùng Consumer để lấy dữ liệu đã được fetch
        return Consumer<AdminProvider>(
          builder: (ctx, adminProvider, _) {
            final stats = adminProvider.userStats;
            if (stats == null) {
              return const Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Không thể tải thống kê user'),
                  leading: Icon(Icons.error_outline, color: Colors.red),
                ),
              );
            }
            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Tổng User',
                      stats['totalUsers'].toString(),
                      Icons.people,
                    ),
                    _buildStatItem(
                      'User mới (3 ngày)',
                      stats['newUsersLast3Days'].toString(),
                      Icons.person_add,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}