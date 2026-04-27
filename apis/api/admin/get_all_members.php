<?php
// api/admin/get_all_members.php
require_once __DIR__ . '/../config/headers.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Member.php';
require_once __DIR__ . '/../utils/response.php';

// Debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Vérifier que c'est une requête GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error("Méthode non autorisée", 405);
}

try {
    // Connexion DB
    $database = new Database();
    $db = $database->getConnection();

    // Instancier le modèle Member
    $member = new Member($db);

    // Récupérer tous les membres
    $stmt = $member->getAll();
    $members = [];

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $members[] = [
            "id" => $row['member_id'],  // Correction: member_id au lieu de id
            "first_name" => $row['first_name'],
            "last_name" => $row['last_name'],
            "email" => $row['email'],
            "phone" => $row['phone'],
            "position" => $row['position'],
            "department" => $row['department'],
            "employee_id" => $row['employee_id'],
            "photo" => $row['photo'],
            "date_joined" => $row['date_joined'],
            "role" => $row['role'],
            "status" => $row['status']
        ];
    }

    Response::success("Membres récupérés avec succès", $members);

} catch (Exception $e) {
    Response::error("Erreur lors de la récupération des membres: " . $e->getMessage(), 500);
}
?>