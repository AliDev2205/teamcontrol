<?php
/**
 * Endpoint: Get Member Projects
 * GET /member/get_projects.php?member_id=2
 */
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Project.php';
require_once '../utils/response.php';

// Désactiver l'affichage des erreurs
error_reporting(0);
ini_set('display_errors', 0);

// Vérifier que c'est une requête GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error("Méthode non autorisée", 405);
}

// Vérifier que member_id est fourni et valide
if (!isset($_GET['member_id']) || empty($_GET['member_id'])) {
    Response::error("L'ID du membre est requis");
}

$member_id = filter_var($_GET['member_id'], FILTER_VALIDATE_INT);
if ($member_id === false || $member_id <= 0) {
    Response::error("L'ID du membre doit être un nombre valide");
}

try {
    // Connexion DB
    $database = new Database();
    $db = $database->getConnection();

    // Instancier le modèle Project
    $project = new Project($db);

    // Récupérer les projets du membre
    $stmt = $project->getByMemberId($member_id);
    
    if (!$stmt) {
        throw new Exception("Erreur lors de la récupération des projets");
    }
    
    $projects = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $projects[] = [
            "id" => $row['project_id'] ?? $row['id'],
            "title" => $row['title'],
            "description" => $row['description'] ?? null,
            "start_date" => $row['start_date'] ?? $row['startDate'] ?? null,
            "end_date" => $row['end_date'] ?? $row['endDate'] ?? null,
            "status" => $row['status'] ?? 'pending',
            "created_by" => $row['created_by'] ?? $row['createdBy'] ?? null,
            "created_at" => $row['created_at'] ?? $row['createdAt'] ?? null,
            "created_by_name" => $row['created_by_name'] ?? $row['createdByName'] ?? null
        ];
    }

    Response::success("Projets récupérés avec succès", $projects);

} catch (Exception $e) {
    error_log("Erreur get_projects.php: " . $e->getMessage());
    Response::error("Erreur lors de la récupération des projets: " . $e->getMessage(), 500);
}
?>