<?php
/**
 * Modèle Member
 * Gestion des membres Arnos Tech - Version corrigée
 */

class Member {
    private $conn;
    private $table = "members";

    public $member_id;  // Changé: id → member_id
    public $first_name;
    public $last_name;
    public $email;
    public $phone;
    public $position;
    public $department;
    public $employee_id;
    public $password;
    public $photo;
    public $date_joined;
    public $role;
    public $status;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Vérifier si l'email existe déjà - CORRIGÉ
     */
    public function emailExists() {
        $query = "SELECT member_id, first_name, last_name, email, password, role, status 
                  FROM " . $this->table . " 
                  WHERE email = :email LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":email", $this->email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch();
            // Correction: member_id au lieu de id
            $this->member_id = $row['member_id'];
            $this->first_name = $row['first_name'];
            $this->last_name = $row['last_name'];
            $this->email = $row['email'];
            $this->password = $row['password'];
            $this->role = $row['role'];
            $this->status = $row['status'];
            return true;
        }
        return false;
    }

    /**
     * Créer un nouveau membre - CORRIGÉ
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (first_name, last_name, email, phone, position, department, 
                   employee_id, password, photo, role, status)
                  VALUES
                  (:first_name, :last_name, :email, :phone, :position, :department,
                   :employee_id, :password, :photo, :role, :status)";

        $stmt = $this->conn->prepare($query);

        // Hash du mot de passe
        $hashed_password = password_hash($this->password, PASSWORD_BCRYPT);

        // Binding
        $stmt->bindParam(":first_name", $this->first_name);
        $stmt->bindParam(":last_name", $this->last_name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":position", $this->position);
        $stmt->bindParam(":department", $this->department);
        $stmt->bindParam(":employee_id", $this->employee_id);
        $stmt->bindParam(":password", $hashed_password);
        $stmt->bindParam(":photo", $this->photo);
        $stmt->bindParam(":role", $this->role);
        $stmt->bindParam(":status", $this->status);

        if ($stmt->execute()) {
            $this->member_id = $this->conn->lastInsertId(); // Correction ici
            return true;
        }
        return false;
    }

    /**
     * Récupérer tous les membres - CORRIGÉ
     */
    public function getAll() {
        $query = "SELECT member_id, first_name, last_name, email, phone, position, 
                         department, employee_id, photo, date_joined, role, status
                  FROM " . $this->table . "
                  ORDER BY date_joined DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Récupérer un membre par ID - CORRIGÉ
     */
    public function getById() {
        $query = "SELECT * FROM " . $this->table . " WHERE member_id = :member_id LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":member_id", $this->member_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            return $stmt->fetch(PDO::FETCH_ASSOC);
        }
        return false;
    }
}
?>