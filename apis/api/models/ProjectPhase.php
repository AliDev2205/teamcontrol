<?php
// api/models/ProjectPhase.php
class ProjectPhase {
    private $conn;
    private $table = "project_phases";

    public $phase_id;
    public $project_id;
    public $title;
    public $description;
    public $start_date;
    public $end_date;
    public $status;
    public $order_number;
    public $created_at;
    public $updated_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Créer une nouvelle phase
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (project_id, title, description, start_date, end_date, status, order_number)
                  VALUES
                  (:project_id, :title, :description, :start_date, :end_date, :status, :order_number)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":project_id", $this->project_id);
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":start_date", $this->start_date);
        $stmt->bindParam(":end_date", $this->end_date);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":order_number", $this->order_number);

        if ($stmt->execute()) {
            $this->phase_id = $this->conn->lastInsertId();
            return true;
        }
        return false;
    }

    /**
     * Récupérer toutes les phases d'un projet
     */
    public function getByProjectId($project_id) {
        $query = "SELECT * FROM " . $this->table . "
                  WHERE project_id = :project_id
                  ORDER BY order_number ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":project_id", $project_id);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Mettre à jour le statut d'une phase
     */
    public function updateStatus() {
        $query = "UPDATE " . $this->table . "
                  SET status = :status, updated_at = NOW()
                  WHERE phase_id = :phase_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":status", $this->status);
        $stmt->bindParam(":phase_id", $this->phase_id);

        return $stmt->execute();
    }

    /**
     * Récupérer une phase par son ID
     */
    public function getById() {
        $query = "SELECT * FROM " . $this->table . "
                  WHERE phase_id = :phase_id
                  LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":phase_id", $this->phase_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch();
            $this->project_id = $row['project_id'];
            $this->title = $row['title'];
            $this->description = $row['description'];
            $this->start_date = $row['start_date'];
            $this->end_date = $row['end_date'];
            $this->status = $row['status'];
            $this->order_number = $row['order_number'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }
}
?>