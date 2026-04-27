<?php
/**
 * Endpoint: Register (Admin uniquement)
 * POST /auth/register.php
 * 
 * Body JSON:
 * {
 *   "first_name": "John",
 *   "last_name": "Doe",
 *   "email": "john@arnostech.com",
 *   "phone": "+22901234567",
 *   "position": "Développeur",
 *   "department": "IT",
 *   "employee_id": "EMP004",
 *   "password": "password123",
 *   "role": "member"
 * }
 */

require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../models/Member.php';
require_once '../utils/response.php';

// Vérifier que c'est une requête POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error("Méthode non autorisée", 405);
}

// Récupérer les données JSON
$input = file_get_contents("php://input");
$data = json_decode($input);

// Debug: afficher ce qui est reçu (à retirer en production)
if ($data === null) {
    Response::error("Données JSON invalides. Reçu: " . $input);
}

// Validation des champs requis
if (!isset($data->first_name) || empty(trim($data->first_name))) {
    Response::error("Le champ 'first_name' est requis");
}
if (!isset($data->last_name) || empty(trim($data->last_name))) {
    Response::error("Le champ 'last_name' est requis");
}
if (!isset($data->email) || empty(trim($data->email))) {
    Response::error("Le champ 'email' est requis");
}
if (!isset($data->password) || empty(trim($data->password))) {
    Response::error("Le champ 'password' est requis");
}
if (!isset($data->employee_id) || empty(trim($data->employee_id))) {
    Response::error("Le champ 'employee_id' est requis");
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

// Instancier le modèle Member
$member = new Member($db);

// Vérifier si l'email existe déjà
$member->email = trim($data->email);
if ($member->emailExists()) {
    Response::error("Cet email est déjà utilisé");
}

// Assigner les données
$member->first_name = trim($data->first_name);
$member->last_name = trim($data->last_name);
$member->email = trim($data->email);
$member->phone = isset($data->phone) ? trim($data->phone) : null;
$member->position = isset($data->position) ? trim($data->position) : null;
$member->department = isset($data->department) ? trim($data->department) : null;
$member->employee_id = trim($data->employee_id);
$member->password = $data->password;
$member->photo = isset($data->photo) ? trim($data->photo) : null;
$member->role = isset($data->role) ? trim($data->role) : 'member';
$member->status = 'active';

// Créer le membre
if ($member->create()) {
    Response::success("Membre créé avec succès", [
        "id" => $member->member_id,
        "first_name" => $member->first_name,
        "last_name" => $member->last_name,
        "email" => $member->email,
        "employee_id" => $member->employee_id,
        "role" => $member->role
    ], 201);
} else {
    Response::error("Erreur lors de la création du membre", 500);
}
?>