<?php
// api/member/update_phase_status.php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/ProjectPhase.php';
require_once '../models/Notification.php';
require_once '../utils/response.php';

// Activer l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Vérifier la méthode
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

// Récupérer les données JSON
$input = file_get_contents("php://input");
$data = json_decode($input);

// Vérifier le décodage JSON
if ($data === null) {
    Response::error("Données JSON invalides");
}

// Validation des champs requis
if (!isset($data->phase_id) || empty($data->phase_id)) {
    Response::error("L'ID de la phase est requis");
}

if (!isset($data->status) || empty($data->status)) {
    Response::error("Le statut est requis");
}

// Valider le statut
$valid_statuses = ['pending', 'in_progress', 'completed'];
if (!in_array($data->status, $valid_statuses)) {
    Response::error("Statut invalide. Valeurs acceptées: " . implode(', ', $valid_statuses));
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Impossible de se connecter à la base de données");
    }
    
    // Démarrer une transaction
    $db->beginTransaction();
    
    // Charger les détails de la phase
    $phase = new ProjectPhase($db);
    $phase->phase_id = intval($data->phase_id);
    $phase->status = $data->status;
    
    // Mettre à jour le statut de la phase
    if (!$phase->updateStatus()) {
        throw new Exception("Erreur lors de la mise à jour du statut de la phase");
    }
    
    // Charger les détails complets de la phase
    if (!$phase->getById()) {
        throw new Exception("Impossible de récupérer les détails de la phase");
    }
    
    // Si la phase est marquée comme terminée, envoyer une notification à l'admin
if ($data->status === 'completed') {
    // Récupérer l'ID de l'administrateur (ici, on prend le premier admin actif)
    $admin_query = $db->query("SELECT member_id FROM members WHERE role = 'admin' AND status = 'active' LIMIT 1");
    $admin = $admin_query->fetch(PDO::FETCH_ASSOC);
    
    if (!$admin) {
        throw new Exception("Aucun administrateur actif trouvé");
    }
    
    $admin_id = $admin['member_id'];
    
    // CORRECTION : Récupérer le titre du projet
    $project_title = 'Projet inconnu'; // Valeur par défaut
    $project_query = $db->prepare("SELECT p.title FROM projects p JOIN project_phases pp ON p.project_id = pp.project_id WHERE pp.phase_id = ?");
    
    if ($project_query->execute([$phase->phase_id])) {
        $project = $project_query->fetch(PDO::FETCH_ASSOC);
        if ($project && !empty($project['title'])) {
            $project_title = $project['title'];
        }
    }
    
    // CORRECTION : Gérer correctement le sender_id
    $sender_id = null;
    $member_name = 'Un membre';
    
    // Si un member_id est fourni ET qu'il existe dans la base
    if (isset($data->member_id) && !empty($data->member_id)) {
        $member_id = intval($data->member_id);
        
        // Vérifier que le membre existe
        $member_query = $db->prepare("SELECT member_id, CONCAT(first_name, ' ', last_name) as member_name FROM members WHERE member_id = ? AND status = 'active'");
        $member_query->execute([$member_id]);
        $member = $member_query->fetch(PDO::FETCH_ASSOC);
        
        if ($member) {
            $sender_id = $member['member_id'];
            $member_name = $member['member_name'];
        }
    }
    
    // Créer la notification AVEC le bon titre de projet
    $notification = new Notification($db);
    $notification->receiver_id = $admin_id;
    $notification->sender_id = $sender_id;
    $notification->message = "La phase \"{$phase->title}\" du projet \"$project_title\" a été marquée comme terminée par $member_name";
    $notification->type = "phase_complete";
    $notification->related_project_id = $phase->project_id;
    $notification->related_phase_id = $phase->phase_id;
    $notification->is_read = 0;
    
    if (!$notification->create()) {
        throw new Exception("Erreur lors de la création de la notification");
    }
}
    // Valider la transaction
    $db->commit();
    
    Response::success("Statut de la phase mis à jour avec succès", [
        "phase_id" => $phase->phase_id,
        "status" => $phase->status
    ]);
    
} catch (PDOException $e) {
    // Annuler la transaction en cas d'erreur
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    
    $errorInfo = $e->errorInfo;
    $errorMessage = "Erreur PDO [" . $e->getCode() . "]: " . $e->getMessage();
    if (!empty($errorInfo[2])) {
        $errorMessage .= " - " . $errorInfo[2];
    }
    
    error_log("Erreur PDO update_phase_status: " . $errorMessage);
    
    // Renvoyer un message d'erreur plus détaillé en mode débogage
    if (isset($db)) {
        $db_error = $db->errorInfo();
        if (!empty($db_error[2])) {
            $errorMessage .= " - Détails: " . $db_error[2];
        }
    }
    
    Response::error($errorMessage, 500);
    
} catch (Exception $e) {
    // Annuler la transaction en cas d'erreur
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log("Erreur update_phase_status: " . $e->getMessage());
    Response::error("Erreur: " . $e->getMessage() . " (Ligne: " . $e->getLine() . ")", 500);
}
?>