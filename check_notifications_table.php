<?php
// check_notifications_table.php
require_once 'apis/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Erreur de connexion à la base de données");
}

try {
    // Vérifier si la table notifications existe
    $checkTable = $db->query("SHOW TABLES LIKE 'notifications'");
    
    if ($checkTable->rowCount() === 0) {
        die("La table 'notifications' n'existe pas dans la base de données.");
    }
    
    // Afficher la structure de la table
    $stmt = $db->query("DESCRIBE notifications");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<h2>Structure de la table notifications :</h2>";
    echo "<pre>";
    print_r($columns);
    echo "</pre>";
    
    // Vérifier les colonnes requises
    $requiredColumns = [
        'receiver_id' => false,
        'sender_id' => false,
        'message' => false,
        'type' => false,
        'related_project_id' => false,
        'related_phase_id' => false,
        'is_read' => false
    ];
    
    foreach ($columns as $column) {
        if (array_key_exists($column['Field'], $requiredColumns)) {
            $requiredColumns[$column['Field']] = true;
        }
    }
    
    // Afficher les colonnes manquantes
    $missingColumns = [];
    foreach ($requiredColumns as $column => $exists) {
        if (!$exists) {
            $missingColumns[] = $column;
        }
    }
    
    if (count($missingColumns) > 0) {
        echo "<div style='color: red;'>";
        echo "<h3>Colonnes manquantes dans la table 'notifications' :</h3>";
        echo "<ul>";
        foreach ($missingColumns as $column) {
            echo "<li>$column</li>";
        }
        echo "</ul>";
        echo "</div>";
        
        echo "<h3>Solution :</h3>";
        echo "<p>Exécutez la requête SQL suivante pour ajouter les colonnes manquantes :</p>";
        echo "<pre>";
        echo "-- Assurez-vous d'abord que la table existe\n";
        echo "CREATE TABLE IF NOT EXISTS `notifications` (\n";
        echo "  `notification_id` int NOT NULL AUTO_INCREMENT,\n";
        echo "  `receiver_id` int NOT NULL,\n";
        echo "  `sender_id` int DEFAULT NULL,\n";
        echo "  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,\n";
        echo "  `type` enum('assignment','update','phase_complete','project_complete','member_added','admin_comment','progress_validation') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,\n";
        echo "  `related_project_id` int DEFAULT NULL,\n";
        echo "  `related_phase_id` int DEFAULT NULL,\n";
        echo "  `is_read` tinyint(1) NOT NULL DEFAULT '0',\n";
        echo "  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,\n";
        echo "  PRIMARY KEY (`notification_id`),\n";
        echo "  KEY `receiver_id` (`receiver_id`),\n";
        echo "  KEY `sender_id` (`sender_id`),\n";
        echo "  KEY `related_project_id` (`related_project_id`),\n";
        echo "  KEY `related_phase_id` (`related_phase_id`),\n";
        echo "  KEY `is_read` (`is_read`),\n";
        echo "  KEY `created_at` (`created_at`),\n";
        echo "  KEY `type` (`type`)\n";
        echo ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n";
        echo "</pre>";
    } else {
        echo "<p style='color: green;'>Toutes les colonnes requises sont présentes dans la table 'notifications'.</p>";
    }
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>Erreur PDO : " . $e->getMessage() . "</p>";
}
?>
