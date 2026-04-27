-- Mise à jour de la colonne 'type' dans la table 'notifications' pour ajouter 'progress_validation'
ALTER TABLE `notifications` 
MODIFY COLUMN `type` ENUM(
  'assignment',
  'update',
  'phase_complete',
  'project_complete',
  'member_added',
  'admin_comment',
  'progress_validation'  -- Nouveau type ajouté
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- Création de la table progress_validations si elle n'existe pas
CREATE TABLE IF NOT EXISTS `progress_validations` (
  `validation_id` int NOT NULL AUTO_INCREMENT,
  `progress_id` int NOT NULL,
  `admin_id` int NOT NULL,
  `validation_status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  `admin_comment` text,
  `validated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`validation_id`),
  UNIQUE KEY `unique_validation` (`progress_id`, `admin_id`),
  KEY `idx_progress_id` (`progress_id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_validation_status` (`validation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
