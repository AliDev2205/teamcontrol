<?php
/**
 * Modèle Progress - Version complètement corrigée
 */

class Progress {
    private $conn;
    private $table = "progress";

    public $progress_id;  // CORRECTION: id → progress_id
    public $project_id;
    public $phase_id;
    public $member_id;
    public $update_text;
    public $date_added;
    public $is_final;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Ajouter une mise à jour de progrès - CORRIGÉ
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (project_id, phase_id, member_id, update_text, is_final)
                  VALUES
                  (:project_id, :phase_id, :member_id, :update_text, :is_final)";

        $stmt = $this->conn->prepare($query);

        // Binding
        $stmt->bindParam(":project_id", $this->project_id);
        $stmt->bindParam(":phase_id", $this->phase_id);
        $stmt->bindParam(":member_id", $this->member_id);
        $stmt->bindParam(":update_text", $this->update_text);
        $stmt->bindParam(":is_final", $this->is_final);

        if ($stmt->execute()) {
            $this->progress_id = $this->conn->lastInsertId(); 
            return true;
        }
        return false;
    }

    /**
     * Récupérer tous les progrès d'un projet - CORRIGÉ
     */
    public function getByProjectId($project_id) {
        $query = "SELECT p.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as member_name,
                         m.photo as member_photo,
                         ph.title as phase_title
                  FROM " . $this->table . " p
                  LEFT JOIN members m ON p.member_id = m.member_id
                  LEFT JOIN project_phases ph ON p.phase_id = ph.phase_id
                  WHERE p.project_id = :project_id
                  ORDER BY p.date_added DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":project_id", $project_id);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Récupérer tous les progrès d'un membre - CORRIGÉ
     */
    public function getByMemberId($member_id) {
        $query = "SELECT p.*, 
                         pr.title as project_title,
                         ph.title as phase_title
                  FROM " . $this->table . " p
                  LEFT JOIN projects pr ON p.project_id = pr.project_id
                  LEFT JOIN project_phases ph ON p.phase_id = ph.phase_id
                  WHERE p.member_id = :member_id
                  ORDER BY p.date_added DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":member_id", $member_id);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Récupérer un progrès spécifique - CORRIGÉ
     */
    public function getById() {
        $query = "SELECT * FROM " . $this->table . "
                  WHERE progress_id = :progress_id
                  LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":progress_id", $this->progress_id);  // CORRECTION
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch();
            $this->project_id = $row['project_id'];
            $this->phase_id = $row['phase_id'];
            $this->member_id = $row['member_id'];
            $this->update_text = $row['update_text'];
            $this->date_added = $row['date_added'];
            $this->is_final = $row['is_final'];
            return true;
        }
        return false;
    }

    /**
     * Compter le nombre de mises à jour d'un projet - CORRIGÉ
     */
    public function countByProject($project_id) {
        $query = "SELECT COUNT(*) as total FROM " . $this->table . "
                  WHERE project_id = :project_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":project_id", $project_id);
        $stmt->execute();
        
        $row = $stmt->fetch();
        return $row['total'];
    }

    /**
     * Récupérer les progrès par phase - NOUVELLE MÉTHODE
     */
    public function getByPhaseId($phase_id) {
        $query = "SELECT p.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as member_name,
                         m.photo as member_photo
                  FROM " . $this->table . " p
                  LEFT JOIN members m ON p.member_id = m.member_id
                  WHERE p.phase_id = :phase_id
                  ORDER BY p.date_added DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":phase_id", $phase_id);
        $stmt->execute();
        return $stmt;
    }
}
?>