<?php
// api/admin/get_pending_validations.php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/ProgressValidation.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error("Méthode non autorisée", 405);
}

$admin_id = isset($_GET['admin_id']) ? $_GET['admin_id'] : null;

try {
    $database = new Database();
    $db = $database->getConnection();

    $validation = new ProgressValidation($db);
    $stmt = $validation->getPendingValidations($admin_id);
    $validations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    Response::success("Validations en attente récupérées", $validations);

} catch (Exception $e) {
    Response::error("Erreur lors de la récupération: " . $e->getMessage(), 500);
}
?>