<?php
/**
 * Configuration de la base de données
 * Team Control - API REST
 */

class Database {
    private $host = "localhost";
    private $db_name = "arnos_tech_db";
    private $username = "root";  
    private $password = "";      
    public $conn;

    /**
     * Connexion à la base de données
     */
    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            echo json_encode([
                "success" => false,
                "message" => "Erreur de connexion: " . $e->getMessage()
            ]);
            exit;
        }

        return $this->conn;
    }
}
?>