<?php
/**
 * Endpoint: Login
 * POST /auth/login.php
 * 
 * Body JSON:
 * {
 *   "email": "admin@arnostech.com",
 *   "password": "password"
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


// Validation
if (!isset($data->email) || !isset($data->password) || 
    empty(trim($data->email)) || empty(trim($data->password))) {
    Response::error("Email et mot de passe requis");
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

// Instancier le modèle Member
$member = new Member($db);
$member->email = trim($data->email);

// Vérifier si l'utilisateur existe
if ($member->emailExists()) {
    
    // Vérifier le statut
    if ($member->status !== 'active') {
        Response::error("Compte inactif. Contactez l'administrateur", 403);
    }

    // Vérifier le mot de passe
    if (password_verify($data->password, $member->password)) {
        
        // Connexion réussie
        Response::success("Connexion réussie", [
           "id" => $member->member_id,  
                "first_name" => $member->first_name,
                "last_name" => $member->last_name,
                "email" => $member->email,
                "phone" => $member->phone,
                "position" => $member->position,
                "department" => $member->department,
                "employee_id" => $member->employee_id,
                "photo" => $member->photo,
                "role" => $member->role,
                "status" => $member->status
        ]);
        
    } else {
        Response::error("Mot de passe incorrect", 401);
    }
    
} else {
    Response::error("Email non trouvé", 404);
}
?>