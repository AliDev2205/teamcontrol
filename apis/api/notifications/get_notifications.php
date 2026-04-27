<?php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Notification.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error("Méthode non autorisée", 405);
}

if (!isset($_GET['member_id']) || empty($_GET['member_id'])) {
    Response::error("L'ID du membre est requis");
}

$member_id = $_GET['member_id'];

try {
    $database = new Database();
    $db = $database->getConnection();

    $notification = new Notification($db);
    $stmt = $notification->getByMemberId($member_id);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

    Response::success("Notifications récupérées avec succès", $notifications);

} catch (Exception $e) {
    Response::error("Erreur lors de la récupération des notifications: " . $e->getMessage(), 500);
}
?>