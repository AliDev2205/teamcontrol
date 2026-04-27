<?php
/**
 * Endpoint: Mark Project as Done
 * POST /member/mark_project_done.php
 * 
 * Body JSON:
 * {
 *   "project_id": 1,
 *   "member_id": 2,
 *   "final_comment": "Projet terminé avec succès. Tous les livrables sont prêts."
 * }
 */

require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Project.php';
require_once '../models/Progress.php';
require_once '../models/Notification.php';
require_once '../utils/response.php';

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
if (!isset($data->member_id) || empty($data->member_id)) {
    Response::error("L'ID du membre est requis");
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

try {
    // Commencer une transaction
    $db->beginTransaction();

    // 1. Ajouter un commentaire final dans progress
    if (isset($data->final_comment) && !empty(trim($data->final_comment))) {
        $progress = new Progress($db);
        $progress->project_id = $data->project_id;
        $progress->member_id = $data->member_id;
        $progress->update_text = trim($data->final_comment);
        $progress->is_final = true;
        
        if (!$progress->create()) {
            throw new Exception("Erreur lors de l'ajout du commentaire final");
        }
    }

    // 2. Mettre à jour le statut du projet à "completed"
    $project = new Project($db);
    $project->project_id = $data->project_id;
    $project->status = 'completed';
    
    if (!$project->updateStatus()) {
        throw new Exception("Erreur lors de la mise à jour du statut du projet");
    }

    // 3. Envoyer une notification à l'administrateur
    // Récupérer les détails complets du projet
    $project_query = $db->prepare("SELECT title FROM projects WHERE project_id = ?");
    $project_query->execute([$data->project_id]);
    $project_data = $project_query->fetch(PDO::FETCH_ASSOC);
    
    if (!$project_data) {
        throw new Exception("Projet introuvable");
    }
    
    // Récupérer l'ID de l'administrateur (ici, on suppose qu'il y a un administrateur avec ID 1, à adapter selon votre logique)
    $admin_id = 1; // À remplacer par la logique pour obtenir l'ID de l'admin
    
    // Récupérer le nom du membre
    $member_query = $db->prepare("SELECT CONCAT(first_name, ' ', last_name) as member_name FROM members WHERE member_id = ?");
    $member_query->execute([$data->member_id]);
    $member = $member_query->fetch(PDO::FETCH_ASSOC);
    $member_name = $member ? $member['member_name'] : 'Un membre';
    
    // Créer la notification avec le titre du projet récupéré directement
    $notification = new Notification($db);
    $notification->receiver_id = $admin_id;
    $notification->sender_id = $data->member_id;
    $notification->message = "Le projet \"{$project_data['title']}\" a été marqué comme terminé par $member_name";
    $notification->type = "project_complete";
    $notification->related_project_id = $data->project_id;
    $notification->create();

    // Valider la transaction
    $db->commit();

    Response::success("Projet marqué comme terminé avec succès", [
        "project_id" => $data->project_id,
        "status" => "completed"
    ]);

} catch (Exception $e) {
    // Annuler la transaction en cas d'erreur
    $db->rollBack();
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>