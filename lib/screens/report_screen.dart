import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descriptionController = TextEditingController();
  Uint8List? _imageBytes;
  String?    _imageName;
  String?    _selectedType;
  bool       _isSubmitting = false;

  final List<String> _pollutionTypes = [
    'Fumée industrielle',
    'Eau contaminée',
    'Déchets sauvages',
    'Odeur suspecte',
    'Autre',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName  = image.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      _showSnack("Veuillez choisir un type de pollution", AppTheme.warning);
      return;
    }
    if (_imageBytes == null) {
      _showSnack("Veuillez sélectionner une photo", AppTheme.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    // Appelle POST /report/image (avec photo) ou POST /report (sans)
    final result = await ApiService.submitReport(
      reportType:  _selectedType!,
      description: _descriptionController.text.trim(),
      imageBytes:  _imageBytes,
      imageName:   _imageName,
    );

    setState(() => _isSubmitting = false);

    if (result != null) {
      _showSnack("✓ Signalement envoyé — les citoyens sont prévenus !", AppTheme.mint);
      setState(() {
        _imageBytes   = null;
        _imageName    = null;
        _selectedType = null;
      });
      _descriptionController.clear();
    } else {
      _showSnack("Erreur lors de l'envoi. Vérifiez votre connexion.", AppTheme.danger);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo
                  _buildImageSection(),
                  const SizedBox(height: 20),

                  // Type
                  const Text('Type de pollution',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _pollutionTypes.map((t) => _TypeChip(
                      label: t,
                      selected: _selectedType == t,
                      onTap: () => setState(() => _selectedType = t),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: "Ex : fumée noire près de l'usine, eau suspecte…",
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton envoyer
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.teal, AppTheme.skyBlue]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: AppTheme.teal.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      label: Text(
                        _isSubmitting ? 'Envoi en cours…' : 'Envoyer le signalement',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.paleTeal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.teal.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppTheme.teal, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Votre signalement sera visible par tous les citoyens de Gabès.',
                            style: TextStyle(fontSize: 12, color: AppTheme.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              const Text('Signaler une pollution',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo du problème',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _imageBytes != null
              ? Stack(
                  children: [
                    Image.memory(_imageBytes!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() { _imageBytes = null; _imageName = null; }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: Colors.black38,
                        child: Text(_imageName ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 200, width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.paleTeal,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.teal.withOpacity(0.2), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, size: 44, color: AppTheme.teal.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text('Aucune image sélectionnée',
                          style: TextStyle(color: AppTheme.teal.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _PhotoButton(icon: Icons.camera_alt_rounded,    label: 'Caméra',  onTap: () => _pickImage(ImageSource.camera))),
            const SizedBox(width: 12),
            Expanded(child: _PhotoButton(icon: Icons.photo_library_rounded, label: 'Galerie', onTap: () => _pickImage(ImageSource.gallery))),
          ],
        ),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────
class _PhotoButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _PhotoButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.teal.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.teal, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
}

class _TypeChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.teal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppTheme.teal : AppTheme.teal.withOpacity(0.3)),
        boxShadow: selected
            ? [BoxShadow(color: AppTheme.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
            : [],
      ),
      child: Text(label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.teal)),
    ),
  );
}