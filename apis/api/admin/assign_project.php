<?php
// ... imports ...

// Récupérer les données JSON
$input = file_get_contents("php://input");
$data = json_decode($input);

// Validation
if (!isset($data->title) || empty(trim($data->title))) {
    Response::error("Le titre du projet est requis");
}
if (!isset($data->created_by) || empty($data->created_by)) {
    Response::error("L'admin créateur est requis");
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

// Instancier le modèle Project
$project = new Project($db);

// Assigner les données - CORRECTION: created_by au lieu de assigned_to
$project->title = trim($data->title);
$project->description = isset($data->description) ? trim($data->description) : null;
$project->created_by = $data->created_by;  // CORRECTION
$project->start_date = isset($data->start_date) ? $data->start_date : date('Y-m-d');
$project->end_date = isset($data->end_date) ? $data->end_date : null;
$project->status = isset($data->status) ? $data->status : 'pending';

// Créer le projet
if ($project->create()) {
    Response::success("Projet créé avec succès", [  // Message changé
        "project_id" => $project->project_id,  // CORRECTION
        "title" => $project->title,
        "created_by" => $project->created_by,  // CORRECTION
        "status" => $project->status
    ], 201);
} else {
    Response::error("Erreur lors de la création du projet", 500);
}
?>