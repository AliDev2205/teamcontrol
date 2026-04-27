<?php
// fix_notification_constraint.php
require_once 'apis/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Erreur de connexion à la base de données");
}

try {
    // 1. Récupérer le nom de la contrainte
    $query = "SELECT 
                CONSTRAINT_NAME
              FROM 
                INFORMATION_SCHEMA.KEY_COLUMN_USAGE
              WHERE 
                TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'notifications'
                AND COLUMN_NAME = 'sender_id'
                AND REFERENCED_TABLE_NAME = 'members'";
    
    $stmt = $db->query($query);
    $constraint = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$constraint) {
        die("Aucune contrainte de clé étrangère trouvée pour sender_id dans la table notifications");
    }
    
    $constraintName = $constraint['CONSTRAINT_NAME'];
    
    echo "<h2>Contrainte à modifier : " . htmlspecialchars($constraintName) . "</h2>";
    
    // 2. Préparer les requêtes
    $queries = [
        "SET FOREIGN_KEY_CHECKS=0;",
        "ALTER TABLE `notifications` DROP FOREIGN KEY `$constraintName`;",
        "ALTER TABLE `notifications` MODIFY COLUMN `sender_id` INT NULL;",
        "ALTER TABLE `notifications` 
         ADD CONSTRAINT `$constraintName` 
         FOREIGN KEY (`sender_id`) 
         REFERENCES `members` (`member_id`) 
         ON DELETE SET NULL 
         ON UPDATE CASCADE;",
        "UPDATE `notifications` n1
         LEFT JOIN `members` m ON n1.`sender_id` = m.`member_id`
         SET n1.`sender_id` = NULL 
         WHERE m.`member_id` IS NULL AND n1.`sender_id` IS NOT NULL;",
        "SET FOREIGN_KEY_CHECKS=1;"
    ];
    
    echo "<h2>Requêtes SQL à exécuter :</h2>";
    echo "<pre>" . implode("\n\n", $queries) . "</pre>";
    
    // Exécuter les requêtes
    foreach ($queries as $query) {
        try {
            $db->exec($query);
            echo "<p style='color: green;'>✓ Exécutée avec succès : " . htmlspecialchars(substr($query, 0, 100)) . "...</p>";
        } catch (PDOException $e) {
            echo "<p style='color: orange;'>⚠ Erreur lors de l'exécution de : " . htmlspecialchars(substr($query, 0, 100)) . "...<br>";
            echo "Erreur : " . htmlspecialchars($e->getMessage()) . "</p>";
            // Ne pas arrêter en cas d'erreur, continuer avec les requêtes suivantes
        }
    }
    
    // Vérifier les notifications sans expéditeur valide
    try {
        $query = "SELECT COUNT(*) as invalid_senders 
                 FROM `notifications` n
                 LEFT JOIN `members` m ON n.`sender_id` = m.`member_id`
                 WHERE n.`sender_id` IS NOT NULL 
                 AND m.`member_id` IS NULL";
        
        $stmt = $db->query($query);
        $invalidSenders = $stmt->fetch(PDO::FETCH_ASSOC);
        $invalidCount = $invalidSenders ? $invalidSenders['invalid_senders'] : 0;
        
        echo "<h2>Résultats :</h2>";
        echo "<p>Contrainte mise à jour avec succès.</p>";
        echo "<p>Nombre d'expéditeurs invalides : " . $invalidCount . " (ont été mis à jour à NULL si nécessaire)</p>";
    } catch (PDOException $e) {
        echo "<p style='color: orange;'>⚠ Impossible de vérifier les expéditeurs invalides : " . 
             htmlspecialchars($e->getMessage()) . "</p>";
    }  
} catch (PDOException $e) {
    echo "<div style='color: red; padding: 15px; border: 1px solid #f5c6cb; background-color: #f8d7da; border-radius: 4px;'>";
    echo "<h3>Erreur lors de la modification de la contrainte :</h3>";
    echo "<p><strong>Message d'erreur :</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p><strong>Code d'erreur :</strong> " . $e->getCode() . "</p>";
    echo "</div>";
    
    // Afficher la structure de la table pour le débogage
    try {
        $stmt = $db->query("SHOW CREATE TABLE notifications");
        $table = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "<h3>Structure actuelle de la table :</h3>";
        echo "<pre>" . htmlspecialchars($table['Create Table']) . "</pre>";
    } catch (PDOException $e2) {
        echo "<p>Impossible de récupérer la structure de la table : " . htmlspecialchars($e2->getMessage()) . "</p>";
    }
    
    // Afficher les contraintes actuelles
    try {
        $stmt = $db->query("
            SELECT * FROM information_schema.TABLE_CONSTRAINTS 
            WHERE table_schema = DATABASE() 
            AND table_name = 'notifications'
        ");
        $constraints = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "<h3>Contraintes actuelles :</h3>";
        echo "<pre>";
        print_r($constraints);
        echo "</pre>";
    } catch (PDOException $e2) {
        echo "<p>Impossible de récupérer les contraintes : " . htmlspecialchars($e2->getMessage()) . "</p>";
    }
    
    // Afficher les clés étrangères
    try {
        $stmt = $db->query("
            SELECT * FROM information_schema.KEY_COLUMN_USAGE 
            WHERE table_schema = DATABASE() 
            AND table_name = 'notifications'
            AND referenced_table_name IS NOT NULL
        ");
        $fks = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "<h3>Clés étrangères actuelles :</h3>";
        echo "<pre>";
        print_r($fks);
        echo "</pre>";
    } catch (PDOException $e2) {
        echo "<p>Impossible de récupérer les clés étrangères : " . htmlspecialchars($e2->getMessage()) . "</p>";
    }
}