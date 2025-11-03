import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'models/device.dart';

class HomePage extends StatefulWidget {
  final String session;

  const HomePage({
    super.key,
    required this.session,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device>? _devices;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final devices = await ApiService.getDevices(widget.session);
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors du chargement des devices: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendCommand(Device device, DeviceAction action) async {
    try {
      final success =
          await ApiService.sendCommand(widget.session, device.id, action);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande envoyée à ${device.name}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message de succès
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade700, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Connexion réussie !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 0),

            // Section Devices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes Devices',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadDevices,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Liste des devices
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              )
            else if (_devices == null || _devices!.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Aucun device trouvé'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _devices!.length,
                  itemBuilder: (context, index) {
                    final device = _devices![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête du device
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.device_hub,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${device.id}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Boutons de contrôle
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Calcul de la taille de police en fonction de la largeur
                                final double buttonWidth = constraints.maxWidth / 3;
                                final double fontSize = buttonWidth < 100 ? 11 : (buttonWidth < 120 ? 13 : 14);
                                final double iconSize = buttonWidth < 100 ? 16 : 18;
                                final double padding = buttonWidth < 100 ? 4 : 8;
                                
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Bouton STOP
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _sendCommand(device, DeviceAction.stop),
                                        icon: Icon(Icons.stop, size: iconSize),
                                        label: Text(
                                          'Stop',
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: padding,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Bouton DOWN
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _sendCommand(device, DeviceAction.down),
                                        icon: Icon(Icons.arrow_downward,
                                            size: iconSize),
                                        label: Text(
                                          'Down',
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: padding,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Bouton UP
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _sendCommand(device, DeviceAction.up),
                                        icon: Icon(Icons.arrow_upward,
                                            size: iconSize),
                                        label: Text(
                                          'Up',
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: padding,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
