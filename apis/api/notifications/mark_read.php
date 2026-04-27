<?php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Notification.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

$input = file_get_contents("php://input");
$data = json_decode($input);

if (!isset($data->notification_id) || empty($data->notification_id)) {
    Response::error("L'ID de la notification est requis");
}

$notification_id = $data->notification_id;

try {
    $database = new Database();
    $db = $database->getConnection();

    $notification = new Notification($db);
    $notification->notification_id = $notification_id;

    if ($notification->markAsRead()) {
        Response::success("Notification marquée comme lue");
    } else {
        Response::error("Erreur lors du marquage de la notification");
    }

} catch (Exception $e) {
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>