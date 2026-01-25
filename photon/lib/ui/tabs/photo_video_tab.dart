import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import '../../core/providers/asset_picker_provider.dart';

class PhotoVideoTab extends StatefulWidget {
  final RequestType requestType; // Image or Video
  const PhotoVideoTab({super.key, required this.requestType});

  @override
  State<PhotoVideoTab> createState() => _PhotoVideoTabState();
}

class _PhotoVideoTabState extends State<PhotoVideoTab> {
  List<AssetEntity> _assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Get albums (recent first)
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: widget.requestType,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

      if (albums.isNotEmpty) {
        // Load first 1000 items from 'Recent'
        List<AssetEntity> media = await albums[0].getAssetListRange(start: 0, end: 1000);
        if (mounted) {
          setState(() {
            _assets = media;
            _isLoading = false;
          });
        }
      } else {
         if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (_assets.isEmpty) {
      return const Center(child: Text("No Media Found"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _assets.length,
      itemBuilder: (ctx, index) {
        final asset = _assets[index];
        return _AssetThumbnail(asset: asset);
      },
    );
  }
}

class _AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;

  const _AssetThumbnail({required this.asset});

  @override
  Widget build(BuildContext context) {
    final picker = Provider.of<AssetPickerProvider>(context);
    
    return FutureBuilder<String?>(
      future: asset.file.then((f) => f?.path), // Need absolute path
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null) return Container(color: Colors.grey[900]);
        
        final isSelected = picker.isSelected(path);

        return GestureDetector(
          onTap: () => picker.toggleSelection(path),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetEntityImage(
                asset,
                isOriginal: false, // Thumbnail
                thumbnailSize: const ThumbnailSize.square(200),
                fit: BoxFit.cover,
              ),
              if (isSelected)
                Container(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  child: const Center(
                    child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
