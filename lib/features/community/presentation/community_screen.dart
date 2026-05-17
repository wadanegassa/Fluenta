import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/community_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Community", style: AppTextStyles.h1),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: roomsAsync.when(
              data: (rooms) => ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.s20),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return _RoomCard(room: room);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s20),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search rooms or people...",
          prefixIcon: const Icon(Icons.search),
          fillColor: AppColors.surfaceWarm,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final dynamic room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/community/room/${room.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(room.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: AppTextStyles.h3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${room.memberCount} members",
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
