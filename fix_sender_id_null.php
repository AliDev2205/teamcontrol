<?php
// fix_sender_id_null.php
require_once 'apis/api/config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Erreur de connexion à la base de données");
}

try {
    // 1. Vérifier la structure actuelle de la colonne sender_id
    $stmt = $db->query("SHOW COLUMNS FROM notifications WHERE Field = 'sender_id'");
    $columnInfo = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "<h2>Structure actuelle de la colonne sender_id :</h2>";
    echo "<pre>";
    print_r($columnInfo);
    echo "</pre>";
    
    // 2. Vérifier si la colonne peut être NULL
    $isNullable = ($columnInfo['Null'] === 'YES');
    
    if (!$isNullable) {
        echo "<h3>La colonne sender_id n'accepte pas les valeurs NULL. Modification en cours...</h3>";
        
        // Désactiver temporairement les vérifications de clés étrangères
        $db->exec("SET FOREIGN_KEY_CHECKS=0;");
        
        // Modifier la colonne pour accepter NULL
        $alterQuery = "ALTER TABLE `notifications` 
                      MODIFY COLUMN `sender_id` INT NULL COMMENT 'Qui a déclenché la notification'";
        
        $db->exec($alterQuery);
        
        // Réactiver les vérifications de clés étrangères
        $db->exec("SET FOREIGN_KEY_CHECKS=1;");
        
        echo "<p style='color: green;'>✓ La colonne sender_id a été modifiée pour accepter les valeurs NULL.</p>";
        
        // Vérifier à nouveau la structure
        $stmt = $db->query("SHOW COLUMNS FROM notifications WHERE Field = 'sender_id'");
        $updatedColumnInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo "<h3>Nouvelle structure de la colonne sender_id :</h3>";
        echo "<pre>";
        print_r($updatedColumnInfo);
        echo "</pre>";
    } else {
        echo "<p style='color: green;'>La colonne sender_id accepte déjà les valeurs NULL. Aucune modification nécessaire.</p>";
    }
    
    // Vérifier les contraintes de clé étrangère
    $stmt = $db->query("
        SELECT 
            TABLE_NAME,
            COLUMN_NAME,
            CONSTRAINT_NAME,
            REFERENCED_TABLE_NAME,
            REFERENCED_COLUMN_NAME
        FROM 
            INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE 
            TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'notifications'
            AND COLUMN_NAME = 'sender_id'
    ");
    
    $constraints = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<h2>Contraintes pour sender_id :</h2>";
    echo "<pre>";
    print_r($constraints);
    echo "</pre>";
    
    echo "<h2>Prochaines étapes :</h2>";
    echo "<ol>";
    echo "<li>Si vous voyez un message de succès en vert, la colonne est maintenant correctement configurée.</li>";
    echo "<li>Vous pouvez essayer à nouveau de marquer une phase comme terminée.</li>";
    echo "<li>Si vous rencontrez d'autres erreurs, veuillez me les communiquer.</li>";
    echo "</ol>";
    
} catch (PDOException $e) {
    echo "<div style='color: red; padding: 15px; border: 1px solid #f5c6cb; background-color: #f8d7da; border-radius: 4px;'>";
    echo "<h3>Erreur :</h3>";
    echo "<p><strong>Message d'erreur :</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
    
    $errorInfo = $db->errorInfo();
    if (!empty($errorInfo)) {
        echo "<p><strong>Détails de l'erreur :</strong></p>";
        echo "<pre>";
        print_r($errorInfo);
        echo "</pre>";
    }
    
    echo "</div>";
}

// Lien pour vérifier la structure complète de la table
echo "<div style='margin-top: 20px;'>";
echo "<a href='check_notifications_table.php' style='padding: 10px 15px; background-color: #28a745; color: white; text-decoration: none; border-radius: 4px;'>";
echo "Vérifier la structure complète de la table notifications";
echo "</a>";
echo "</div>";
?>
