<?php
/**
 * Modèle Project - Version complètement corrigée
 */

class Project {
    private $conn;
    private $table = "projects";

    public $project_id;  
    public $title;
    public $description;
    public $created_by;  
    public $status;
    public $start_date;
    public $end_date;
    public $created_at;
    public $updated_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Créer un nouveau projet - CORRIGÉ
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (title, description, created_by, start_date, end_date, status)
                  VALUES
                  (:title, :description, :created_by, :start_date, :end_date, :status)";

        $stmt = $this->conn->prepare($query);

        // Binding - CORRECTION: created_by au lieu de assigned_to
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":created_by", $this->created_by);
        $stmt->bindParam(":start_date", $this->start_date);
        $stmt->bindParam(":end_date", $this->end_date);
        $stmt->bindParam(":status", $this->status);

        if ($stmt->execute()) {
            $this->project_id = $this->conn->lastInsertId();
            return true;
        }
        return false;
    }

    /**
     * Récupérer tous les projets - CORRIGÉ
     */
    public function getAll() {
        $query = "SELECT p.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as created_by_name
                  FROM " . $this->table . " p
                  LEFT JOIN members m ON p.created_by = m.member_id
                  ORDER BY p.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Récupérer les projets d'un membre spécifique - NOUVELLE MÉTHODE
     * Via la table project_members pour l'attribution multiple
     */
    public function getByMemberId($member_id) {
        $query = "SELECT p.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as created_by_name
                  FROM " . $this->table . " p
                  LEFT JOIN members m ON p.created_by = m.member_id
                  WHERE p.project_id IN (
                      SELECT project_id FROM project_members 
                      WHERE member_id = :member_id AND is_active = true
                  )
                  ORDER BY p.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":member_id", $member_id);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Récupérer un projet par ID - CORRIGÉ
     */
    public function getById() {
        $query = "SELECT p.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as created_by_name
                  FROM " . $this->table . " p
                  LEFT JOIN members m ON p.created_by = m.member_id
                  WHERE p.project_id = :project_id
                  LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":project_id", $this->project_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            return $stmt->fetch(PDO::FETCH_ASSOC);
        }
        return false;
    }

    /**
     * Mettre à jour le statut d'un projet - CORRIGÉ
     */
    public function updateStatus() {
        $query = "UPDATE " . $this->table . "
                  SET status = :status, updated_at = NOW()
                  WHERE project_id = :project_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":project_id", $this->project_id);

        return $stmt->execute();
    }

    /**
     * Mettre à jour un projet - CORRIGÉ
     */
    public function update() {
        $query = "UPDATE " . $this->table . "
                  SET title = :title,
                      description = :description,
                      start_date = :start_date,
                      end_date = :end_date,
                      status = :status,
                      updated_at = NOW()
                  WHERE project_id = :project_id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":start_date", $this->start_date);
        $stmt->bindParam(":end_date", $this->end_date);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":project_id", $this->project_id);

        return $stmt->execute();
    }

    /**
     * Récupérer les membres assignés à un projet - NOUVELLE MÉTHODE
     */
    public function getAssignedMembers($project_id) {
        $query = "SELECT pm.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as member_name,
                         m.email as member_email,
                         m.photo as member_photo
                  FROM project_members pm
                  LEFT JOIN members m ON pm.member_id = m.member_id
                  WHERE pm.project_id = :project_id AND pm.is_active = true
                  ORDER BY pm.assigned_date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":project_id", $project_id);
        $stmt->execute();
        return $stmt;
    }
}
?>