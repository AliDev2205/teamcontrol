<?php
// api/admin/get_all_projects.php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Project.php';
require_once __DIR__ . '/../utils/response.php';

// Debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Vérifier que c'est une requête GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error("Méthode non autorisée", 405);
}

try {
    // Connexion DB
    $database = new Database();
    $db = $database->getConnection();

    // Instancier le modèle Project
    $project = new Project($db);

    // Récupérer tous les projets
    $stmt = $project->getAll();
    $projects = [];

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $projects[] = [
            "id" => $row['project_id'],  
            "title" => $row['title'],
            "description" => $row['description'],
            "created_by" => $row['created_by'],
            "created_by_name" => $row['created_by_name'],
            "start_date" => $row['start_date'],
            "end_date" => $row['end_date'],
            "status" => $row['status'],
            "created_at" => $row['created_at'],
            "updated_at" => $row['updated_at']
        ];
    }

    Response::success("Projets récupérés avec succès", $projects);

} catch (Exception $e) {
    Response::error("Erreur lors de la récupération des projets: " . $e->getMessage(), 500);
}
?>