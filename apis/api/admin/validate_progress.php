<?php
// api/admin/validate_progress.php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/ProgressValidation.php';
require_once '../models/Notification.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

$input = file_get_contents("php://input");
$data = json_decode($input);

// Validation
if (!isset($data->progress_id) || empty($data->progress_id)) {
    Response::error("L'ID de la mise à jour est requis");
}
if (!isset($data->admin_id) || empty($data->admin_id)) {
    Response::error("L'ID de l'admin est requis");
}
if (!isset($data->validation_status) || !in_array($data->validation_status, ['approved', 'rejected'])) {
    Response::error("Statut de validation invalide");
}

try {
    $database = new Database();
    $db = $database->getConnection();
    $db->beginTransaction();

    // Créer ou mettre à jour la validation
    $validation = new ProgressValidation($db);
    $validation->progress_id = $data->progress_id;
    $validation->admin_id = $data->admin_id;
    $validation->validation_status = $data->validation_status;
    $validation->admin_comment = $data->admin_comment ?? null;

    if ($validation->createOrUpdate()) {
        // Récupérer les infos pour la notification
        $progress_info = $validation->getProgressWithMemberInfo();
        
        if ($progress_info) {
            $member_id = $progress_info['member_id'];
            $member_name = $progress_info['member_name'];
            $project_title = $progress_info['project_title'];
            $admin_name = $progress_info['admin_name'];
            
            // Notifier le membre
            $notification = new Notification($db);
            $notification->receiver_id = $member_id;
            $notification->sender_id = $data->admin_id;
            $notification->message = "Votre mise à jour sur le projet \"$project_title\" a été " . 
                                   ($data->validation_status == 'approved' ? 'approuvée' : 'rejetée') . 
                                   " par $admin_name";
            $notification->type = "progress_validation";
            $notification->related_project_id = $progress_info['project_id'];
            $notification->create();
        }

        $db->commit();
        Response::success("Validation enregistrée avec succès");
    } else {
        throw new Exception("Erreur lors de la validation");
    }

} catch (Exception $e) {
    $db->rollBack();
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>