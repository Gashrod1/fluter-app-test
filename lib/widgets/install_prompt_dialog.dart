import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum DevicePlatform { ios, android }

class InstallPromptDialog extends StatefulWidget {
  const InstallPromptDialog({super.key});

  @override
  State<InstallPromptDialog> createState() => _InstallPromptDialogState();
}

class _InstallPromptDialogState extends State<InstallPromptDialog> {
  late DevicePlatform _selectedPlatform;

  @override
  void initState() {
    super.initState();
    // Détecter la plateforme par défaut
    if (!kIsWeb && Platform.isIOS) {
      _selectedPlatform = DevicePlatform.ios;
    } else {
      _selectedPlatform = DevicePlatform.android;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.phone_android, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text('Installer l\'application')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pour une meilleure expérience, ajoutez cette application à votre écran d\'accueil !',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildPlatformSelector(),
            const SizedBox(height: 16),
            _buildInstructions(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Plus tard'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('J\'ai compris'),
        ),
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPlatformButton(
              platform: DevicePlatform.ios,
              icon: Icons.apple,
              label: 'iOS',
            ),
          ),
          Expanded(
            child: _buildPlatformButton(
              platform: DevicePlatform.android,
              icon: Icons.android,
              label: 'Android',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformButton({
    required DevicePlatform platform,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedPlatform == platform;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlatform = platform;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return _selectedPlatform == DevicePlatform.ios
        ? _buildIOSInstructions()
        : _buildAndroidInstructions();
  }

  Widget _buildIOSInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions pour iOS :',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        _buildInstructionStep(
          '1',
          'Ouvrez cette page dans Safari',
          description: 'L\'application doit être ouverte dans le navigateur Safari',
        ),
        _buildInstructionStep(
          '2',
          'Appuyez sur le bouton "Partager"',
          icon: Icons.ios_share,
          description: 'Recherchez l\'icône de partage en bas au centre de l\'écran',
        ),
        _buildInstructionStep(
          '3',
          'Faites défiler vers le bas',
          description: 'Trouvez l\'option "Sur l\'écran d\'accueil" dans le menu',
        ),
        _buildInstructionStep(
          '4',
          'Appuyez sur "Ajouter"',
          description: 'Confirmez en appuyant sur "Ajouter" en haut à droite',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'L\'icône apparaîtra sur votre écran d\'accueil comme une app native',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAndroidInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions pour Android :',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        _buildInstructionStep(
          '1',
          'Appuyez sur le menu (⋮)',
          icon: Icons.more_vert,
          description: 'Trouvez les trois points verticaux en haut à droite du navigateur',
        ),
        _buildInstructionStep(
          '2',
          'Sélectionnez "Ajouter à l\'écran d\'accueil"',
          description: 'Ou "Installer l\'application" selon votre navigateur',
        ),
        _buildInstructionStep(
          '3',
          'Confirmez l\'installation',
          description: 'Appuyez sur "Ajouter" ou "Installer" pour finaliser',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Compatible avec Chrome, Firefox, Edge et autres navigateurs modernes',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(
    String number,
    String text, {
    IconData? icon,
    String? description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: icon != null
                      ? Icon(icon, size: 16, color: Colors.white)
                      : Text(
                          number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
