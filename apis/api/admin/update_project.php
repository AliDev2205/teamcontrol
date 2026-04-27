<?php
// Désactiver la mise en cache
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Project.php';
require_once '../models/Notification.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

$input = file_get_contents("php://input");
$data = json_decode($input);

if ($data === null) {
    Response::error("Données JSON invalides");
}

if (!isset($data->project_id) || empty($data->project_id)) {
    Response::error("L'ID du projet est requis");
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $project = new Project($db);
    $project->project_id = intval($data->project_id);

    // Charger projet existant pour comparer et pour message
    $existing = $project->getById();
    if (!$existing) {
        Response::error("Projet introuvable", 404);
    }

    // Appliquer mises à jour optionnelles
    $project->title = property_exists($data, 'title') ? $data->title : $existing['title'];
    $project->description = property_exists($data, 'description') ? $data->description : $existing['description'];
    $project->start_date = property_exists($data, 'start_date') ? $data->start_date : $existing['start_date'];
    $project->end_date = property_exists($data, 'end_date') ? $data->end_date : $existing['end_date'];
    $project->status = property_exists($data, 'status') ? $data->status : $existing['status'];

    if ($project->update()) {
        // Notifier les membres assignés si le projet est assigné
        $assignedStmt = $project->getAssignedMembers($project->project_id);
        $assigned = $assignedStmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($assigned)) {
            $sender_id = isset($data->admin_id) ? intval($data->admin_id) : $existing['created_by'];
            foreach ($assigned as $row) {
                $notif = new Notification($db);
                $notif->receiver_id = intval($row['member_id']);
                $notif->sender_id = $sender_id;
                $notif->message = "Le projet '" . $project->title . "' a été mis à jour";
                $notif->type = 'project_updated';
                $notif->related_project_id = $project->project_id;
                $notif->related_phase_id = null;
                $notif->create();
            }
        }

        // Préparer la réponse avec plus de détails
        $responseData = [
            'project_id' => $project->project_id,
            'title' => $project->title,
            'description' => $project->description,
            'start_date' => $project->start_date,
            'end_date' => $project->end_date,
            'status' => $project->status,
            'updated_at' => date('Y-m-d H:i:s'), // Ajout d'un timestamp
            'timestamp' => time() // Ajout d'un timestamp Unix
        ];

        Response::success("Projet mis à jour avec succès", $responseData);
    } else {
        Response::error("Erreur lors de la mise à jour du projet", 500);
    }
} catch (Exception $e) {
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>



