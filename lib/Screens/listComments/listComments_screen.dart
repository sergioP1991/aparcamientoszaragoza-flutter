import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/addComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/providers/CommentsProviders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/comment.dart';
import '../../Models/garaje.dart';
import '../../Values/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class ListCommentsPage extends ConsumerWidget {
  static const routeName = '/listComments-page';

  ListCommentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));
    ref.listen<String?>(commentsProvider, (previous, next) {
      if (next != null && next != "LOAD" && next != "") {
        _mostrarDialogo(context, ref, AppLocalizations.of(context)!.infoTitle, next);
      }
    });

    final isCommentLoading = ref.watch(commentsProvider) == "LOAD";

    final user = homeDataState.value?.user;
    final indexPlaza = (ModalRoute.of(context)?.settings.arguments ?? 0) as int;
    final Garaje? plaza = homeDataState.value?.getGarageById(indexPlaza);

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.reviewsTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: plaza == null || isCommentLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, ref, plaza, user),
      bottomNavigationBar: _buildBottomUI(context, indexPlaza),
    );
  }

  Widget _buildBottomUI(BuildContext context, int indexPlaza) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: BoxDecoration(
        color: AppColors.darkerBlue,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AddComments.routeName, arguments: [indexPlaza]),
          icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 20),
          label: Text(
            AppLocalizations.of(context)!.writeCommentAction,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Garaje plaza, User? user) {
    final comments = plaza.comments ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildSummaryCard(context, comments),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recentCommentsTitle,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune, color: Colors.blue, size: 16),
                label: Text(AppLocalizations.of(context)!.filterAction, style: const TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (comments.isEmpty)
            _buildEmptyState(context)
          else
            ...comments.map((comment) => _buildCommentItem(context, ref, comment, user, plaza.idPlaza ?? 0)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<Comment> comments) {
    double average = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    if (comments.isNotEmpty) {
      int sum = 0;
      for (var c in comments) {
        sum += c.ranking;
        distribution[c.ranking] = (distribution[c.ranking] ?? 0) + 1;
      }
      average = sum / comments.length;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            average.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < average.floor() ? Icons.star : (index < average ? Icons.star_half : Icons.star_border),
                color: Colors.amber,
                size: 24,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.basedOnReviews(comments.length),
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ...[5, 4, 3, 2, 1].map((star) {
            double percent = comments.isEmpty ? 0 : distribution[star]! / comments.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text("$star", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, WidgetRef ref, Comment comment, User? user, int idPlaza) {
    bool isOwner = user != null && comment.idUsuario == user.uid;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.titulo ?? AppLocalizations.of(context)!.anonymousUser,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(comment.fecha ?? DateTime.now()),
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < comment.ranking ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.contenido ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          if (isOwner) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => ref.read(commentsProvider.notifier).deleteComment(idPlaza, comment),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pushNamed(AddComments.routeName, arguments: [idPlaza, comment]),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, color: Colors.white10, size: 64),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noReviewsYet,
            style: const TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }


  void _mostrarDialogo(BuildContext context, WidgetRef ref, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(titulo, style: const TextStyle(color: Colors.white)),
          content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(commentsProvider.notifier).clearState();
              },
              child: Text(AppLocalizations.of(context)!.acceptAction, style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
