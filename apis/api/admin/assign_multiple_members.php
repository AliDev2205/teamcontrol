<?php
/**
 * Endpoint: Assign Multiple Members to Project
 * POST /admin/assign_multiple_members.php
 */

// Inclure les fichiers avec chemins absolus
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/ProjectMember.php';
require_once __DIR__ . '/../models/Notification.php';
require_once __DIR__ . '/../models/Project.php';
require_once __DIR__ . '/../utils/response.php';

// Debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Vérifier que c'est une requête POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

// Récupérer les données JSON
$input = file_get_contents("php://input");
$data = json_decode($input);

// Debug
if ($data === null) {
    Response::error("Données JSON invalides. Reçu: " . $input);
}

// Validation des champs requis
if (!isset($data->project_id) || empty($data->project_id)) {
    Response::error("L'ID du projet est requis");
}

if (!isset($data->members) || !is_array($data->members) || empty($data->members)) {
    Response::error("La liste des membres est requise");
}

if (!isset($data->assigned_by) || empty($data->assigned_by)) {
    Response::error("L'admin assignateur est requis");
}

try {
    // Connexion DB
    $database = new Database();
    $db = $database->getConnection();
    
    // Démarrer une transaction
    $db->beginTransaction();

    // Récupérer le titre du projet pour les notifications
    $project = new Project($db);
    $project->project_id = $data->project_id;
    $project_data = $project->getById();
    
    if (!$project_data) {
        throw new Exception("Projet non trouvé");
    }
    
    $project_title = $project_data['title'];

    $assigned_members = [];
    $errors = [];
    
    // Assigner chaque membre
    foreach ($data->members as $member_id) {
        try {
            $projectMember = new ProjectMember($db);
            $projectMember->project_id = $data->project_id;
            $projectMember->member_id = $member_id;
            $projectMember->assigned_by = $data->assigned_by;
            $projectMember->is_active = true;
            
            if ($projectMember->create()) {
                $assigned_members[] = $member_id;
                
                // Créer une notification pour le membre assigné
                $notification = new Notification($db);
                $notification->receiver_id = $member_id;
                $notification->sender_id = $data->assigned_by;
                $notification->message = "Vous avez été assigné au projet \"$project_title\"";
                $notification->type = "assignment";
                $notification->related_project_id = $data->project_id;
                $notification->create();
                
            } else {
                $errors[] = "Erreur lors de l'assignation du membre ID: $member_id";
            }
        } catch (Exception $e) {
            $errors[] = "Erreur avec le membre ID $member_id: " . $e->getMessage();
        }
    }

    // NOUVEAU: Mettre à jour le statut du projet en "in_progress"
    $updateProjectQuery = "UPDATE projects SET status = 'in_progress', updated_at = NOW() WHERE project_id = :project_id";
    $updateProjectStmt = $db->prepare($updateProjectQuery);
    $updateProjectStmt->bindParam(":project_id", $data->project_id);
    
    if (!$updateProjectStmt->execute()) {
        $errors[] = "Erreur lors de la mise à jour du statut du projet";
    }

    // Si des erreurs sont survenues, rollback
    if (!empty($errors)) {
        $db->rollBack();
        Response::error("Erreurs lors de l'assignation: " . implode(", ", $errors), 400);
    }

    // Notifier l'admin qui a fait l'assignation
    $admin_notification = new Notification($db);
    $admin_notification->receiver_id = $data->assigned_by;
    $admin_notification->sender_id = $data->assigned_by;
    $admin_notification->message = "Vous avez assigné " . count($assigned_members) . " membre(s) au projet \"$project_title\"";
    $admin_notification->type = "assignment";
    $admin_notification->related_project_id = $data->project_id;
    $admin_notification->create();

    // Tout s'est bien passé, commit
    $db->commit();

    Response::success("Membres assignés avec succès - Projet maintenant en cours", [
        "project_id" => $data->project_id,
        "assigned_members" => $assigned_members,
        "total_assigned" => count($assigned_members),
        "new_status" => "in_progress"
    ], 201);

} catch (Exception $e) {
    // Rollback en cas d'erreur générale
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error("Erreur serveur: " . $e->getMessage(), 500);
}
?>