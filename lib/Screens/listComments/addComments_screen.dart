import 'dart:ui';
import 'package:aparcamientoszaragoza/Models/comment.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/providers/CommentsProviders.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class AddComments extends ConsumerStatefulWidget {
  static const routeName = '/add-comment';

  const AddComments({super.key});

  @override
  ConsumerState<AddComments> createState() => _AddCommentsState();
}

class _AddCommentsState extends ConsumerState<AddComments> {
  final TextEditingController _contenidoController = TextEditingController();
  int _currentRating = 0;
  List<String> _selectedTags = [];
  
  int? _idPlaza;
  Comment? _commentOld;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final dynamic args = ModalRoute.of(context)?.settings.arguments;
      if (args is List && args.isNotEmpty) {
        _idPlaza = args[0] as int;
        if (args.length > 1 && args[1] is Comment) {
          _commentOld = args[1] as Comment;
          _contenidoController.text = _commentOld?.contenido ?? "";
          _currentRating = _commentOld?.ranking ?? 0;
        }
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_idPlaza == null) {
      return Scaffold(body: Center(child: Text(l10n.loadPlazaError)));
    }

    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));
    final plaza = homeDataState.value?.getGarageById(_idPlaza!);
    final User? user = homeDataState.value?.user;

    if (plaza == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Image.asset(
              'assets/basilica.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildPhotoSection(l10n),
                        const SizedBox(height: 30),
                        _buildBottomCard(context, plaza, user, l10n),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickySubmitButton(context, plaza, user, l10n),
    );
  }

  Widget _buildStickySubmitButton(BuildContext context, Garaje plaza, User? user, AppLocalizations l10n) {
    final commentState = ref.watch(commentsProvider);
    final isLoading = commentState == "LOAD";

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.98),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => _submitReview(context, plaza, user),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            disabledBackgroundColor: Colors.blue.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isLoading ? 0 : 8,
            shadowColor: Colors.blue.withOpacity(0.4),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  l10n.sendReviewAction,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            l10n.addCommentTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.skipAction, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
          ),
          child: const Icon(Icons.add_a_photo, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.captureExperience,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            l10n.photoTip,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.file_upload_outlined, color: Colors.white, size: 18),
          label: Text(l10n.selectPhotoAction, style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        const SizedBox(height: 40),
        const Icon(Icons.keyboard_arrow_down, color: Colors.white30),
      ],
    );
  }

  Widget _buildBottomCard(BuildContext context, Garaje plaza, User? user, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plaza Mini Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "https://picsum.photos/seed/${plaza.idPlaza}/100/100",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plaza.direccion, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(l10n.spainIndicator(plaza.Provincia), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating
          Center(
            child: Column(
              children: [
                _buildRatingStars(),
                const SizedBox(height: 12),
                Text(l10n.tapToRate, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // Tags
          Text(l10n.highlightsTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTag(l10n.tagClean),
              _buildTag(l10n.tagSafe),
              _buildTag(l10n.tagEasyAccess),
              _buildTag(l10n.tagCentral),
              _buildTag(l10n.tagSpacious),
            ],
          ),
          const SizedBox(height: 35),

          // Comment
          Text(l10n.yourCommentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 15),
          TextField(
            controller: _contenidoController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.commentHint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool isActive = index < _currentRating;
        return GestureDetector(
          onTap: () => setState(() => _currentRating = index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.star,
              color: isActive ? Colors.blue : Colors.white10.withOpacity(0.05),
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTag(String tag) {
    bool isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue : Colors.white10, width: 1),
        ),
        child: Text(
          tag,
          style: TextStyle(color: isSelected ? Colors.blue : Colors.white60, fontSize: 13),
        ),
      ),
    );
  }

  void _submitReview(BuildContext context, Garaje plaza, User? user) {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.selectRatingError)));
      return;
    }

    final commentNew = Comment(
      user?.uid,
      user?.displayName ?? AppLocalizations.of(context)!.anonymousUser, 
      _contenidoController.text,
      DateTime.now(),
      _currentRating,
    );

    if (_commentOld != null) {
      ref.read(commentsProvider.notifier).updateComment(_idPlaza!, _commentOld!, commentNew);
    } else {
      ref.read(commentsProvider.notifier).addComment(_idPlaza!, commentNew);
    }

    // Volver a la lista de comentarios. El listener en ListCommentsPage mostrará el resultado.
    Navigator.of(context).pop();
  }
}
