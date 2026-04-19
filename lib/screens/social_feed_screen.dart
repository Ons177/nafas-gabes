import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'create_post_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  final String fullName;

  const SocialFeedScreen({super.key, required this.fullName});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getSocialPosts();
    setState(() {
      _posts = data;
      _isLoading = false;
    });
  }

  Future<void> _reactToPost(int postId, String reactionType) async {
    final ok = await ApiService.reactToPost(
      postId: postId,
      reactionType: reactionType,
      userFullName: widget.fullName,
    );

    if (ok) {
      await _loadPosts();
    } else {
      _showSnack("Erreur lors de la réaction", AppTheme.danger);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        color: AppTheme.teal,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.teal),
                    )
                  : _posts.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.forum_outlined,
                                    size: 48,
                                    color: AppTheme.textLight,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Aucune publication pour le moment",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Soyez le premier à publier un signalement citoyen.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.textMid,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _SocialPostCard(
                                post: _posts[index],
                                onReact: _reactToPost,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Publier"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(fullName: widget.fullName),
            ),
          );
          _loadPosts();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepTeal, AppTheme.teal, AppTheme.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Veille citoyenne",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final Future<void> Function(int, String) onReact;

  const _SocialPostCard({
    required this.post,
    required this.onReact,
  });

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fumée industrielle':
        return AppTheme.danger;
      case 'eau contaminée':
        return AppTheme.skyBlue;
      case 'déchets sauvages':
        return AppTheme.warning;
      case 'odeur suspecte':
        return AppTheme.mint;
      default:
        return AppTheme.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int postId = post["id"] ?? 0;
    final String fullName = post["user_full_name"] ?? "Citoyen";
    final String type = post["post_type"] ?? "Publication";
    final String description = post["description"] ?? "";
    final String location = post["location_name"] ?? "Gabès";
    final String createdAt = post["created_at"] ?? "";
    final String? imageUrl = post["image_url"];
    final int confirms = post["confirms_count"] ?? 0;
    final int urgents = post["urgents_count"] ?? 0;
    final color = _typeColor(type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(Icons.person, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$location • $createdAt",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMid,
                  height: 1.4,
                ),
              ),
            ),
          if (imageUrl != null && imageUrl.toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Image.network(
                  "${ApiService.baseUrl}/$imageUrl",
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: AppTheme.paleTeal,
                    alignment: Alignment.center,
                    child: const Text(
                      "Image indisponible",
                      style: TextStyle(color: AppTheme.textMid),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                _ReactionChip(
                  icon: Icons.verified_rounded,
                  label: "Confirmé ($confirms)",
                  color: AppTheme.teal,
                  onTap: () => onReact(postId, "confirm"),
                ),
                const SizedBox(width: 8),
                _ReactionChip(
                  icon: Icons.priority_high_rounded,
                  label: "Urgent ($urgents)",
                  color: AppTheme.danger,
                  onTap: () => onReact(postId, "urgent"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}