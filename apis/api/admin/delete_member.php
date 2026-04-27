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

try {
    $database = new Database();
    $db = $database->getConnection();

    $memberId = intval($data->member_id);

    // Supprimer les liaisons (projets, notifications) avant le membre
    $db->beginTransaction();
    $stmt = $db->prepare("DELETE FROM project_members WHERE member_id = :mid");
    $stmt->bindParam(":mid", $memberId);
    $stmt->execute();

    $stmt2 = $db->prepare("DELETE FROM notifications WHERE receiver_id = :mid OR sender_id = :mid");
    $stmt2->bindParam(":mid", $memberId);
    $stmt2->execute();

    $stmt3 = $db->prepare("DELETE FROM members WHERE member_id = :mid");
    $stmt3->bindParam(":mid", $memberId);
    $stmt3->execute();

    $db->commit();
    Response::success("Membre supprimé", ["member_id" => $memberId]);
} catch (Exception $e) {
    if ($db && $db->inTransaction()) $db->rollBack();
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>



