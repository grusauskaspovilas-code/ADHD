import 'app_language.dart';
import '../models/context_place.dart';

class ContextPlaceStrings {
  final AppLanguage language;

  const ContextPlaceStrings(this.language);

  String get title => switch (language) {
    AppLanguage.lithuanian => 'Svarbios vietos',
    AppLanguage.german => 'Wichtige Orte',
    _ => 'Important places',
  };

  String get explanation => switch (language) {
    AppLanguage.lithuanian =>
      'Vietų pridėti nebūtina. Ateityje, tik gavusi atskirą tavo leidimą, programėlė galės suprasti, ar esi darbe ar kitoje svarbioje vietoje, ir tinkamiau pasiūlyti užduotis. Dabar adresai saugomi tik šiame įrenginyje, o buvimo vieta nestebima.',
    AppLanguage.german =>
      'Orte sind optional. Später kann die App nur mit deiner gesonderten Erlaubnis erkennen, ob du bei der Arbeit oder an einem anderen wichtigen Ort bist, und Aufgaben passender vorschlagen. Adressen werden derzeit nur auf diesem Gerät gespeichert; dein Standort wird nicht verfolgt.',
    _ =>
      'Places are optional. Later, only with your separate permission, the app can understand whether you are at work or another important place and suggest tasks more appropriately. Addresses are currently stored only on this device; your location is not tracked.',
  };

  String get contextTitle => switch (language) {
    AppLanguage.lithuanian => 'Vietos kontekstas',
    AppLanguage.german => 'Standortkontext',
    _ => 'Location context',
  };

  String get contextSubtitle => switch (language) {
    AppLanguage.lithuanian =>
      'Naudoti vietą tik tada, kai programėlė atidaryta.',
    AppLanguage.german =>
      'Standort nur verwenden, während die App geöffnet ist.',
    _ => 'Use location only while the app is open.',
  };

  String get consentTitle => switch (language) {
    AppLanguage.lithuanian => 'Įjungti vietos kontekstą?',
    AppLanguage.german => 'Standortkontext aktivieren?',
    _ => 'Enable location context?',
  };

  String get consentBody => switch (language) {
    AppLanguage.lithuanian =>
      'Programėlė vietą tikrins tik tada, kai ją naudoji. Ji negaus nuolatinio fono leidimo. Vietos kontekstą galėsi bet kada išjungti. Paspaudus „Tęsti“, telefonas parodys sistemos leidimo užklausą.',
    AppLanguage.german =>
      'Die App prüft deinen Standort nur, während du sie verwendest. Sie erhält keinen dauerhaften Hintergrundzugriff. Du kannst den Standortkontext jederzeit deaktivieren. Nach „Weiter“ zeigt das Gerät die Systemanfrage an.',
    _ =>
      'The app will check your location only while you use it. It will not receive permanent background access. You can disable location context at any time. After Continue, your device will show the system permission request.',
  };

  String get continueLabel => switch (language) {
    AppLanguage.lithuanian => 'Tęsti',
    AppLanguage.german => 'Weiter',
    _ => 'Continue',
  };

  String get ready => switch (language) {
    AppLanguage.lithuanian => 'Vietos kontekstas įjungtas.',
    AppLanguage.german => 'Standortkontext ist aktiviert.',
    _ => 'Location context is enabled.',
  };

  String get permissionDenied => switch (language) {
    AppLanguage.lithuanian => 'Vietos leidimas nesuteiktas.',
    AppLanguage.german => 'Standortberechtigung wurde nicht erteilt.',
    _ => 'Location permission was not granted.',
  };

  String get permissionDeniedForever => switch (language) {
    AppLanguage.lithuanian =>
      'Vietos leidimas užblokuotas. Jį galima pakeisti telefono nustatymuose.',
    AppLanguage.german =>
      'Die Standortberechtigung ist blockiert. Du kannst sie in den Geräteeinstellungen ändern.',
    _ =>
      'Location permission is blocked. You can change it in device settings.',
  };

  String get serviceDisabled => switch (language) {
    AppLanguage.lithuanian => 'Telefone išjungtos vietos nustatymo paslaugos.',
    AppLanguage.german => 'Die Ortungsdienste des Geräts sind deaktiviert.',
    _ => 'Location services are disabled on this device.',
  };

  String get openSettings => switch (language) {
    AppLanguage.lithuanian => 'Atidaryti nustatymus',
    AppLanguage.german => 'Einstellungen öffnen',
    _ => 'Open settings',
  };

  String get addressReady => switch (language) {
    AppLanguage.lithuanian => 'Adresas atpažintas',
    AppLanguage.german => 'Adresse erkannt',
    _ => 'Address recognized',
  };

  String get addressNotResolved => switch (language) {
    AppLanguage.lithuanian =>
      'Adreso nepavyko atpažinti. Patikrink ir išsaugok dar kartą.',
    AppLanguage.german =>
      'Die Adresse wurde nicht erkannt. Bitte prüfen und erneut speichern.',
    _ => 'Address was not recognized. Check it and save again.',
  };

  String get checkCurrentPlace => switch (language) {
    AppLanguage.lithuanian => 'Patikrinti, kur esu',
    AppLanguage.german => 'Aktuellen Ort prüfen',
    _ => 'Check where I am',
  };

  String nearPlace(String name) => switch (language) {
    AppLanguage.lithuanian => 'Dabar esi netoli: $name.',
    AppLanguage.german => 'Du bist gerade in der Nähe von: $name.',
    _ => 'You are currently near: $name.',
  };

  String get notNearPlace => switch (language) {
    AppLanguage.lithuanian =>
      'Dabar nesi netoli nė vienos atpažintos svarbios vietos.',
    AppLanguage.german =>
      'Du bist derzeit nicht in der Nähe eines erkannten wichtigen Ortes.',
    _ => 'You are not currently near any recognized important place.',
  };

  String get locationCheckFailed => switch (language) {
    AppLanguage.lithuanian => 'Dabartinės vietos patikrinti nepavyko.',
    AppLanguage.german => 'Der aktuelle Standort konnte nicht geprüft werden.',
    _ => 'Your current location could not be checked.',
  };

  String get empty => switch (language) {
    AppLanguage.lithuanian => 'Dar nepridėta nė viena vieta.',
    AppLanguage.german => 'Noch keine Orte hinzugefügt.',
    _ => 'No places added yet.',
  };

  String get add => switch (language) {
    AppLanguage.lithuanian => 'Pridėti vietą',
    AppLanguage.german => 'Ort hinzufügen',
    _ => 'Add place',
  };

  String get edit => switch (language) {
    AppLanguage.lithuanian => 'Redaguoti vietą',
    AppLanguage.german => 'Ort bearbeiten',
    _ => 'Edit place',
  };

  String get type => switch (language) {
    AppLanguage.lithuanian => 'Vietos tipas',
    AppLanguage.german => 'Ortstyp',
    _ => 'Place type',
  };

  String get name => switch (language) {
    AppLanguage.lithuanian => 'Pavadinimas',
    AppLanguage.german => 'Name',
    _ => 'Name',
  };

  String get address => switch (language) {
    AppLanguage.lithuanian => 'Adresas',
    AppLanguage.german => 'Adresse',
    _ => 'Address',
  };

  String get save => switch (language) {
    AppLanguage.lithuanian => 'Išsaugoti',
    AppLanguage.german => 'Speichern',
    _ => 'Save',
  };

  String get cancel => switch (language) {
    AppLanguage.lithuanian => 'Atšaukti',
    AppLanguage.german => 'Abbrechen',
    _ => 'Cancel',
  };

  String get required => switch (language) {
    AppLanguage.lithuanian => 'Įrašyk pavadinimą ir adresą.',
    AppLanguage.german => 'Bitte Name und Adresse eingeben.',
    _ => 'Enter a name and address.',
  };

  String get deleted => switch (language) {
    AppLanguage.lithuanian => 'Vieta pašalinta.',
    AppLanguage.german => 'Ort entfernt.',
    _ => 'Place removed.',
  };

  String get undo => switch (language) {
    AppLanguage.lithuanian => 'Atšaukti',
    AppLanguage.german => 'Rückgängig',
    _ => 'Undo',
  };

  String typeName(ContextPlaceType type) => switch ((language, type)) {
    (AppLanguage.lithuanian, ContextPlaceType.home) => 'Namai',
    (AppLanguage.lithuanian, ContextPlaceType.work) => 'Darbas',
    (AppLanguage.lithuanian, ContextPlaceType.school) => 'Mokykla',
    (AppLanguage.lithuanian, ContextPlaceType.childcare) =>
      'Darželis / būrelis',
    (AppLanguage.lithuanian, ContextPlaceType.other) => 'Kita',
    (AppLanguage.german, ContextPlaceType.home) => 'Zuhause',
    (AppLanguage.german, ContextPlaceType.work) => 'Arbeit',
    (AppLanguage.german, ContextPlaceType.school) => 'Schule',
    (AppLanguage.german, ContextPlaceType.childcare) => 'Kita / Aktivität',
    (AppLanguage.german, ContextPlaceType.other) => 'Andere',
    (_, ContextPlaceType.home) => 'Home',
    (_, ContextPlaceType.work) => 'Work',
    (_, ContextPlaceType.school) => 'School',
    (_, ContextPlaceType.childcare) => 'Childcare / activity',
    (_, ContextPlaceType.other) => 'Other',
  };
}
