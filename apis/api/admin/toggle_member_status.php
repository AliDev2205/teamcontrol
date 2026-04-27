<?php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

$input = file_get_contents("php://input");
$data = json_decode($input);
if ($data === null) {
    Response::error("Données JSON invalides");
}

if (!isset($data->member_id) || empty($data->member_id)) {
    Response::error("L'ID du membre est requis");
}
if (!isset($data->status) || !in_array($data->status, ['active','inactive'])) {
    Response::error("Statut invalide (active/inactive)");
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $stmt = $db->prepare("UPDATE members SET status = :status, updated_at = NOW() WHERE member_id = :mid");
    $stmt->bindValue(":status", $data->status);
    $stmt->bindValue(":mid", intval($data->member_id));
    if ($stmt->execute()) {
        Response::success("Statut mis à jour", [
            'member_id' => intval($data->member_id),
            'status' => $data->status,
        ]);
    }
    Response::error("Erreur lors de la mise à jour", 500);
} catch (Exception $e) {
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>



