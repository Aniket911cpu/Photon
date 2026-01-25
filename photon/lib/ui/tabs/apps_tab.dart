import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/asset_picker_provider.dart';

class AppsTab extends StatefulWidget {
  const AppsTab({super.key});

  @override
  State<AppsTab> createState() => _AppsTabState();
}

class _AppsTabState extends State<AppsTab> {
  List<Application> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    // Get installed apps (including system apps if needed, usually just user apps)
    List<Application> apps = await FlutterDeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );
    
    if (mounted) {
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final picker = Provider.of<AssetPickerProvider>(context);

    return ListView.builder(
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index] as ApplicationWithIcon;
        // Verify it is ApplicationWithIcon since we requested icons
        final isSelected = picker.isSelected(app.apkFilePath);

        return ListTile(
          leading: Image.memory(app.icon, width: 40, height: 40),
          title: Text(app.appName),
          subtitle: Text(app.packageName),
          trailing: isSelected 
             ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
             : const Icon(Icons.circle_outlined),
          onTap: () => picker.toggleSelection(app.apkFilePath),
        );
      },
    );
  }
}
