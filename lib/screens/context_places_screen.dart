import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/context_place_strings.dart';
import '../models/context_place.dart';
import '../services/context_place_service.dart';
import '../services/location_context_service.dart';
import '../services/place_geocoding_service.dart';

class ContextPlacesScreen extends StatefulWidget {
  final AppLanguage language;
  final LocationContextService locationContextService;
  final PlaceGeocodingService placeGeocodingService;

  const ContextPlacesScreen({
    super.key,
    required this.language,
    this.locationContextService = const LocationContextService(),
    this.placeGeocodingService = const PlaceGeocodingService(),
  });

  @override
  State<ContextPlacesScreen> createState() => _ContextPlacesScreenState();
}

class _ContextPlacesScreenState extends State<ContextPlacesScreen>
    with WidgetsBindingObserver {
  List<ContextPlace> _places = [];
  bool _isLoading = true;
  bool _isChangingLocationContext = false;
  bool _locationContextEnabled = false;
  LocationContextStatus _locationStatus = LocationContextStatus.disabled;
  bool _isResolvingAddress = false;
  bool _isCheckingCurrentPlace = false;
  String? _currentPlaceMessage;

  ContextPlaceStrings get _strings => ContextPlaceStrings(widget.language);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPlaces();
    _loadLocationContextStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLocationContextStatus();
    }
  }

  Future<void> _loadPlaces() async {
    final places = await ContextPlaceService.loadPlaces();
    if (!mounted) return;
    setState(() {
      _places = places;
      _isLoading = false;
    });
  }

  Future<void> _loadLocationContextStatus() async {
    final enabled = await widget.locationContextService.isEnabled();
    final status = await widget.locationContextService.loadStatus();
    if (!mounted) return;
    setState(() {
      _locationContextEnabled = enabled;
      _locationStatus = status;
    });
  }

  Future<void> _setLocationContext(bool enabled) async {
    if (_isChangingLocationContext) return;

    if (!enabled) {
      await widget.locationContextService.disable();
      if (!mounted) return;
      setState(() {
        _locationContextEnabled = false;
        _locationStatus = LocationContextStatus.disabled;
      });
      return;
    }

    final consented = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_strings.consentTitle),
        content: Text(_strings.consentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_strings.continueLabel),
          ),
        ],
      ),
    );
    if (consented != true || !mounted) return;

    setState(() => _isChangingLocationContext = true);
    final status = await widget.locationContextService.enable();
    if (!mounted) return;
    setState(() {
      _isChangingLocationContext = false;
      _locationContextEnabled = status == LocationContextStatus.ready;
      _locationStatus = status;
    });
  }

  String? get _locationStatusMessage {
    return switch (_locationStatus) {
      LocationContextStatus.disabled => null,
      LocationContextStatus.ready => _strings.ready,
      LocationContextStatus.serviceDisabled => _strings.serviceDisabled,
      LocationContextStatus.permissionDenied => _strings.permissionDenied,
      LocationContextStatus.permissionDeniedForever =>
        _strings.permissionDeniedForever,
    };
  }

  bool get _canOpenLocationSettings {
    return _locationStatus == LocationContextStatus.serviceDisabled ||
        _locationStatus == LocationContextStatus.permissionDeniedForever;
  }

  Future<void> _addPlace() async {
    final place = await _showPlaceDialog();
    if (place == null || !mounted) return;

    setState(() => _isResolvingAddress = true);
    final resolved = await widget.placeGeocodingService.resolve(place);
    final updated = [..._places, resolved];
    await ContextPlaceService.savePlaces(updated);
    if (!mounted) return;
    setState(() {
      _places = updated;
      _isResolvingAddress = false;
      _currentPlaceMessage = null;
    });
  }

  Future<void> _editPlace(ContextPlace existingPlace) async {
    final place = await _showPlaceDialog(existingPlace: existingPlace);
    if (place == null || !mounted) return;

    setState(() => _isResolvingAddress = true);
    final addressChanged = place.address != existingPlace.address;
    final placeToResolve = addressChanged
        ? place.copyWith(clearCoordinates: true)
        : place;
    final resolved = await widget.placeGeocodingService.resolve(placeToResolve);
    final updated = _places
        .map((item) => item.id == existingPlace.id ? resolved : item)
        .toList();
    await ContextPlaceService.savePlaces(updated);
    if (!mounted) return;
    setState(() {
      _places = updated;
      _isResolvingAddress = false;
      _currentPlaceMessage = null;
    });
  }

  Future<ContextPlace?> _showPlaceDialog({ContextPlace? existingPlace}) async {
    final nameController = TextEditingController(text: existingPlace?.name);
    final addressController = TextEditingController(
      text: existingPlace?.address,
    );
    var selectedType = existingPlace?.type ?? ContextPlaceType.work;

    final place = await showDialog<ContextPlace>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingPlace == null ? _strings.add : _strings.edit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ContextPlaceType>(
                  initialValue: selectedType,
                  decoration: InputDecoration(labelText: _strings.type),
                  items: ContextPlaceType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_strings.typeName(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: _strings.name,
                    hintText: _strings.typeName(selectedType),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: _strings.address),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final address = addressController.text.trim();
                if (name.isEmpty || address.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(_strings.required)));
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  ContextPlace(
                    id:
                        existingPlace?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    type: selectedType,
                    name: name,
                    address: address,
                  ),
                );
              },
              child: Text(_strings.save),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    addressController.dispose();
    return place;
  }

  Future<void> _deletePlace(ContextPlace place) async {
    final removedIndex = _places.indexWhere((item) => item.id == place.id);
    if (removedIndex < 0) return;

    final updated = _places.where((item) => item.id != place.id).toList();
    await ContextPlaceService.savePlaces(updated);
    if (!mounted) return;
    setState(() => _places = updated);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_strings.deleted),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: _strings.undo,
          onPressed: () => _restorePlace(place, removedIndex),
        ),
      ),
    );
  }

  Future<void> _restorePlace(ContextPlace place, int index) async {
    if (_places.any((item) => item.id == place.id)) return;

    final restored = [..._places];
    final safeIndex = index.clamp(0, restored.length).toInt();
    restored.insert(safeIndex, place);
    await ContextPlaceService.savePlaces(restored);
    if (!mounted) return;
    setState(() => _places = restored);
  }

  Future<void> _checkCurrentPlace() async {
    if (_isCheckingCurrentPlace) return;
    setState(() {
      _isCheckingCurrentPlace = true;
      _currentPlaceMessage = null;
    });

    try {
      final place = await widget.locationContextService.detectCurrentPlace(
        _places,
      );
      if (!mounted) return;
      setState(() {
        _isCheckingCurrentPlace = false;
        _currentPlaceMessage = place == null
            ? _strings.notNearPlace
            : _strings.nearPlace(place.name);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingCurrentPlace = false;
        _currentPlaceMessage = _strings.locationCheckFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isResolvingAddress ? null : _addPlace,
        icon: _isResolvingAddress
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_location_alt_outlined),
        label: Text(_strings.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.privacy_tip_outlined),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_strings.explanation)),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          value: _locationContextEnabled,
                          onChanged: _isChangingLocationContext
                              ? null
                              : _setLocationContext,
                          secondary: _isChangingLocationContext
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location_outlined),
                          title: Text(_strings.contextTitle),
                          subtitle: Text(_strings.contextSubtitle),
                        ),
                        if (_locationStatusMessage != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(_locationStatusMessage!),
                          ),
                        if (_canOpenLocationSettings)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: TextButton.icon(
                              onPressed: () => widget.locationContextService
                                  .openRelevantSettings(_locationStatus),
                              icon: const Icon(Icons.settings_outlined),
                              label: Text(_strings.openSettings),
                            ),
                          ),
                        if (_locationStatus == LocationContextStatus.ready &&
                            _places.any((place) => place.hasCoordinates))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: FilledButton.tonalIcon(
                              onPressed: _isCheckingCurrentPlace
                                  ? null
                                  : _checkCurrentPlace,
                              icon: _isCheckingCurrentPlace
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.near_me_outlined),
                              label: Text(_strings.checkCurrentPlace),
                            ),
                          ),
                        if (_currentPlaceMessage != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(_currentPlaceMessage!),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_places.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(_strings.empty)),
                  )
                else
                  ..._places.map(
                    (place) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(place.name),
                        subtitle: Text(
                          '${_strings.typeName(place.type)}\n${place.address}\n'
                          '${place.hasCoordinates ? _strings.addressReady : _strings.addressNotResolved}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _editPlace(place),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () => _deletePlace(place),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
