<?php
// api/member/get_phases.php - VERSION AMÉLIORÉE
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

// Inclure les fichiers nécessaires
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/ProjectPhase.php';
require_once __DIR__ . '/../utils/response.php';

// Fonction pour envoyer une réponse d'erreur
function sendError($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'message' => $message
    ]);
    exit;
}

// Vérifier que c'est une requête GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Méthode non autorisée", 405);
}

// Vérifier que project_id est fourni et valide
if (!isset($_GET['project_id']) || empty($_GET['project_id'])) {
    sendError("L'ID du projet est requis");
}

$project_id = filter_var($_GET['project_id'], FILTER_VALIDATE_INT);
if ($project_id === false || $project_id <= 0) {
    sendError("L'ID du projet doit être un nombre valide");
}

try {
    $database = new Database();
    $db = $database->getConnection();

    // Vérifier que la connexion à la base de données fonctionne
    if (!$db) {
        throw new Exception("Impossible de se connecter à la base de données");
    }

    $phase = new ProjectPhase($db);
    
    // Vérifier que la méthode existe
    if (!method_exists($phase, 'getByProjectId')) {
        throw new Exception("Méthode getByProjectId non trouvée dans ProjectPhase");
    }
    
    $stmt = $phase->getByProjectId($project_id);
    
    if (!$stmt) {
        throw new Exception("Erreur lors de l'exécution de la requête");
    }
    
    $phases = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Log des phases récupérées
    error_log("Phases brutes récupérées: " . print_r($phases, true));

    // Formater la réponse de manière cohérente
    $formattedPhases = array_map(function($phase) {
        error_log("Formatage phase: " . print_r($phase, true));
        return [
            'phase_id' => $phase['phase_id'] ?? $phase['id'] ?? null,
            'project_id' => $phase['project_id'] ?? null,
            'title' => $phase['title'] ?? 'Sans titre',
            'description' => $phase['description'] ?? null,
            'order_number' => (int)($phase['order_number'] ?? $phase['orderNumber'] ?? 1),
            'start_date' => $phase['start_date'] ?? $phase['startDate'] ?? null,
            'end_date' => $phase['end_date'] ?? $phase['endDate'] ?? null,
            'is_completed' => (bool)($phase['is_completed'] ?? $phase['isCompleted'] ?? false),
            'status' => $phase['status'] ?? 'pending',
            'created_at' => $phase['created_at'] ?? $phase['createdAt'] ?? null
        ];
    }, $phases);

    error_log("Phases formatées: " . print_r($formattedPhases, true));

    // Envoyer la réponse
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Phases récupérées avec succès',
        'data' => $formattedPhases
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // Logger l'erreur pour le débogage
    error_log("Erreur get_phases.php: " . $e->getMessage());
    
    // Envoyer une réponse d'erreur
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>