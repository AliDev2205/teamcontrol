<?php
class Notification {
    private $conn;
    private $table = "notifications";

    public $notification_id;
    public $receiver_id;
    public $sender_id;
    public $message;
    public $type;
    public $related_project_id;
    public $related_phase_id;
    public $is_read;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Récupérer les notifications d'un membre
     */
    public function getByMemberId($member_id) {
        $query = "SELECT n.*, 
                         CONCAT(s.first_name, ' ', s.last_name) as sender_name,
                         p.title as project_title,
                         ph.title as phase_title
                  FROM " . $this->table . " n
                  LEFT JOIN members s ON n.sender_id = s.member_id
                  LEFT JOIN projects p ON n.related_project_id = p.project_id
                  LEFT JOIN project_phases ph ON n.related_phase_id = ph.phase_id
                  WHERE n.receiver_id = :receiver_id
                  ORDER BY n.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":receiver_id", $member_id);
        $stmt->execute();
        return $stmt;
    }

    /**
     * Marquer une notification comme lue
     */
    public function markAsRead() {
        $query = "UPDATE " . $this->table . "
                  SET is_read = true
                  WHERE notification_id = :notification_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":notification_id", $this->notification_id);

        return $stmt->execute();
    }

    /**
     * Créer une nouvelle notification
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (receiver_id, sender_id, message, type, related_project_id, related_phase_id)
                  VALUES
                  (:receiver_id, :sender_id, :message, :type, :related_project_id, :related_phase_id)";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":receiver_id", $this->receiver_id);
        $stmt->bindParam(":sender_id", $this->sender_id);
        $stmt->bindParam(":message", $this->message);
        $stmt->bindParam(":type", $this->type);
        $stmt->bindParam(":related_project_id", $this->related_project_id);
        $stmt->bindParam(":related_phase_id", $this->related_phase_id);

        if ($stmt->execute()) {
            $this->notification_id = $this->conn->lastInsertId();
            return true;
        }
        return false;
    }
}
?>