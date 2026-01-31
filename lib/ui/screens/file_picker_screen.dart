import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../../core/providers/asset_picker_provider.dart';
import '../../core/transfer/transfer_manager.dart';
import '../tabs/photo_video_tab.dart';
import '../tabs/apps_tab.dart';

class FilePickerScreen extends StatelessWidget {
  const FilePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssetPickerProvider(),
      child: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) {
            final picker = Provider.of<AssetPickerProvider>(context);
            return Scaffold(
              appBar: AppBar(
                title: const Text("Select Files"),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "Photos"),
                    Tab(text: "Videos"),
                    Tab(text: "Apps"),
                  ],
                ),
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        "${picker.totalSelected} Selected", 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  )
                ],
              ),
              body: TabBarView(
                children: const [
                   PhotoVideoTab(requestType: RequestType.image),
                   PhotoVideoTab(requestType: RequestType.video),
                   AppsTab(),
                ],
              ),
              floatingActionButton: picker.totalSelected > 0 
                ? FloatingActionButton.extended(
                    onPressed: () {
                      // Pass selected paths back or start transfer
                      // For MVP, we pop with results or initiate transfer directly
                      // But the prompt implies this IS the 'Xender' selection screen.
                      // Let's assume we navigate to 'Sender' screen with this list.
                      
                      // For now, assume this screen was pushed with expectation of result.
                      // Navigator.pop(context, picker.selectedPaths.toList());

                      // Or, if integrated into flow:
                      final paths = picker.selectedPaths.toList();
                      Provider.of<TransferManager>(context, listen: false)
                        .startTransfer(paths, '127.0.0.1'); // Still mock IP until QR part
                      
                      // Show finding receiver?
                      Navigator.pop(context); // Close picker
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Send"),
                  )
                : null,
            );
          }
        ),
      ),
    );
  }
}
