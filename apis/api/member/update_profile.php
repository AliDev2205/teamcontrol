<?php
/**
 * Endpoint: Update Profile
 * POST /member/update_profile.php
 * 
 * Body JSON:
 * {
 *   "id": 1,
 *   "first_name": "John",
 *   "last_name": "Doe",
 *   "phone": "+22912345678",
 *   "position": "Développeur Senior",
 *   "department": "IT",
 *   "photo": "base64_or_url"
 * }
 */

require_once '../config/headers.php';
require_once '../config/database.php';
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

// Validation minimale: uniquement l'ID requis
if (!isset($data->id) || empty($data->id)) {
    Response::error("L'ID du membre est requis");
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

try {
    // Construire dynamiquement les champs à mettre à jour
    $fields = [];
    $params = [":id" => $data->id];

    if (property_exists($data, 'first_name')) {
        $fields[] = "first_name = :first_name";
        $params[":first_name"] = $data->first_name; // peut être null
    }
    if (property_exists($data, 'last_name')) {
        $fields[] = "last_name = :last_name";
        $params[":last_name"] = $data->last_name;
    }
    if (property_exists($data, 'phone')) {
        $fields[] = "phone = :phone";
        $params[":phone"] = $data->phone;
    }
    if (property_exists($data, 'position')) {
        $fields[] = "position = :position";
        $params[":position"] = $data->position;
    }
    if (property_exists($data, 'department')) {
        $fields[] = "department = :department";
        $params[":department"] = $data->department;
    }
    if (property_exists($data, 'photo')) {
        $fields[] = "photo = :photo";
        $params[":photo"] = $data->photo;
    }

    if (empty($fields)) {
        Response::error("Aucune donnée à mettre à jour", 400);
    }

    $query = "UPDATE members SET " . implode(', ', $fields) . " WHERE member_id = :id";
    $stmt = $db->prepare($query);
    foreach ($params as $key => $value) {
        // utiliser bindValue pour permettre null
        $stmt->bindValue($key, $value);
    }

    if ($stmt->execute()) {
        // Récupérer les données mises à jour
        $query_select = "SELECT member_id AS id, first_name, last_name, email, phone, position, 
                                department, employee_id, photo, date_joined, role, status
                         FROM members WHERE member_id = :id LIMIT 1";
        
        $stmt_select = $db->prepare($query_select);
        $stmt_select->bindParam(":id", $data->id);
        $stmt_select->execute();
        
        $user_data = $stmt_select->fetch();
        
        Response::success("Profil mis à jour avec succès", $user_data);
    } else {
        Response::error("Erreur lors de la mise à jour", 500);
    }

} catch (Exception $e) {
    Response::error("Erreur: " . $e->getMessage(), 500);
}
?>