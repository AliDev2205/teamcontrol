<?php
// api/models/ProjectMember.php
class ProjectMember {
    private $conn;
    private $table = "project_members";

    public $assignment_id;
    public $project_id;
    public $member_id;
    public $assigned_by;
    public $assigned_date;
    public $is_active;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        // Vérifier d'abord si l'assignation existe déjà
        $checkQuery = "SELECT assignment_id FROM " . $this->table . " 
                      WHERE project_id = :project_id AND member_id = :member_id AND is_active = true";
        $checkStmt = $this->conn->prepare($checkQuery);
        $checkStmt->bindParam(":project_id", $this->project_id);
        $checkStmt->bindParam(":member_id", $this->member_id);
        $checkStmt->execute();

        if ($checkStmt->rowCount() > 0) {
            // L'assignation existe déjà
            return true;
        }

        $query = "INSERT INTO " . $this->table . "
                  (project_id, member_id, assigned_by, is_active)
                  VALUES
                  (:project_id, :member_id, :assigned_by, :is_active)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":project_id", $this->project_id);
        $stmt->bindParam(":member_id", $this->member_id);
        $stmt->bindParam(":assigned_by", $this->assigned_by);
        $stmt->bindParam(":is_active", $this->is_active);

        if ($stmt->execute()) {
            $this->assignment_id = $this->conn->lastInsertId();
            return true;
        }
        return false;
    }

    public function getByProjectId($project_id) {
        $query = "SELECT pm.*, 
                         CONCAT(m.first_name, ' ', m.last_name) as member_name,
                         m.email as member_email,
                         m.position as member_position,
                         m.department as member_department
                  FROM " . $this->table . " pm
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