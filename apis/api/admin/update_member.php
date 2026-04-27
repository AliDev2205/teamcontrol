<?php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Member.php';
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

    // Construire un UPDATE partiel
    $fields = [];
    $params = [":member_id" => intval($data->member_id)];

    $map = [
        'first_name' => 'first_name',
        'last_name' => 'last_name',
        'email' => 'email',
        'phone' => 'phone',
        'position' => 'position',
        'department' => 'department',
        'employee_id' => 'employee_id',
        'photo' => 'photo',
        'role' => 'role',
        'status' => 'status',
    ];

    foreach ($map as $jsonKey => $col) {
        if (property_exists($data, $jsonKey)) {
            $fields[] = "$col = :$jsonKey";
            $params[":$jsonKey"] = $data->$jsonKey; // peut être null
        }
    }

    if (property_exists($data, 'password') && !empty($data->password)) {
        $fields[] = "password = :password";
        $params[":password"] = password_hash($data->password, PASSWORD_BCRYPT);
    }

    if (empty($fields)) {
        Response::error("Aucune donnée à mettre à jour", 400);
    }

    $query = "UPDATE members SET " . implode(', ', $fields) . ", updated_at = NOW() WHERE member_id = :member_id";
    $stmt = $db->prepare($query);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }

    if ($stmt->execute()) {
        $select = $db->prepare("SELECT member_id AS id, first_name, last_name, email, phone, position, department, employee_id, photo, date_joined, role, status FROM members WHERE member_id = :member_id");
        $select->bindValue(":member_id", $params[":member_id"]);
        $select->execute();
        $user = $select->fetch(PDO::FETCH_ASSOC);
        Response::success("Membre mis à jour", $user);
    }
    Response::error("Erreur lors de la mise à jour", 500);
} catch (Exception $e) {
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>



