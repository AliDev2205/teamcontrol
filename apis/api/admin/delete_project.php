<?php
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
    $existing = $project->getById();
    if (!$existing) {
        Response::error("Projet introuvable", 404);
    }

    // Récupérer les membres assignés avant suppression
    $assignedStmt = $project->getAssignedMembers($project->project_id);
    $assigned = $assignedStmt->fetchAll(PDO::FETCH_ASSOC);

    // Démarrer la transaction
    $db->beginTransaction();

    try {
        // 1. D'abord, notifier les membres si des affectations existent
        if (!empty($assigned)) {
            $sender_id = isset($data->admin_id) ? intval($data->admin_id) : $existing['created_by'];
            foreach ($assigned as $row) {
                $notif = new Notification($db);
                $notif->receiver_id = intval($row['member_id']);
                $notif->sender_id = $sender_id;
                $notif->message = "Le projet '" . $existing['title'] . "' a été supprimé";
                $notif->type = 'project_deleted';
                $notif->related_project_id = $project->project_id;
                $notif->related_phase_id = null;
                $notif->create();
            }
        }

        // 2. Supprimer les notifications existantes liées au projet
        $stmtNotif = $db->prepare("DELETE FROM notifications WHERE related_project_id = :pid");
        $stmtNotif->bindParam(":pid", $project->project_id);
        $stmtNotif->execute();

        // 3. Supprimer les liaisons des membres
        $stmtPM = $db->prepare("DELETE FROM project_members WHERE project_id = :pid");
        $stmtPM->bindParam(":pid", $project->project_id);
        $stmtPM->execute();

        // 4. Supprimer les phases
        $stmtPh = $db->prepare("DELETE FROM project_phases WHERE project_id = :pid");
        $stmtPh->bindParam(":pid", $project->project_id);
        $stmtPh->execute();

        // 5. Supprimer les entrées de progression
        $stmtProg = $db->prepare("DELETE FROM progress WHERE project_id = :pid");
        $stmtProg->bindParam(":pid", $project->project_id);
        $stmtProg->execute();

        // 6. Supprimer les logs d'activité
        $stmtLogs = $db->prepare("DELETE FROM activity_logs WHERE project_id = :pid");
        $stmtLogs->bindParam(":pid", $project->project_id);
        $stmtLogs->execute();

        // 7. Enfin, supprimer le projet
        $stmtPr = $db->prepare("DELETE FROM projects WHERE project_id = :pid");
        $stmtPr->bindParam(":pid", $project->project_id);
        $stmtPr->execute();

        // Valider la transaction
        $db->commit();
    } catch (Exception $e) {
        $db->rollBack();
        throw $e; // Relancer l'exception pour la gestion d'erreur globale
    }

    Response::success("Projet supprimé avec succès", [
        'project_id' => $project->project_id,
        'title' => $existing['title'],
    ]);

} catch (Exception $e) {
    if ($db && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>



