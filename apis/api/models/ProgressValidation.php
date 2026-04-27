<?php
// api/models/ProgressValidation.php
class ProgressValidation {
    private $conn;
    private $table = "progress_validations";

    public $validation_id;
    public $progress_id;
    public $admin_id;
    public $validation_status;
    public $admin_comment;
    public $validated_at;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function createOrUpdate() {
        // Vérifier si une validation existe déjà
        $checkQuery = "SELECT validation_id FROM " . $this->table . " 
                      WHERE progress_id = :progress_id AND admin_id = :admin_id";
        $checkStmt = $this->conn->prepare($checkQuery);
        $checkStmt->bindParam(":progress_id", $this->progress_id);
        $checkStmt->bindParam(":admin_id", $this->admin_id);
        $checkStmt->execute();

        if ($checkStmt->rowCount() > 0) {
            // Mettre à jour
            $query = "UPDATE " . $this->table . "
                      SET validation_status = :validation_status, 
                          admin_comment = :admin_comment,
                          validated_at = NOW()
                      WHERE progress_id = :progress_id AND admin_id = :admin_id";
        } else {
            // Créer
            $query = "INSERT INTO " . $this->table . "
                      (progress_id, admin_id, validation_status, admin_comment)
                      VALUES
                      (:progress_id, :admin_id, :validation_status, :admin_comment)";
        }

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":progress_id", $this->progress_id);
        $stmt->bindParam(":admin_id", $this->admin_id);
        $stmt->bindParam(":validation_status", $this->validation_status);
        $stmt->bindParam(":admin_comment", $this->admin_comment);

        return $stmt->execute();
    }

    public function getByProgressId($progress_id) {
        $query = "SELECT pv.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as admin_name
                  FROM " . $this->table . " pv
                  LEFT JOIN members m ON pv.admin_id = m.member_id
                  WHERE pv.progress_id = :progress_id
                  ORDER BY pv.validated_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":progress_id", $progress_id);
        $stmt->execute();
        return $stmt;
    }

    public function getPendingValidations($admin_id = null) {
        $query = "SELECT pv.*, 
                         p.update_text,
                         p.member_id as progress_member_id,
                         CONCAT(m.first_name, ' ', m.last_name) as member_name,
                         pr.title as project_title,
                         pr.project_id
                  FROM " . $this->table . " pv
                  LEFT JOIN progress p ON pv.progress_id = p.progress_id
                  LEFT JOIN projects pr ON p.project_id = pr.project_id
                  LEFT JOIN members m ON p.member_id = m.member_id
                  WHERE pv.validation_status = 'pending'";

        if ($admin_id !== null) {
            $query .= " AND pv.admin_id = :admin_id";
        }

        $query .= " ORDER BY pv.created_at DESC";

        $stmt = $this->conn->prepare($query);
        
        if ($admin_id !== null) {
            $stmt->bindParam(":admin_id", $admin_id);
        }
        
        $stmt->execute();
        return $stmt;
    }

    public function getProgressWithMemberInfo() {
        $query = "SELECT p.member_id, 
                         CONCAT(m.first_name, ' ', m.last_name) as member_name,
                         pr.title as project_title,
                         pr.project_id,
                         CONCAT(a.first_name, ' ', a.last_name) as admin_name
                  FROM progress p
                  JOIN projects pr ON p.project_id = pr.project_id
                  JOIN members m ON p.member_id = m.member_id
                  JOIN members a ON a.member_id = :admin_id
                  WHERE p.progress_id = :progress_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":progress_id", $this->progress_id);
        $stmt->bindParam(":admin_id", $this->admin_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            return $stmt->fetch(PDO::FETCH_ASSOC);
        }
        return false;
    }
}
?>