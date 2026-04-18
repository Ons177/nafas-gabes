import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _selectedType;

  final List<String> _pollutionTypes = [
    'Fumée industrielle',
    'Eau contaminée',
    'Déchets sauvages',
    'Odeur suspecte',
    'Autre',
  ];

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  void submitReport() {
    if (_selectedImage == null) {
      _showSnack("Veuillez sélectionner une photo", AppTheme.warning);
      return;
    }
    _showSnack("Signalement envoyé avec succès ✓", AppTheme.mint);
    setState(() {
      _selectedImage = null;
      _selectedType = null;
    });
    descriptionController.clear();
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
    descriptionController.dispose();
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
                  // Image section
                  _buildImageSection(),
                  const SizedBox(height: 20),

                  // Pollution type
                  const Text(
                    'Type de pollution',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                  ),
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
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Ex : fumée noire près de l\'usine, eau suspecte…',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.teal, AppTheme.skyBlue],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppTheme.teal.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      label: const Text(
                        'Envoyer le signalement',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
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
              const Text(
                'Signaler une pollution',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
        const Text(
          'Photo du problème',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 200,
                  width: double.infinity,
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
            Expanded(
              child: _PhotoButton(
                icon: Icons.camera_alt_rounded,
                label: 'Caméra',
                onTap: pickImageFromCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoButton(
                icon: Icons.photo_library_rounded,
                label: 'Galerie',
                onTap: pickImageFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
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
  final String label;
  final bool selected;
  final VoidCallback onTap;
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
        boxShadow: selected ? [BoxShadow(color: AppTheme.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : AppTheme.teal,
        ),
      ),
    ),
  );
}