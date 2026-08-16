import 'dart:io';
import 'package:dio/dio.dart';

class AppErrorHandler {
  /// Transforme une exception technique en message compréhensible pour l'utilisateur.
  static String getFriendlyMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Le serveur met trop de temps à répondre. Vérifiez votre connexion internet.";
        
        case DioExceptionType.connectionError:
          if (error.error is SocketException) {
            final se = error.error as SocketException;
            if (se.osError?.errorCode == 111 || se.message.contains("Connection refused")) {
              return "Impossible de contacter le serveur. Assurez-vous que le backend SEGMA est bien lancé.";
            }
          }
          return "Erreur de connexion au serveur. Vérifiez que vous êtes en ligne.";

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 413) {
            return "L'image est trop volumineuse pour être traitée par le serveur.";
          }
          if (statusCode == 404) {
            return "La ressource demandée est introuvable sur le serveur.";
          }
          if (statusCode == 500) {
            return "Le serveur a rencontré une erreur interne lors du traitement de l'image.";
          }
          return "Le serveur a renvoyé une erreur inhabituelle (Code $statusCode).";

        default:
          return "Un problème réseau est survenu. Veuillez réessayer plus tard.";
      }
    }

    if (error is FileSystemException) {
      if (error.message.contains("Permission denied")) {
        return "L'application n'a pas la permission d'accéder à ce fichier ou dossier.";
      }
      return "Erreur lors de la manipulation des fichiers sur votre disque.";
    }

    // Erreurs génériques basées sur le texte
    final msg = error.toString().toLowerCase();
    if (msg.contains("not found")) {
      return "Fichier ou dossier introuvable. Il a peut-être été déplacé ou supprimé.";
    }
    if (msg.contains("out of memory") || msg.contains("oom")) {
      return "Mémoire saturée. Essayez de fermer d'autres applications ou de réduire la taille de l'image.";
    }
    if (msg.contains("checkpoint") || msg.contains("model not loaded")) {
      return "Le modèle d'IA n'est pas encore prêt. Attendez quelques instants.";
    }
    if (msg.contains("invalid path") || msg.contains("no such file")) {
      return "Le chemin spécifié est invalide ou l'image a été déplacée.";
    }
    if (msg.contains("timeout")) {
      return "L'opération a pris trop de temps. Réessayez avec une image plus petite.";
    }

    return "Une erreur inattendue est survenue. Les détails techniques ont été enregistrés dans les logs.";
  }
}
