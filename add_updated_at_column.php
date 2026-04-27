<?php
// add_updated_at_column.php
require_once 'apis/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Erreur de connexion à la base de données");
}

try {
    // Vérifier si la colonne updated_at existe déjà
    $checkColumn = $db->query("SHOW COLUMNS FROM project_phases LIKE 'updated_at'");
    
    if ($checkColumn->rowCount() === 0) {
        // La colonne n'existe pas, on l'ajoute
        $alterQuery = "ALTER TABLE `project_phases` 
                      ADD COLUMN `updated_at` DATETIME NULL DEFAULT NULL 
                      AFTER `created_at`";
        
        if ($db->exec($alterQuery) !== false) {
            echo "<p style='color: green;'>La colonne 'updated_at' a été ajoutée avec succès à la table 'project_phases'.</p>";
            
            // Mettre à jour les enregistrements existants avec la date actuelle
            $updateQuery = "UPDATE `project_phases` SET `updated_at` = NOW() WHERE `updated_at` IS NULL";
            $updated = $db->exec($updateQuery);
            
            echo "<p>Mise à jour de $updated enregistrement(s) avec la date actuelle.</p>";
        } else {
            $error = $db->errorInfo();
            throw new Exception("Erreur lors de l'ajout de la colonne: " . $error[2]);
        }
    } else {
        echo "<p>La colonne 'updated_at' existe déjà dans la table 'project_phases'.</p>";
    }
    
    // Afficher la structure mise à jour
    $stmt = $db->query("DESCRIBE project_phases");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<h2>Structure actuelle de la table project_phases :</h2>";
    echo "<pre>";
    print_r($columns);
    echo "</pre>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>Erreur PDO : " . $e->getMessage() . "</p>";
} catch (Exception $e) {
    echo "<p style='color: red;'>Erreur : " . $e->getMessage() . "</p>";
}

echo "<p><a href='check_phase_table.php'>Vérifier la structure de la table</a></p>";
?>
