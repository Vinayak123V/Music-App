import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/search_normalizer.dart';
import '../../data/models/rights_management_model.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/upload_repository.dart';
import '../../providers/auth_providers.dart';
import '../../providers/category_providers.dart';
import '../../providers/song_providers.dart';
import '../../widgets/saffron_button.dart';

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  return FirebaseStorageUploadRepository();
});

class AdminUploadSongDialog extends ConsumerStatefulWidget {
  final SongModel? songToEdit;

  const AdminUploadSongDialog({super.key, this.songToEdit});

  @override
  ConsumerState<AdminUploadSongDialog> createState() => _AdminUploadSongDialogState();
}

class _AdminUploadSongDialogState extends ConsumerState<AdminUploadSongDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _rightsHolderController;
  late TextEditingController _licenseRefController;
  late TextEditingController _permittedUsageController;

  String _selectedCategory = 'bhajans';
  String _selectedDeity = 'shiva';
  String _selectedLanguage = 'Hindi';
  bool _isFeatured = false;
  bool _isPublished = true;
  bool _commercialAuthorized = true;

  // Selected Files
  PlatformFile? _pickedAudioFile;
  PlatformFile? _pickedArtworkFile;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    final song = widget.songToEdit;

    _titleController = TextEditingController(text: song?.title ?? '');
    _artistController = TextEditingController(text: song?.artist ?? '');
    _descriptionController = TextEditingController(text: song?.description ?? '');
    _durationController = TextEditingController(
      text: song?.durationSeconds != null ? song!.durationSeconds.toString() : '',
    );
    _rightsHolderController = TextEditingController(
      text: song?.rights?.rightsHolder ?? 'Bhakti Records India',
    );
    _licenseRefController = TextEditingController(
      text: song?.rights?.licenseReference ?? 'BM-2026-LIC-01',
    );
    _permittedUsageController = TextEditingController(
      text: song?.rights?.permittedUsage ?? 'Worldwide digital devotional streaming',
    );

    if (song != null) {
      _selectedCategory = song.categoryId;
      _selectedDeity = song.deityId;
      _selectedLanguage = song.language;
      _isFeatured = song.featured;
      _isPublished = song.published;
      _commercialAuthorized = song.rights?.commercialAuthorized ?? true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _rightsHolderController.dispose();
    _licenseRefController.dispose();
    _permittedUsageController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'aac', 'wav'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 50 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio file exceeds 50 MB limit.')),
          );
        }
        return;
      }
      setState(() {
        _pickedAudioFile = file;
      });
    }
  }

  Future<void> _pickArtworkFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artwork exceeds 5 MB limit.')),
          );
        }
        return;
      }
      setState(() {
        _pickedArtworkFile = file;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.songToEdit == null && _pickedAudioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an MP3 audio file to upload.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.05;
      _uploadStatus = 'Preparing devotional assets...';
    });

    try {
      final uploadRepo = ref.read(uploadRepositoryProvider);
      final songRepo = ref.read(songRepositoryProvider);
      final user = ref.read(currentUserProvider);

      final songId = widget.songToEdit?.id ?? const Uuid().v4();

      String audioUrl = widget.songToEdit?.audioUrl ?? '';
      String storagePath = widget.songToEdit?.storagePath ?? 'audio/$songId/original.mp3';

      // 1. Upload audio file if new file was picked
      if (_pickedAudioFile != null) {
        setState(() {
          _uploadStatus = 'Uploading audio file to Firebase Storage...';
        });

        audioUrl = await uploadRepo.uploadAudioFile(
          songId: songId,
          fileBytes: _pickedAudioFile!.bytes!,
          fileName: _pickedAudioFile!.name,
          fileSize: _pickedAudioFile!.size,
          onProgress: (p) {
            setState(() {
              _uploadProgress = 0.1 + (p * 0.6);
            });
          },
        );
      }

      // 2. Upload artwork if picked
      String? artworkUrl = widget.songToEdit?.artworkUrl;
      String? artworkPath = widget.songToEdit?.artworkPath;

      if (_pickedArtworkFile != null) {
        setState(() {
          _uploadStatus = 'Uploading cover artwork...';
        });

        artworkUrl = await uploadRepo.uploadArtworkFile(
          songId: songId,
          fileBytes: _pickedArtworkFile!.bytes!,
          fileName: _pickedArtworkFile!.name,
          fileSize: _pickedArtworkFile!.size,
        );
        artworkPath = 'artwork/$songId/cover.jpg';
      }

      // 3. Construct Song Model
      setState(() {
        _uploadStatus = 'Saving verified metadata to Cloud Firestore...';
        _uploadProgress = 0.85;
      });

      final title = _titleController.text.trim();
      final artist = _artistController.text.trim();
      final duration = int.tryParse(_durationController.text.trim()) ?? 300;

      final rights = RightsManagementModel(
        rightsHolder: _rightsHolderController.text.trim(),
        licenseReference: _licenseRefController.text.trim(),
        permittedUsage: _permittedUsageController.text.trim(),
        commercialAuthorized: _commercialAuthorized,
      );

      final song = SongModel(
        id: songId,
        title: title,
        normalizedTitle: SearchNormalizer.normalize(title),
        artist: artist,
        categoryId: _selectedCategory,
        deityId: _selectedDeity,
        language: _selectedLanguage,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        artworkPath: artworkPath,
        artworkUrl: artworkUrl,
        storagePath: storagePath,
        audioUrl: audioUrl,
        durationSeconds: duration,
        published: _isPublished,
        featured: _isFeatured,
        searchTokens: SearchNormalizer.generateSearchTokens([
          title,
          artist,
          _selectedDeity,
          _selectedCategory,
          _selectedLanguage,
        ]),
        createdAt: widget.songToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: user?.uid ?? 'admin',
        rights: rights,
      );

      await songRepo.saveSong(song);

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Successfully saved!';
      });

      if (mounted) {
        ref.invalidate(adminSongsListProvider);
        ref.invalidate(publishedSongsProvider);
        ref.invalidate(featuredSongsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Text(
              widget.songToEdit != null
                  ? 'Song updated successfully.'
                  : 'Devotional song uploaded and published.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text('Upload failed: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final deitiesAsync = ref.watch(deitiesListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.songToEdit != null ? 'Edit Devotional Song' : 'Upload New Devotional Song',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isUploading ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // Scrollable Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Song Title *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
                        ),
                        const SizedBox(height: 14),

                        // Artist
                        TextFormField(
                          controller: _artistController,
                          decoration: const InputDecoration(labelText: 'Artist / Singer / Acharya *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter artist' : null,
                        ),
                        const SizedBox(height: 14),

                        // Deity & Category Row
                        Row(
                          children: [
                            // Deity Dropdown
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedDeity,
                                decoration: const InputDecoration(labelText: 'Deity *'),
                                items: deitiesAsync.value?.map((d) {
                                      return DropdownMenuItem(value: d.id, child: Text(d.name));
                                    }).toList() ??
                                    AppConstants.defaultDeities.map((d) {
                                      return DropdownMenuItem(
                                        value: d['id'] as String,
                                        child: Text(d['name'] as String),
                                      );
                                    }).toList(),
                                onChanged: (v) => setState(() => _selectedDeity = v!),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Category Dropdown
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(labelText: 'Category *'),
                                items: categoriesAsync.value?.map((c) {
                                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                                    }).toList() ??
                                    AppConstants.defaultCategories.map((c) {
                                      return DropdownMenuItem(
                                        value: c['id'] as String,
                                        child: Text(c['name'] as String),
                                      );
                                    }).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Language & Duration Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedLanguage,
                                decoration: const InputDecoration(labelText: 'Language *'),
                                items: AppConstants.supportedLanguages
                                    .where((l) => l != 'All')
                                    .map((lang) {
                                  return DropdownMenuItem(value: lang, child: Text(lang));
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedLanguage = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Duration (seconds)',
                                  hintText: 'e.g. 360',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Spiritual Meaning & Context (Optional)',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // File Upload Section
                        const Text(
                          'AUDIO & ARTWORK FILES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.saffronDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Pick Audio File
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          leading: const Icon(Icons.audio_file_rounded, color: AppColors.saffronPrimary),
                          title: Text(
                            _pickedAudioFile != null
                                ? _pickedAudioFile!.name
                                : (widget.songToEdit?.storagePath ?? 'Select Audio (.mp3, max 50MB)'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: _pickedAudioFile != null
                              ? Text(Formatters.formatFileSize(_pickedAudioFile!.size))
                              : const Text('MP3 format recommended'),
                          trailing: OutlinedButton(
                            onPressed: _pickAudioFile,
                            child: Text(_pickedAudioFile != null ? 'Change' : 'Browse'),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Pick Artwork File
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.borderSubtle),
                          ),
                          leading: const Icon(Icons.image_outlined, color: AppColors.goldAccent),
                          title: Text(
                            _pickedArtworkFile != null
                                ? _pickedArtworkFile!.name
                                : (widget.songToEdit?.artworkUrl != null ? 'Existing Cover Artwork' : 'Select Artwork (.jpg/.png, max 5MB)'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: _pickedArtworkFile != null
                              ? Text(Formatters.formatFileSize(_pickedArtworkFile!.size))
                              : const Text('Aspect ratio 1:1 recommended'),
                          trailing: OutlinedButton(
                            onPressed: _pickArtworkFile,
                            child: Text(_pickedArtworkFile != null ? 'Change' : 'Browse'),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Rights Management Section
                        const Text(
                          'RIGHTS & LICENSING RECORD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.saffronDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _rightsHolderController,
                          decoration: const InputDecoration(labelText: 'Rights Holder / Studio'),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _licenseRefController,
                                decoration: const InputDecoration(labelText: 'License Reference #'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _permittedUsageController,
                                decoration: const InputDecoration(labelText: 'Permitted Usage'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Featured & Published Toggles
                        SwitchListTile(
                          title: const Text('Publish Immediately'),
                          subtitle: const Text('If disabled, saves as draft hidden from devotees'),
                          value: _isPublished,
                          activeColor: AppColors.saffronPrimary,
                          onChanged: (v) => setState(() => _isPublished = v),
                        ),
                        SwitchListTile(
                          title: const Text('Feature on Home Screen'),
                          subtitle: const Text('Highlight in top banner of mobile app'),
                          value: _isFeatured,
                          activeColor: AppColors.saffronPrimary,
                          onChanged: (v) => setState(() => _isFeatured = v),
                        ),
                      ],
                    ),
                  ),
                ),

                // Upload Progress Bar
                if (_isUploading) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _uploadProgress, color: AppColors.saffronPrimary),
                  const SizedBox(height: 6),
                  Text(
                    _uploadStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.saffronDark),
                  ),
                ],

                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isUploading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    SaffronButton(
                      label: widget.songToEdit != null ? 'Save Changes' : 'Upload & Publish',
                      isLoading: _isUploading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
