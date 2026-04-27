<?php
/**
 * Endpoint: Get Progress - VERSION AMÉLIORÉE AVEC LOGS
 * GET /member/get_progress.php?project_id=1
 * 
 * Récupère l'historique des progrès d'un projet
 */

// Activer le rapport d'erreurs pour le débogage (à désactiver en production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Définir les en-têtes CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Gérer les requêtes OPTIONS pour CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Fonction pour envoyer une réponse d'erreur
function sendError($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'message' => $message
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Log de débogage
error_log("=== DÉBUT get_progress.php ===");
error_log("Méthode: " . $_SERVER['REQUEST_METHOD']);
error_log("GET params: " . print_r($_GET, true));

// Vérifier que c'est une requête GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    error_log("Erreur: Méthode non autorisée");
    sendError("Méthode non autorisée", 405);
}

// Vérifier que project_id est fourni et valide
if (!isset($_GET['project_id']) || empty($_GET['project_id'])) {
    error_log("Erreur: project_id manquant");
    sendError("L'ID du projet est requis");
}

$project_id = filter_var($_GET['project_id'], FILTER_VALIDATE_INT);
if ($project_id === false || $project_id <= 0) {
    error_log("Erreur: project_id invalide: " . $_GET['project_id']);
    sendError("L'ID du projet doit être un nombre valide");
}

error_log("Project ID validé: $project_id");

try {
    // Inclure les fichiers nécessaires
    require_once __DIR__ . '/../config/headers.php';
    require_once __DIR__ . '/../config/database.php';
    require_once __DIR__ . '/../models/Progress.php';
    require_once __DIR__ . '/../utils/response.php';

    error_log("Fichiers inclus avec succès");

    // Connexion DB
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception("Impossible de se connecter à la base de données");
    }
    error_log("Connexion DB réussie");

    // Instancier le modèle Progress
    $progress = new Progress($db);
    error_log("Modèle Progress instancié");

    // Récupérer les progrès du projet
    $stmt = $progress->getByProjectId($project_id);
    
    if (!$stmt) {
        throw new Exception("Erreur lors de l'exécution de la requête getByProjectId");
    }
    error_log("Requête exécutée avec succès");

    $progress_list = [];
    $count = 0;

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $count++;
        error_log("Rangée $count: " . print_r($row, true));
        
        $progress_list[] = [
            "id" => $row['progress_id'] ?? $row['id'] ?? null,
            "project_id" => $row['project_id'] ?? null,
            "member_id" => $row['member_id'] ?? null,
            "member_name" => $row['member_name'] ?? 'Membre inconnu',
            "member_photo" => $row['member_photo'] ?? null,
            "update_text" => $row['update_text'] ?? '',
            "date_added" => $row['date_added'] ?? null,
            "is_final" => (bool)($row['is_final'] ?? false)
        ];
    }

    error_log("Nombre de progrès récupérés: " . count($progress_list));

    // Envoyer la réponse
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Progrès récupérés avec succès',
        'data' => $progress_list
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // Logger l'erreur pour le débogage
    error_log("Erreur get_progress.php: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    // Envoyer une réponse d'erreur
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

error_log("=== FIN get_progress.php ===");
?>