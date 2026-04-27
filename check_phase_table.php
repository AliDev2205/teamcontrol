<?php
// check_phase_table.php
require_once 'apis/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Erreur de connexion à la base de données");
}

try {
    // Vérifier si la table project_phases existe
    $checkTable = $db->query("SHOW TABLES LIKE 'project_phases'");
    
    if ($checkTable->rowCount() === 0) {
        die("La table 'project_phases' n'existe pas dans la base de données.");
    }
    
    // Afficher la structure de la table
    $stmt = $db->query("DESCRIBE project_phases");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<h2>Structure de la table project_phases :</h2>";
    echo "<pre>";
    print_r($columns);
    echo "</pre>";
    
    // Vérifier si la colonne updated_at existe
    $hasUpdatedAt = false;
    foreach ($columns as $column) {
        if ($column['Field'] === 'updated_at') {
            $hasUpdatedAt = true;
            break;
        }
    }
    
    if (!$hasUpdatedAt) {
        echo "<p style='color: red;'>La colonne 'updated_at' est manquante dans la table 'project_phases'.</p>";
        
        // Proposition de requête pour ajouter la colonne
        echo "<h3>Solution :</h3>";
        echo "<p>Exécutez la requête SQL suivante pour ajouter la colonne manquante :</p>";
        echo "<pre>ALTER TABLE `project_phases` ADD COLUMN `updated_at` DATETIME NULL DEFAULT NULL AFTER `created_at`;</pre>";
    } else {
        echo "<p style='color: green;'>La colonne 'updated_at' existe bien dans la table 'project_phases'.</p>";
    }
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>Erreur PDO : " . $e->getMessage() . "</p>";
}
?>
