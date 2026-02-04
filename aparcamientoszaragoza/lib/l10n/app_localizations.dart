import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar Ajustes'**
  String get settingsTitle;

  /// No description provided for @preferencesSection.
  ///
  /// In es, this message translates to:
  /// **'PREFERENCIAS'**
  String get preferencesSection;

  /// No description provided for @languageItem.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageItem;

  /// No description provided for @themeItem.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeItem;

  /// No description provided for @notificationsSection.
  ///
  /// In es, this message translates to:
  /// **'NOTIFICACIONES'**
  String get notificationsSection;

  /// No description provided for @reservationAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas de Reserva'**
  String get reservationAlerts;

  /// No description provided for @offersPromotions.
  ///
  /// In es, this message translates to:
  /// **'Ofertas y Promociones'**
  String get offersPromotions;

  /// No description provided for @accountSection.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get accountSection;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get changePassword;

  /// No description provided for @paymentMethods.
  ///
  /// In es, this message translates to:
  /// **'Métodos de Pago'**
  String get paymentMethods;

  /// No description provided for @helpSupport.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y Soporte'**
  String get helpSupport;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightMode;

  /// No description provided for @welcomeTitle1.
  ///
  /// In es, this message translates to:
  /// **'Tu aparcamiento en tu distrito\n'**
  String get welcomeTitle1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In es, this message translates to:
  /// **', de forma simplificada.'**
  String get welcomeTitle2;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descubre una nueva forma de moverte por la ciudad. Encuentra, aparca y disfruta.'**
  String get welcomeSubtitle;

  /// No description provided for @featureFindTitle.
  ///
  /// In es, this message translates to:
  /// **'Encontrar'**
  String get featureFindTitle;

  /// No description provided for @featureFindSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Localiza plazas libres cerca de ti en tiempo real.'**
  String get featureFindSubtitle;

  /// No description provided for @featureRentTitle.
  ///
  /// In es, this message translates to:
  /// **'Alquilar'**
  String get featureRentTitle;

  /// No description provided for @featureRentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reserva tu espacio por horas o días al instante.'**
  String get featureRentSubtitle;

  /// No description provided for @featureManageTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get featureManageTitle;

  /// No description provided for @featureManageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Controla reservas y pagos desde tu móvil.'**
  String get featureManageSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'Empezar ahora'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginAction.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginAction;

  /// No description provided for @homeHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuentra tu plaza'**
  String get homeHeaderTitle;

  /// No description provided for @homeHeaderLocation.
  ///
  /// In es, this message translates to:
  /// **'Zaragoza, España'**
  String get homeHeaderLocation;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar en Zaragoza...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterMyGarages.
  ///
  /// In es, this message translates to:
  /// **'Mis Plazas'**
  String get filterMyGarages;

  /// No description provided for @filterPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get filterPrice;

  /// No description provided for @filterVehicle.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get filterVehicle;

  /// No description provided for @filterStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get filterStatus;

  /// No description provided for @filterFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritas'**
  String get filterFavorites;

  /// No description provided for @filterPriceAsc.
  ///
  /// In es, this message translates to:
  /// **' (Menor)'**
  String get filterPriceAsc;

  /// No description provided for @filterPriceDesc.
  ///
  /// In es, this message translates to:
  /// **' (Mayor)'**
  String get filterPriceDesc;

  /// No description provided for @filterVehicleMoto.
  ///
  /// In es, this message translates to:
  /// **' (Moto)'**
  String get filterVehicleMoto;

  /// No description provided for @filterVehicleSmallCar.
  ///
  /// In es, this message translates to:
  /// **' (Coche P.)'**
  String get filterVehicleSmallCar;

  /// No description provided for @filterVehicleLargeCar.
  ///
  /// In es, this message translates to:
  /// **' (Coche G.)'**
  String get filterVehicleLargeCar;

  /// No description provided for @filterVehicleVan.
  ///
  /// In es, this message translates to:
  /// **' (Furgoneta)'**
  String get filterVehicleVan;

  /// No description provided for @filterStatusFree.
  ///
  /// In es, this message translates to:
  /// **' (Libre)'**
  String get filterStatusFree;

  /// No description provided for @filterStatusOccupied.
  ///
  /// In es, this message translates to:
  /// **' (Ocupado)'**
  String get filterStatusOccupied;

  /// No description provided for @navSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get navSearch;

  /// No description provided for @navGarages.
  ///
  /// In es, this message translates to:
  /// **'Aparcamiento'**
  String get navGarages;

  /// No description provided for @navMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get navMap;

  /// No description provided for @navActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get navActivity;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @noGaragesFound.
  ///
  /// In es, this message translates to:
  /// **'No se han encontrado plazas'**
  String get noGaragesFound;

  /// No description provided for @noMyGarages.
  ///
  /// In es, this message translates to:
  /// **'No tienes plazas registradas todavía'**
  String get noMyGarages;

  /// No description provided for @noFavorites.
  ///
  /// In es, this message translates to:
  /// **'No tienes favoritas'**
  String get noFavorites;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get loginWelcomeTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu aparcamiento de tu comunidad.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'EMAIL'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'usuario@email.es'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'CONTRASEÑA'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// No description provided for @continueWith.
  ///
  /// In es, this message translates to:
  /// **'O CONTINÚA CON'**
  String get continueWith;

  /// No description provided for @googleLogin.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get googleLogin;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes una cuenta? '**
  String get noAccount;

  /// No description provided for @registerAction.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get registerAction;

  /// No description provided for @errorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error...'**
  String get errorTitle;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'¡Error al hacer login!'**
  String get loginError;

  /// No description provided for @loginSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Login Correcto!'**
  String get loginSuccess;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingrese email'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Email inválido'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingrese contraseña'**
  String get passwordRequired;

  /// No description provided for @tutorialSkip.
  ///
  /// In es, this message translates to:
  /// **'SALTAR'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tutorialNext;

  /// No description provided for @tutorialFinish.
  ///
  /// In es, this message translates to:
  /// **'Empezar ahora'**
  String get tutorialFinish;

  /// No description provided for @tutorialTitle1.
  ///
  /// In es, this message translates to:
  /// **'Encuentra tu plaza'**
  String get tutorialTitle1;

  /// No description provided for @tutorialHighlight1.
  ///
  /// In es, this message translates to:
  /// **'ideal al instante'**
  String get tutorialHighlight1;

  /// No description provided for @tutorialSubtitle1.
  ///
  /// In es, this message translates to:
  /// **'Explora el mapa de Zaragoza y localiza plazas libres cerca de ti en tiempo real. Sin vueltas innecesarias.'**
  String get tutorialSubtitle1;

  /// No description provided for @tutorialTitle2.
  ///
  /// In es, this message translates to:
  /// **'Alquila tu plaza'**
  String get tutorialTitle2;

  /// No description provided for @tutorialHighlight2.
  ///
  /// In es, this message translates to:
  /// **'sin complicaciones'**
  String get tutorialHighlight2;

  /// No description provided for @tutorialSubtitle2.
  ///
  /// In es, this message translates to:
  /// **'Reserva aparcamiento por horas o días. Acceso garantizado y gestión completa desde tu móvil.'**
  String get tutorialSubtitle2;

  /// No description provided for @tutorialTitle3.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus reservas'**
  String get tutorialTitle3;

  /// No description provided for @tutorialSubtitle3.
  ///
  /// In es, this message translates to:
  /// **'Controla tus pagos, revisa tu historial y modifica tus reservas de aparcamiento en Zaragoza al instante.'**
  String get tutorialSubtitle3;

  /// No description provided for @registerGarageTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de Plaza'**
  String get registerGarageTitle;

  /// No description provided for @modifyGarageTitle.
  ///
  /// In es, this message translates to:
  /// **'Modificar Plaza'**
  String get modifyGarageTitle;

  /// No description provided for @multimediaSection.
  ///
  /// In es, this message translates to:
  /// **'MULTIMEDIA'**
  String get multimediaSection;

  /// No description provided for @locationSection.
  ///
  /// In es, this message translates to:
  /// **'UBICACIÓN'**
  String get locationSection;

  /// No description provided for @addressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección Exacta'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In es, this message translates to:
  /// **'Calle Zaragoza, 12, Bajo A'**
  String get addressHint;

  /// No description provided for @comunidadLabel.
  ///
  /// In es, this message translates to:
  /// **'Comunidad (Seleccionar)'**
  String get comunidadLabel;

  /// No description provided for @comunidadHint.
  ///
  /// In es, this message translates to:
  /// **'Aragón'**
  String get comunidadHint;

  /// No description provided for @provinciaLabel.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get provinciaLabel;

  /// No description provided for @provinciaHint.
  ///
  /// In es, this message translates to:
  /// **'Zaragoza'**
  String get provinciaHint;

  /// No description provided for @municipioLabel.
  ///
  /// In es, this message translates to:
  /// **'Municipio'**
  String get municipioLabel;

  /// No description provided for @municipioHint.
  ///
  /// In es, this message translates to:
  /// **'Zaragoza'**
  String get municipioHint;

  /// No description provided for @cpLabel.
  ///
  /// In es, this message translates to:
  /// **'Código Postal'**
  String get cpLabel;

  /// No description provided for @getGps.
  ///
  /// In es, this message translates to:
  /// **'Obtener GPS'**
  String get getGps;

  /// No description provided for @measuresSection.
  ///
  /// In es, this message translates to:
  /// **'MEDIDAS Y NIVEL'**
  String get measuresSection;

  /// No description provided for @lengthLabel.
  ///
  /// In es, this message translates to:
  /// **'Largo'**
  String get lengthLabel;

  /// No description provided for @widthLabel.
  ///
  /// In es, this message translates to:
  /// **'Ancho'**
  String get widthLabel;

  /// No description provided for @floorLabel.
  ///
  /// In es, this message translates to:
  /// **'Planta'**
  String get floorLabel;

  /// No description provided for @vehicleTypeSection.
  ///
  /// In es, this message translates to:
  /// **'TIPO DE VEHÍCULO'**
  String get vehicleTypeSection;

  /// No description provided for @coveredLabel.
  ///
  /// In es, this message translates to:
  /// **'Plaza Cubierta'**
  String get coveredLabel;

  /// No description provided for @coveredSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Protegida de la intemperie?'**
  String get coveredSubtitle;

  /// No description provided for @conditionsSection.
  ///
  /// In es, this message translates to:
  /// **'CONDICIONES'**
  String get conditionsSection;

  /// No description provided for @specialRentLabel.
  ///
  /// In es, this message translates to:
  /// **'Alquiler especial'**
  String get specialRentLabel;

  /// No description provided for @specialRentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Servicios adicionales incluidos'**
  String get specialRentSubtitle;

  /// No description provided for @priceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio Mensual'**
  String get priceLabel;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrar Plaza'**
  String get registerButton;

  /// No description provided for @modifyButton.
  ///
  /// In es, this message translates to:
  /// **'Modificar Plaza'**
  String get modifyButton;

  /// No description provided for @missingFieldTitle.
  ///
  /// In es, this message translates to:
  /// **'Campo faltante'**
  String get missingFieldTitle;

  /// No description provided for @missingFieldMessage.
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa el campo: {field}'**
  String missingFieldMessage(Object field);

  /// No description provided for @successRegister.
  ///
  /// In es, this message translates to:
  /// **'Plaza registrada con éxito'**
  String get successRegister;

  /// No description provided for @successModify.
  ///
  /// In es, this message translates to:
  /// **'Plaza modificada con éxito'**
  String get successModify;

  /// No description provided for @exploreImages.
  ///
  /// In es, this message translates to:
  /// **'Explorar Imágenes del Dispositivo'**
  String get exploreImages;

  /// No description provided for @photoDetailHint.
  ///
  /// In es, this message translates to:
  /// **'Añade fotos detalladas para mejorar el alquiler'**
  String get photoDetailHint;

  /// No description provided for @photoField.
  ///
  /// In es, this message translates to:
  /// **'Fotografía de la plaza'**
  String get photoField;

  /// No description provided for @gpsField.
  ///
  /// In es, this message translates to:
  /// **'Ubicación GPS (pulsar Obtener GPS)'**
  String get gpsField;

  /// No description provided for @specialAlquiler.
  ///
  /// In es, this message translates to:
  /// **'Alquiler Especial'**
  String get specialAlquiler;

  /// No description provided for @covered.
  ///
  /// In es, this message translates to:
  /// **'Cubierta'**
  String get covered;

  /// No description provided for @atMeters.
  ///
  /// In es, this message translates to:
  /// **'{value} m'**
  String atMeters(Object value);

  /// No description provided for @floor.
  ///
  /// In es, this message translates to:
  /// **'Planta {value}'**
  String floor(Object value);

  /// No description provided for @vehicleMoto.
  ///
  /// In es, this message translates to:
  /// **'Moto'**
  String get vehicleMoto;

  /// No description provided for @vehicleSmallCar.
  ///
  /// In es, this message translates to:
  /// **'Coche P.'**
  String get vehicleSmallCar;

  /// No description provided for @vehicleLargeCar.
  ///
  /// In es, this message translates to:
  /// **'Coche G.'**
  String get vehicleLargeCar;

  /// No description provided for @vehicleVan.
  ///
  /// In es, this message translates to:
  /// **'Furgoneta'**
  String get vehicleVan;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro'**
  String get registerTitle;

  /// No description provided for @stepXofY.
  ///
  /// In es, this message translates to:
  /// **'PASO {current} DE {total}'**
  String stepXofY(Object current, Object total);

  /// No description provided for @finishAction.
  ///
  /// In es, this message translates to:
  /// **'FINALIZAR'**
  String get finishAction;

  /// No description provided for @personalDataTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get personalDataTitle;

  /// No description provided for @personalDataSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comencemos con tu información básica para crear tu perfil en Z-Parking.'**
  String get personalDataSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. María García'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce tu nombre'**
  String get fullNameRequired;

  /// No description provided for @emailHintRegister.
  ///
  /// In es, this message translates to:
  /// **'usuario@ejemplo.com'**
  String get emailHintRegister;

  /// No description provided for @emailRequiredRegister.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce tu email'**
  String get emailRequiredRegister;

  /// No description provided for @emailInvalidRegister.
  ///
  /// In es, this message translates to:
  /// **'Email no válido'**
  String get emailInvalidRegister;

  /// No description provided for @passwordStepTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu contraseña'**
  String get passwordStepTitle;

  /// No description provided for @passwordStepSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Asegura tu cuenta. La contraseña debe tener al menos 8 caracteres para garantizar la seguridad.'**
  String get passwordStepSubtitle;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get confirmPasswordHint;

  /// No description provided for @passwordRequiredRegister.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce una contraseña'**
  String get passwordRequiredRegister;

  /// No description provided for @passwordMinChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get passwordMinChars;

  /// No description provided for @passwordNumbers.
  ///
  /// In es, this message translates to:
  /// **'Debe contener al menos un número'**
  String get passwordNumbers;

  /// No description provided for @passwordNoSpaces.
  ///
  /// In es, this message translates to:
  /// **'No puede contener espacios'**
  String get passwordNoSpaces;

  /// No description provided for @passwordsMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsMismatch;

  /// No description provided for @passwordSecurityWarning.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no cumple con todos los requisitos de seguridad.'**
  String get passwordSecurityWarning;

  /// No description provided for @facialCaptureTitle.
  ///
  /// In es, this message translates to:
  /// **'Captura facial'**
  String get facialCaptureTitle;

  /// No description provided for @facialCaptureSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para verificar tu identidad y asegurar tu cuenta, necesitamos escanear tu rostro.'**
  String get facialCaptureSubtitle;

  /// No description provided for @photoGoodHint.
  ///
  /// In es, this message translates to:
  /// **'¿Se ve bien la foto?'**
  String get photoGoodHint;

  /// No description provided for @faceInFrameHint.
  ///
  /// In es, this message translates to:
  /// **'Coloca tu rostro en el marco'**
  String get faceInFrameHint;

  /// No description provided for @clearPhotoHint.
  ///
  /// In es, this message translates to:
  /// **'Asegúrate de que sea clara y nítida'**
  String get clearPhotoHint;

  /// No description provided for @goodLightingHint.
  ///
  /// In es, this message translates to:
  /// **'Asegúrate de tener buena iluminación'**
  String get goodLightingHint;

  /// No description provided for @retakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Repetir foto'**
  String get retakePhoto;

  /// No description provided for @skipForNow.
  ///
  /// In es, this message translates to:
  /// **'Saltar por ahora'**
  String get skipForNow;

  /// No description provided for @cameraError.
  ///
  /// In es, this message translates to:
  /// **'Error al capturar la foto: {error}'**
  String cameraError(Object error);

  /// No description provided for @termsTitle.
  ///
  /// In es, this message translates to:
  /// **'Términos y Privacidad'**
  String get termsTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Por favor, revisa y acepta nuestros términos legales para completar la creación de tu cuenta en Z-Parking.'**
  String get termsSubtitle;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto los '**
  String get acceptTermsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get termsOfService;

  /// No description provided for @andThe.
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get andThe;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// No description provided for @acceptTermsSuffix.
  ///
  /// In es, this message translates to:
  /// **', incluyendo el uso de cookies para mejorar la experiencia.'**
  String get acceptTermsSuffix;

  /// No description provided for @marketingConsent.
  ///
  /// In es, this message translates to:
  /// **'(Opcional) Me gustaría recibir novedades, descuentos en aparcamientos y actualizaciones de Z-Parking.'**
  String get marketingConsent;

  /// No description provided for @termsRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get termsRequired;

  /// No description provided for @registerActionStep.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerActionStep;

  /// No description provided for @continueAction.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// No description provided for @securityRequirements.
  ///
  /// In es, this message translates to:
  /// **'REQUISITOS DE SEGURIDAD'**
  String get securityRequirements;

  /// No description provided for @min8Chars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get min8Chars;

  /// No description provided for @atLeastOneNumber.
  ///
  /// In es, this message translates to:
  /// **'Al menos un número'**
  String get atLeastOneNumber;

  /// No description provided for @noSpacesAllowed.
  ///
  /// In es, this message translates to:
  /// **'Sin espacios vacíos'**
  String get noSpacesAllowed;

  /// No description provided for @passwordsMustMatch.
  ///
  /// In es, this message translates to:
  /// **'Contraseñas coinciden'**
  String get passwordsMustMatch;

  /// No description provided for @scanFaceAction.
  ///
  /// In es, this message translates to:
  /// **'Escanear rostro'**
  String get scanFaceAction;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitleLogged.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu correo electrónico para recibir las instrucciones de restablecimiento de contraseña.'**
  String get forgotPasswordSubtitleLogged;

  /// No description provided for @forgotPasswordSubtitleNotLogged.
  ///
  /// In es, this message translates to:
  /// **'Introduce el correo electrónico asociado a tu cuenta de Parking Zaragoza y te enviaremos las instrucciones para restablecerla.'**
  String get forgotPasswordSubtitleNotLogged;

  /// No description provided for @emailHintForget.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get emailHintForget;

  /// No description provided for @sendRecoveryLink.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace de recuperación'**
  String get sendRecoveryLink;

  /// No description provided for @emailSentTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Correo enviado!'**
  String get emailSentTitle;

  /// No description provided for @emailSentMessage.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado las instrucciones para restablecer tu contraseña a tu correo electrónico. Por favor, revisa tu bandeja de entrada.'**
  String get emailSentMessage;

  /// No description provided for @understoodAction.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understoodAction;

  /// No description provided for @errorSendingEmail.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el correo de recuperación'**
  String get errorSendingEmail;

  /// No description provided for @needMoreHelp.
  ///
  /// In es, this message translates to:
  /// **'¿Necesitas más ayuda? '**
  String get needMoreHelp;

  /// No description provided for @contactSupport.
  ///
  /// In es, this message translates to:
  /// **'Contactar soporte'**
  String get contactSupport;

  /// No description provided for @ownerBanner.
  ///
  /// In es, this message translates to:
  /// **'ERES EL PROPIETARIO DE ESTA PLAZA'**
  String get ownerBanner;

  /// No description provided for @availableNow.
  ///
  /// In es, this message translates to:
  /// **'¡Plaza disponible ahora mismo!'**
  String get availableNow;

  /// No description provided for @notAvailable.
  ///
  /// In es, this message translates to:
  /// **'Plaza ocupada actualmente'**
  String get notAvailable;

  /// No description provided for @descriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descriptionTitle;

  /// No description provided for @garageDescription.
  ///
  /// In es, this message translates to:
  /// **'Plaza de aparcamiento situada en {address}. Dimensiones de {length}m x {width}m, ubicada en la planta {floor}. {vehicleInfo}'**
  String garageDescription(Object address, Object floor, Object length,
      Object vehicleInfo, Object width);

  /// No description provided for @suitableForMotos.
  ///
  /// In es, this message translates to:
  /// **'Apta para motos.'**
  String get suitableForMotos;

  /// No description provided for @suitableForCars.
  ///
  /// In es, this message translates to:
  /// **'Ideal para coches.'**
  String get suitableForCars;

  /// No description provided for @schedulesAction.
  ///
  /// In es, this message translates to:
  /// **'HORARIOS'**
  String get schedulesAction;

  /// No description provided for @rulesAction.
  ///
  /// In es, this message translates to:
  /// **'NORMAS'**
  String get rulesAction;

  /// No description provided for @locationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get locationTitle;

  /// No description provided for @openInMapAction.
  ///
  /// In es, this message translates to:
  /// **'Abrir en Mapa'**
  String get openInMapAction;

  /// No description provided for @viewCommentsAction.
  ///
  /// In es, this message translates to:
  /// **'Ver Comentarios'**
  String get viewCommentsAction;

  /// No description provided for @rentNowAction.
  ///
  /// In es, this message translates to:
  /// **'Alquilar ahora'**
  String get rentNowAction;

  /// No description provided for @notAvailableAction.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get notAvailableAction;

  /// No description provided for @vigilada.
  ///
  /// In es, this message translates to:
  /// **'Vigilada'**
  String get vigilada;

  /// No description provided for @accesible.
  ///
  /// In es, this message translates to:
  /// **'Accesible'**
  String get accesible;

  /// No description provided for @pricePerDay.
  ///
  /// In es, this message translates to:
  /// **'{price} € / día'**
  String pricePerDay(Object price);

  /// No description provided for @pricePerHour.
  ///
  /// In es, this message translates to:
  /// **'{price} €/h'**
  String pricePerHour(Object price);

  /// No description provided for @spainIndicator.
  ///
  /// In es, this message translates to:
  /// **'{province}, España'**
  String spainIndicator(Object province);

  /// No description provided for @rentConfirmationTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmación de Alquiler'**
  String get rentConfirmationTitle;

  /// No description provided for @garageSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de la Plaza'**
  String get garageSummaryTitle;

  /// No description provided for @verifiedLabel.
  ///
  /// In es, this message translates to:
  /// **'Verificada'**
  String get verifiedLabel;

  /// No description provided for @rentalPeriodTitle.
  ///
  /// In es, this message translates to:
  /// **'Periodo de Alquiler'**
  String get rentalPeriodTitle;

  /// No description provided for @paymentBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Desglose de Pago'**
  String get paymentBreakdownTitle;

  /// No description provided for @totalToPay.
  ///
  /// In es, this message translates to:
  /// **'Total a pagar'**
  String get totalToPay;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In es, this message translates to:
  /// **'Método de Pago'**
  String get paymentMethodTitle;

  /// No description provided for @changeAction.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get changeAction;

  /// No description provided for @baseRateLabel.
  ///
  /// In es, this message translates to:
  /// **'Tarifa base ({hours}h x {price}€)'**
  String baseRateLabel(Object hours, Object price);

  /// No description provided for @managementFeesLabel.
  ///
  /// In es, this message translates to:
  /// **'Gastos de gestión'**
  String get managementFeesLabel;

  /// No description provided for @ivaLabel.
  ///
  /// In es, this message translates to:
  /// **'IVA (21%)'**
  String get ivaLabel;

  /// No description provided for @monthlyAutoRenewal.
  ///
  /// In es, this message translates to:
  /// **'Mensual - Renovación automática'**
  String get monthlyAutoRenewal;

  /// No description provided for @selectDatesHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona fechas'**
  String get selectDatesHint;

  /// No description provided for @daysSelected.
  ///
  /// In es, this message translates to:
  /// **'{count} días seleccionados'**
  String daysSelected(Object count);

  /// No description provided for @longTermContract.
  ///
  /// In es, this message translates to:
  /// **'Contrato de larga duración'**
  String get longTermContract;

  /// No description provided for @totalDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración total: {hours} horas'**
  String totalDuration(Object hours);

  /// No description provided for @visaLabel.
  ///
  /// In es, this message translates to:
  /// **'Visa terminada en {digits}'**
  String visaLabel(Object digits);

  /// No description provided for @expiresLabel.
  ///
  /// In es, this message translates to:
  /// **'Expira {date}'**
  String expiresLabel(Object date);

  /// No description provided for @legalPrefix.
  ///
  /// In es, this message translates to:
  /// **'Al confirmar el pago, aceptas nuestros '**
  String get legalPrefix;

  /// No description provided for @cancellationPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Cancelación'**
  String get cancellationPolicy;

  /// No description provided for @confirmPaymentAction.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Pago • {total} €'**
  String confirmPaymentAction(Object total);

  /// No description provided for @rentSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Alquiler realizado con éxito!'**
  String get rentSuccess;

  /// No description provided for @noRecentActivity.
  ///
  /// In es, this message translates to:
  /// **'No hay actividad reciente'**
  String get noRecentActivity;

  /// No description provided for @todayGroup.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get todayGroup;

  /// No description provided for @last7DaysGroup.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 Días'**
  String get last7DaysGroup;

  /// No description provided for @previousMonthGroup.
  ///
  /// In es, this message translates to:
  /// **'Mes Anterior'**
  String get previousMonthGroup;

  /// No description provided for @timelineTitle.
  ///
  /// In es, this message translates to:
  /// **'Timeline de Actividad del...'**
  String get timelineTitle;

  /// No description provided for @activityLabel.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get activityLabel;

  /// No description provided for @spainIndicatorMeta.
  ///
  /// In es, this message translates to:
  /// **'Zaragoza, España'**
  String get spainIndicatorMeta;

  /// No description provided for @userNameLabel.
  ///
  /// In es, this message translates to:
  /// **'displayName: {name}, email: {email}'**
  String userNameLabel(Object email, Object name);

  /// No description provided for @reviewsTitle.
  ///
  /// In es, this message translates to:
  /// **'Valoraciones'**
  String get reviewsTitle;

  /// No description provided for @writeCommentAction.
  ///
  /// In es, this message translates to:
  /// **'Escribir un comentario'**
  String get writeCommentAction;

  /// No description provided for @recentCommentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Comentarios recientes'**
  String get recentCommentsTitle;

  /// No description provided for @filterAction.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filterAction;

  /// No description provided for @basedOnReviews.
  ///
  /// In es, this message translates to:
  /// **'Basado en {count} reseñas'**
  String basedOnReviews(Object count);

  /// No description provided for @noReviewsYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay reseñas'**
  String get noReviewsYet;

  /// No description provided for @acceptAction.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get acceptAction;

  /// No description provided for @infoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get infoTitle;

  /// No description provided for @anonymousUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get anonymousUser;

  /// No description provided for @addCommentTitle.
  ///
  /// In es, this message translates to:
  /// **'VALORACIÓN'**
  String get addCommentTitle;

  /// No description provided for @sendReviewAction.
  ///
  /// In es, this message translates to:
  /// **'Enviar Reseña'**
  String get sendReviewAction;

  /// No description provided for @skipAction.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skipAction;

  /// No description provided for @captureExperience.
  ///
  /// In es, this message translates to:
  /// **'Captura tu experiencia'**
  String get captureExperience;

  /// No description provided for @photoTip.
  ///
  /// In es, this message translates to:
  /// **'Sube una foto real para ayudar a otros conductores'**
  String get photoTip;

  /// No description provided for @selectPhotoAction.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Foto'**
  String get selectPhotoAction;

  /// No description provided for @tapToRate.
  ///
  /// In es, this message translates to:
  /// **'Pulsa para valorar'**
  String get tapToRate;

  /// No description provided for @highlightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Destacados'**
  String get highlightsTitle;

  /// No description provided for @yourCommentTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu comentario'**
  String get yourCommentTitle;

  /// No description provided for @commentHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos tu experiencia... ¿Fue fácil encontrar la plaza?'**
  String get commentHint;

  /// No description provided for @tagClean.
  ///
  /// In es, this message translates to:
  /// **'Limpio'**
  String get tagClean;

  /// No description provided for @tagSafe.
  ///
  /// In es, this message translates to:
  /// **'Seguro'**
  String get tagSafe;

  /// No description provided for @tagEasyAccess.
  ///
  /// In es, this message translates to:
  /// **'Fácil acceso'**
  String get tagEasyAccess;

  /// No description provided for @tagCentral.
  ///
  /// In es, this message translates to:
  /// **'Céntrico'**
  String get tagCentral;

  /// No description provided for @tagSpacious.
  ///
  /// In es, this message translates to:
  /// **'Espacioso'**
  String get tagSpacious;

  /// No description provided for @selectRatingError.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona una puntuación'**
  String get selectRatingError;

  /// No description provided for @loadPlazaError.
  ///
  /// In es, this message translates to:
  /// **'Error: No se pudo cargar la plaza'**
  String get loadPlazaError;

  /// No description provided for @incidentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get incidentsTitle;

  /// No description provided for @incidentTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Incidencia'**
  String get incidentTypeLabel;

  /// No description provided for @selectLocationTypeRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona el tipo de ubicación'**
  String get selectLocationTypeRequired;

  /// No description provided for @incidentImageUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL de la imagen de la incidencia'**
  String get incidentImageUrlLabel;

  /// No description provided for @obtainingLocation.
  ///
  /// In es, this message translates to:
  /// **'Obteniendo ubicación...'**
  String get obtainingLocation;

  /// No description provided for @reloadLocationAction.
  ///
  /// In es, this message translates to:
  /// **'Recargar Ubicación'**
  String get reloadLocationAction;

  /// No description provided for @sendIncidentAction.
  ///
  /// In es, this message translates to:
  /// **'Enviar incidencia'**
  String get sendIncidentAction;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In es, this message translates to:
  /// **'Los servicios de ubicación están desactivados.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de ubicación fueron denegados.'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @latLongIndicator.
  ///
  /// In es, this message translates to:
  /// **'Latitud: {lat}, Longitud: {long}'**
  String latLongIndicator(Object lat, Object long);

  /// No description provided for @smsCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código SMS'**
  String get smsCodeTitle;

  /// No description provided for @pleaseEnterValidOTP.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un código OTP válido'**
  String get pleaseEnterValidOTP;

  /// No description provided for @verifyAction.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get verifyAction;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono'**
  String get phoneNumberLabel;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce el número de teléfono'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @phoneNumberInvalid.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono inválido'**
  String get phoneNumberInvalid;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String genericError(Object error);

  /// No description provided for @noData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get noData;

  /// No description provided for @viewMyProperties.
  ///
  /// In es, this message translates to:
  /// **'Ver Mis Propiedades'**
  String get viewMyProperties;

  /// No description provided for @manageRegisteredSpots.
  ///
  /// In es, this message translates to:
  /// **'Gestionar plazas registradas'**
  String get manageRegisteredSpots;

  /// No description provided for @checkHistory.
  ///
  /// In es, this message translates to:
  /// **'Consultar Historial'**
  String get checkHistory;

  /// No description provided for @historySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos usos y movimientos'**
  String get historySubtitle;

  /// No description provided for @favoriteSpots.
  ///
  /// In es, this message translates to:
  /// **'Plazas Favoritas'**
  String get favoriteSpots;

  /// No description provided for @favoriteSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Zonas de aparcamiento habituales'**
  String get favoriteSubtitle;

  /// No description provided for @userSpecial.
  ///
  /// In es, this message translates to:
  /// **'Usuario Especial'**
  String get userSpecial;

  /// No description provided for @userPro.
  ///
  /// In es, this message translates to:
  /// **'USUARIO PRO'**
  String get userPro;

  /// No description provided for @logoutAction.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logoutAction;

  /// No description provided for @myPropertiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Propiedades'**
  String get myPropertiesTitle;

  /// No description provided for @noFavoriteGarages.
  ///
  /// In es, this message translates to:
  /// **'No tienes plazas favoritas'**
  String get noFavoriteGarages;

  /// No description provided for @errorLoadingData.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los datos'**
  String get errorLoadingData;

  /// No description provided for @adTitle.
  ///
  /// In es, this message translates to:
  /// **'PUBLICIDAD'**
  String get adTitle;

  /// No description provided for @adMessage.
  ///
  /// In es, this message translates to:
  /// **'Este anuncio ayuda a mantener gratuita\nla aplicación de aparcamientos.'**
  String get adMessage;

  /// No description provided for @adDiscount.
  ///
  /// In es, this message translates to:
  /// **'¡Consigue un 20% de descuento\nen tu próxima reserva!'**
  String get adDiscount;

  /// No description provided for @closeIn.
  ///
  /// In es, this message translates to:
  /// **'Cerrar en {seconds}...'**
  String closeIn(Object seconds);

  /// No description provided for @closeAction.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get closeAction;

  /// No description provided for @bitTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Apuesta!'**
  String get bitTitle;

  /// No description provided for @createBitSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Genera tu apuesta'**
  String get createBitSubtitle;

  /// No description provided for @accountEthLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuenta Eth'**
  String get accountEthLabel;

  /// No description provided for @pleaseEnterEthAccount.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce la cuenta Eth'**
  String get pleaseEnterEthAccount;

  /// No description provided for @invalidEthAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta Eth no válida'**
  String get invalidEthAccount;

  /// No description provided for @bitAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Introduce el valor de la apuesta'**
  String get bitAmountLabel;

  /// No description provided for @pleaseEnterBitAmount.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce el valor de la apuesta'**
  String get pleaseEnterBitAmount;

  /// No description provided for @invalidBitAmount.
  ///
  /// In es, this message translates to:
  /// **'Valor de apuesta no válido'**
  String get invalidBitAmount;

  /// No description provided for @tagSafeCapitalized.
  ///
  /// In es, this message translates to:
  /// **'SEGURO'**
  String get tagSafeCapitalized;

  /// No description provided for @ownerLabel.
  ///
  /// In es, this message translates to:
  /// **'PROPIETARIO'**
  String get ownerLabel;

  /// No description provided for @privateLabel.
  ///
  /// In es, this message translates to:
  /// **'PRIVADA'**
  String get privateLabel;

  /// No description provided for @normalLabel.
  ///
  /// In es, this message translates to:
  /// **'NORMAL'**
  String get normalLabel;

  /// No description provided for @motoLabel.
  ///
  /// In es, this message translates to:
  /// **'Moto'**
  String get motoLabel;

  /// No description provided for @carLabel.
  ///
  /// In es, this message translates to:
  /// **'Coche'**
  String get carLabel;

  /// No description provided for @coveredChip.
  ///
  /// In es, this message translates to:
  /// **'Cubierta'**
  String get coveredChip;

  /// No description provided for @occupiedLabel.
  ///
  /// In es, this message translates to:
  /// **'OCUPADO'**
  String get occupiedLabel;

  /// No description provided for @availableLabel.
  ///
  /// In es, this message translates to:
  /// **'DISPONIBLE'**
  String get availableLabel;

  /// No description provided for @perHourSuffix.
  ///
  /// In es, this message translates to:
  /// **' /h'**
  String get perHourSuffix;

  /// No description provided for @reserveAction.
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get reserveAction;

  /// No description provided for @deleteSpotTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Plaza'**
  String get deleteSpotTitle;

  /// No description provided for @deleteSpotConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar esta plaza? Esta acción no se puede deshacer.'**
  String get deleteSpotConfirmation;

  /// No description provided for @cancelAction.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In es, this message translates to:
  /// **'ELIMINAR'**
  String get deleteAction;

  /// No description provided for @spotDeletedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Plaza eliminada correctamente'**
  String get spotDeletedSuccess;

  /// No description provided for @rentedLabel.
  ///
  /// In es, this message translates to:
  /// **'Alquilada'**
  String get rentedLabel;

  /// No description provided for @notRentedLabel.
  ///
  /// In es, this message translates to:
  /// **'NO Alquilada'**
  String get notRentedLabel;

  /// No description provided for @normalRentLabel.
  ///
  /// In es, this message translates to:
  /// **'Alquiler normal'**
  String get normalRentLabel;

  /// No description provided for @searchConfigTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración para la búsqueda'**
  String get searchConfigTitle;

  /// No description provided for @selectComunidadHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona comunidad autónoma'**
  String get selectComunidadHint;

  /// No description provided for @selectProvinciaHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona provincia'**
  String get selectProvinciaHint;

  /// No description provided for @selectMunicipioHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona Municipio'**
  String get selectMunicipioHint;

  /// No description provided for @selectPoblacionHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona Población'**
  String get selectPoblacionHint;

  /// No description provided for @selectNucleoHint.
  ///
  /// In es, this message translates to:
  /// **'Seleccione su núcleo'**
  String get selectNucleoHint;

  /// No description provided for @selectCpHint.
  ///
  /// In es, this message translates to:
  /// **'Seleccione su CP'**
  String get selectCpHint;

  /// No description provided for @saveChangesAction.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChangesAction;

  /// No description provided for @unknownAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección desconocida'**
  String get unknownAddress;

  /// No description provided for @getDirectionsAction.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get getDirectionsAction;

  /// No description provided for @reserveNowAction.
  ///
  /// In es, this message translates to:
  /// **'Reservar ahora'**
  String get reserveNowAction;

  /// No description provided for @perHourLabel.
  ///
  /// In es, this message translates to:
  /// **'/ hora'**
  String get perHourLabel;

  /// No description provided for @ofLabel.
  ///
  /// In es, this message translates to:
  /// **'de'**
  String get ofLabel;

  /// No description provided for @fullLabel.
  ///
  /// In es, this message translates to:
  /// **'Completo'**
  String get fullLabel;

  /// No description provided for @okAction.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo Requerido'**
  String get requiredField;

  /// No description provided for @configurationSaved.
  ///
  /// In es, this message translates to:
  /// **'Configuración guardada'**
  String get configurationSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
