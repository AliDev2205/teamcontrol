<?php
// api/admin/create_project_with_phases.php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Project.php';
require_once '../models/ProjectPhase.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

$input = file_get_contents("php://input");
$data = json_decode($input);

// Validation
if (!isset($data->title) || empty(trim($data->title))) {
    Response::error("Le titre du projet est requis");
}
if (!isset($data->created_by) || empty($data->created_by)) {
    Response::error("L'admin créateur est requis");
}

try {
    $database = new Database();
    $db = $database->getConnection();
    $db->beginTransaction();

    // 1. Créer le projet
    $project = new Project($db);
    $project->title = trim($data->title);
    $project->description = isset($data->description) ? trim($data->description) : null;
    $project->created_by = $data->created_by;
    $project->start_date = isset($data->start_date) ? $data->start_date : date('Y-m-d');
    $project->end_date = isset($data->end_date) ? $data->end_date : null;
    $project->status = 'pending';

    if (!$project->create()) {
        throw new Exception("Erreur lors de la création du projet");
    }

    $project_id = $project->project_id;
    $phases_created = [];

    // 2. Créer les phases si fournies
    if (isset($data->phases) && is_array($data->phases)) {
        $phase_model = new ProjectPhase($db);
        
        foreach ($data->phases as $index => $phase_data) {
            $phase_model->project_id = $project_id;
            $phase_model->title = trim($phase_data->title);
            $phase_model->description = isset($phase_data->description) ? trim($phase_data->description) : null;
            $phase_model->order_number = $index + 1;
            $phase_model->status = 'pending';
            
            if ($phase_model->create()) {
                $phases_created[] = [
                    'phase_id' => $phase_model->phase_id,
                    'title' => $phase_model->title,
                    'order_number' => $phase_model->order_number
                ];
            }
        }
    }

    $db->commit();

    Response::success("Projet créé avec phases", [
        "project_id" => $project_id,
        "title" => $project->title,
        "phases" => $phases_created
    ], 201);

} catch (Exception $e) {
    $db->rollBack();
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>