<?php
/**
 * Endpoint: Add Progress
 * POST /member/add_progress.php
 * 
 * Body JSON:
 * {
 *   "project_id": 1,
 *   "member_id": 2,
 *   "update_text": "Aujourd'hui j'ai terminé la maquette de la page d'accueil",
 *   "is_final": false
 * }
 */

require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Progress.php';
require_once '../models/Notification.php';
require_once '../models/Project.php';
require_once '../models/Member.php';
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
if (!isset($data->update_text) || empty(trim($data->update_text))) {
    Response::error("Le texte de la mise à jour est requis");
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

try {
    // Démarrer une transaction pour les notifications
    $db->beginTransaction();

    // CORRECTION : Convertir is_final en entier (0 ou 1)
    $is_final = 0; // Par défaut false
    if (isset($data->is_final)) {
        if ($data->is_final === true || $data->is_final === 'true' || $data->is_final === '1' || $data->is_final === 1) {
            $is_final = 1;
        }
    }

    // Instancier le modèle Progress
    $progress = new Progress($db);

    // Assigner les données
    $progress->project_id = intval($data->project_id);
    $progress->member_id = intval($data->member_id);
    $progress->update_text = trim($data->update_text);
    $progress->is_final = $is_final; // Utiliser la valeur convertie

    // Créer la mise à jour de progrès
    if (!$progress->create()) {
        throw new Exception("Erreur lors de l'ajout de la mise à jour");
    }

    // Récupérer les informations pour les notifications
    $project = new Project($db);
    $project->project_id = $data->project_id;
    $project_data = $project->getById();
    $project_title = $project_data ? $project_data['title'] : 'Projet';

    $member = new Member($db);
    $member->member_id = $data->member_id;
    $member_data = $member->getById();
    $member_name = $member_data ? $member_data['first_name'] . ' ' . $member_data['last_name'] : 'Un membre';

    // NOTIFIER TOUS LES ADMINS de la nouvelle mise à jour
    $admin_query = "SELECT member_id FROM members WHERE role = 'admin' AND status = 'active'";
    $admin_stmt = $db->prepare($admin_query);
    $admin_stmt->execute();
    $admins = $admin_stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($admins as $admin) {
        $notification = new Notification($db);
        $notification->receiver_id = $admin['member_id'];
        $notification->sender_id = $data->member_id;
        
        if ($is_final == 1) { // Utiliser la variable convertie
            $notification->message = "$member_name a marqué le projet \"$project_title\" comme terminé";
            $notification->type = "project_complete";
        } else {
            $notification->message = "$member_name a ajouté une mise à jour sur le projet \"$project_title\"";
            $notification->type = "update";
        }
        
        $notification->related_project_id = $data->project_id;
        $notification->create();
        
        // CRÉER UNE VALIDATION EN ATTENTE POUR CHAQUE ADMIN
        // Vérifier si la table progress_validations existe
        $checkTableQuery = "SHOW TABLES LIKE 'progress_validations'";
        $checkTableStmt = $db->prepare($checkTableQuery);
        $checkTableStmt->execute();
        
        if ($checkTableStmt->rowCount() > 0) {
            // Table existe, créer l'entrée de validation
            $validationQuery = "INSERT INTO progress_validations 
                               (progress_id, admin_id, validation_status, created_at) 
                               VALUES 
                               (:progress_id, :admin_id, 'pending', NOW()) 
                               ON DUPLICATE KEY UPDATE 
                               validation_status = 'pending', 
                               validated_at = NULL, 
                               admin_comment = NULL";
            
            $validationStmt = $db->prepare($validationQuery);
            $validationStmt->bindParam(":progress_id", $progress->progress_id);
            $validationStmt->bindParam(":admin_id", $admin['member_id']);
            $validationStmt->execute();
        }
    }

    // Si c'est une mise à jour finale, marquer le projet comme terminé
    if ($is_final == 1) { // Utiliser la variable convertie
        $updateProjectQuery = "UPDATE projects SET status = 'completed', updated_at = NOW() WHERE project_id = :project_id";
        $updateProjectStmt = $db->prepare($updateProjectQuery);
        $updateProjectStmt->bindParam(":project_id", $data->project_id);
        $updateProjectStmt->execute();
        
        // Notifier aussi les autres membres du projet
        $project_members_query = "SELECT member_id FROM project_members 
                                 WHERE project_id = :project_id 
                                 AND member_id != :current_member_id
                                 AND is_active = true";
        $project_members_stmt = $db->prepare($project_members_query);
        $project_members_stmt->bindParam(":project_id", $data->project_id);
        $project_members_stmt->bindParam(":current_member_id", $data->member_id);
        $project_members_stmt->execute();
        $project_members = $project_members_stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($project_members as $project_member) {
            $notification = new Notification($db);
            $notification->receiver_id = $project_member['member_id'];
            $notification->sender_id = $data->member_id;
            $notification->message = "Le projet \"$project_title\" a été marqué comme terminé par $member_name";
            $notification->type = "project_complete";
            $notification->related_project_id = $data->project_id;
            $notification->create();
        }
    }

    // Valider la transaction
    $db->commit();

    Response::success("Mise à jour ajoutée avec succès - Admins notifiés", [
        "id" => $progress->progress_id, 
        "project_id" => $progress->project_id,
        "member_id" => $progress->member_id,
        "update_text" => $progress->update_text,
        "is_final" => $is_final, // Retourner la valeur convertie
        "admins_notified" => count($admins)
    ], 201);

} catch (Exception $e) {
    // Rollback en cas d'erreur
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error("Erreur lors de l'ajout de la mise à jour: " . $e->getMessage(), 500);
}
?>