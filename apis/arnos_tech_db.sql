-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 29 oct. 2025 à 18:14
-- Version du serveur : 8.2.0
-- Version de PHP : 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `arnos_tech_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT 'Membre ou admin qui a fait l''action',
  `user_type` enum('admin','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Détails de l''action',
  `project_id` int DEFAULT NULL COMMENT 'Projet concerné',
  `phase_id` int DEFAULT NULL COMMENT 'Phase concernée',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_type` (`user_type`),
  KEY `idx_action` (`action`),
  KEY `idx_project_id` (`project_id`),
  KEY `idx_phase_id` (`phase_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `activity_logs`
--

INSERT INTO `activity_logs` (`log_id`, `user_id`, `user_type`, `action`, `description`, `project_id`, `phase_id`, `created_at`) VALUES
(1, 1, 'admin', 'Création de projet', 'Projet \"Site Web Arnos Tech V2\" créé', 1, NULL, '2025-10-27 09:07:31'),
(2, 1, 'admin', 'Attribution de membre', 'John Doe assigné au projet', 1, NULL, '2025-10-27 09:07:31'),
(3, 3, 'member', 'Mise à jour de progrès', 'Planification terminée', 1, 1, '2025-10-27 09:07:31'),
(4, 4, 'member', 'Mise à jour de progrès', 'Maquettes en cours', 1, 2, '2025-10-27 09:07:31');

-- --------------------------------------------------------

--
-- Structure de la table `members`
--

DROP TABLE IF EXISTS `members`;
CREATE TABLE IF NOT EXISTS `members` (
  `member_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'member',
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `date_joined` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_email` (`email`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `members`
--

INSERT INTO `members` (`member_id`, `first_name`, `last_name`, `email`, `phone`, `position`, `department`, `employee_id`, `password`, `photo`, `role`, `status`, `date_joined`, `updated_at`) VALUES
(1, 'Admin', 'Arnos Tech', 'admin@arnostech.com', '+2290165302251', 'Directeur Général', 'Direction', 'EMP001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'admin', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30'),
(2, 'Admin2', 'Secondary', 'admin2@arnostech.com', '+2290165302252', 'Directeur Technique', 'Direction', 'EMP001B', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'admin', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30'),
(3, 'John', 'Doe', 'jean.dupont@arnostech.com', '+22912345678', 'Développeur Senior', 'IT', 'EMP002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'member', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30'),
(4, 'Marie', 'Martin', 'marie.martin@arnostech.com', '+22901234568', 'Designer', 'Design', 'EMP003', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'member', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30'),
(5, 'Test', 'User', 'test@arnostech.com', '+22912345678', 'Testeur', 'QA', 'EMP010', '$2y$10$h0lLEpWvBAUqJ5RP323.guFgAiBvnYg.A/3mHm5fUhHYCgWqz.FqS', NULL, 'member', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30'),
(6, 'Emmanuel', 'SANTOS', 'es8726504@gmail.com', '+2290167702887', 'Développeur', 'Service technique', '#2', '$2y$10$1M4q1Vkpj2OYPug4wFm5r.JZWBUnlWilBmoXT8nmx1gX2NSN/LeWS', NULL, 'member', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30'),
(7, 'Alimi', 'LAMIDI', 'alimilamidi24@gmail.com', '+2290195777408', 'Développeur', 'Développement', 'EMP009', '$2y$10$Oe5vnjgvr4IcLuZ/v4FTKOclG0WsOdyPTYOoPKXHuOKNbgkT5CbdG', NULL, 'member', 'active', '2025-10-27 09:07:30', '2025-10-27 12:04:19'),
(8, 'Enirack', 'DADA', 'jerry@gmail.com', '+2290196016933', 'Développeur mobile', 'IT', 'EMPOO8', '$2y$10$EQA3v3fSe0Tmkh4dkshzfubuXTQp6jrkYqCAQ5jvnjL/SZoZqxNeq', NULL, 'member', 'active', '2025-10-27 09:07:30', '2025-10-27 09:07:30');

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `receiver_id` int NOT NULL COMMENT 'Membre ou admin qui reçoit',
  `sender_id` int DEFAULT NULL COMMENT 'Qui a déclenché la notification',
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('assignment','update','phase_complete','project_complete','member_added','admin_comment') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_project_id` int DEFAULT NULL COMMENT 'Projet concerné',
  `related_phase_id` int DEFAULT NULL COMMENT 'Phase concernée',
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_related_project` (`related_project_id`),
  KEY `idx_related_phase` (`related_phase_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `receiver_id`, `sender_id`, `message`, `type`, `related_project_id`, `related_phase_id`, `is_read`, `created_at`) VALUES
(1, 3, 1, 'Vous avez été assigné au projet \"Site Web Arnos Tech V2\"', 'assignment', 1, NULL, 0, '2025-10-27 09:07:31'),
(2, 4, 1, 'Vous avez été assignée au projet \"Site Web Arnos Tech V2\"', 'assignment', 1, NULL, 0, '2025-10-27 09:07:31'),
(3, 1, 4, 'Phase \"Design UI/UX\" mise à jour par Marie Martin', 'update', 1, 2, 1, '2025-10-27 09:07:31'),
(4, 1, 3, 'Phase \"Planification\" marquée comme terminée', 'phase_complete', 1, 1, 1, '2025-10-27 09:07:31');

-- --------------------------------------------------------

--
-- Structure de la table `progress`
--

DROP TABLE IF EXISTS `progress`;
CREATE TABLE IF NOT EXISTS `progress` (
  `progress_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL,
  `phase_id` int DEFAULT NULL COMMENT 'Phase concernée (nullable pour progrès général)',
  `member_id` int NOT NULL,
  `update_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_added` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_final` tinyint(1) DEFAULT '0' COMMENT 'Marque si la phase/projet est terminé',
  PRIMARY KEY (`progress_id`),
  KEY `idx_project_id` (`project_id`),
  KEY `idx_phase_id` (`phase_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_date_added` (`date_added`),
  KEY `idx_is_final` (`is_final`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `progress`
--

INSERT INTO `progress` (`progress_id`, `project_id`, `phase_id`, `member_id`, `update_text`, `date_added`, `is_final`) VALUES
(1, 1, 1, 3, 'Planification terminée. Architecture validée avec l\'équipe.', '2025-10-27 09:07:31', 1),
(2, 1, 2, 4, 'Maquettes de la page d\'accueil terminées. En cours de validation.', '2025-10-27 09:07:31', 0),
(3, 1, 2, 4, 'Corrections apportées selon les retours. Maquettes finalisées.', '2025-10-27 09:07:31', 0),
(4, 1, NULL, 6, 'Mise en place de l\'environnement de développement.', '2025-10-27 09:07:31', 0);

-- --------------------------------------------------------

--
-- Structure de la table `projects`
--

DROP TABLE IF EXISTS `projects`;
CREATE TABLE IF NOT EXISTS `projects` (
  `project_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int NOT NULL COMMENT 'Admin qui a créé le projet',
  `status` enum('pending','in_progress','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`project_id`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_status` (`status`),
  KEY `idx_dates` (`start_date`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `projects`
--

INSERT INTO `projects` (`project_id`, `title`, `description`, `created_by`, `status`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
(1, 'Site Web Arnos Tech V2', 'Refonte complète du site web de l\'entreprise avec nouvelles fonctionnalités', 1, 'in_progress', '2025-10-01', '2025-12-31', '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(2, 'Application Mobile Collaborative', 'App mobile pour la gestion de projets en équipe', 2, 'pending', '2025-11-01', '2026-02-28', '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(3, 'Plateforme E-learning', 'Système de formation en ligne pour les employés', 1, 'pending', '2025-11-15', '2026-01-15', '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(5, 'Test Simple', 'Test Description', 1, 'pending', '2025-10-27', NULL, '2025-10-27 16:25:05', '2025-10-27 16:25:05'),
(6, 'Application mobile de vente d\'eau et de jus de fruits', 'Créer une application mobile qui permet au producteur d\'eau et de jus de fruits de présenter, vendre et gérer facilement ses produits tout en offrant aux clients la possibilité de voir, de choisir, de commander et payer en ligne ou à la livraison', 1, 'pending', '2025-10-28', '2025-10-31', '2025-10-28 09:53:15', '2025-10-28 09:53:15');

-- --------------------------------------------------------

--
-- Structure de la table `project_members`
--

DROP TABLE IF EXISTS `project_members`;
CREATE TABLE IF NOT EXISTS `project_members` (
  `assignment_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL,
  `member_id` int NOT NULL,
  `assigned_by` int NOT NULL COMMENT 'Admin qui a fait l''attribution',
  `assigned_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Membre toujours assigné au projet',
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `unique_project_member` (`project_id`,`member_id`),
  KEY `idx_project_id` (`project_id`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_assigned_by` (`assigned_by`),
  KEY `idx_assigned_date` (`assigned_date`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `project_members`
--

INSERT INTO `project_members` (`assignment_id`, `project_id`, `member_id`, `assigned_by`, `assigned_date`, `is_active`) VALUES
(1, 1, 7, 1, '2025-10-27 09:07:31', 1),
(2, 1, 4, 1, '2025-10-27 09:07:31', 1),
(3, 1, 6, 1, '2025-10-27 09:07:31', 1),
(4, 2, 3, 2, '2025-10-27 09:07:31', 1),
(5, 2, 8, 2, '2025-10-27 09:07:31', 1),
(6, 3, 4, 1, '2025-10-27 09:07:31', 1),
(7, 3, 5, 1, '2025-10-27 09:07:31', 1),
(8, 1, 3, 1, '2025-10-28 10:12:00', 1),
(9, 6, 7, 1, '2025-10-28 10:41:52', 1),
(10, 6, 5, 1, '2025-10-28 10:41:52', 1);

-- --------------------------------------------------------

--
-- Structure de la table `project_phases`
--

DROP TABLE IF EXISTS `project_phases`;
CREATE TABLE IF NOT EXISTS `project_phases` (
  `phase_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('pending','in_progress','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `order_number` int NOT NULL DEFAULT '1' COMMENT 'Ordre d''exécution des phases',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`phase_id`),
  KEY `idx_project_id` (`project_id`),
  KEY `idx_status` (`status`),
  KEY `idx_order` (`order_number`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `project_phases`
--

INSERT INTO `project_phases` (`phase_id`, `project_id`, `title`, `description`, `start_date`, `end_date`, `status`, `order_number`, `created_at`, `updated_at`) VALUES
(1, 1, 'Planification', 'Analyse des besoins et architecture', NULL, NULL, 'completed', 1, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(2, 1, 'Design UI/UX', 'Conception des maquettes et interfaces', NULL, NULL, 'in_progress', 2, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(3, 1, 'Développement Frontend', 'Intégration des pages web', NULL, NULL, 'pending', 3, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(4, 1, 'Développement Backend', 'API et base de données', NULL, NULL, 'pending', 4, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(5, 1, 'Tests et Déploiement', 'Tests qualité et mise en production', NULL, NULL, 'pending', 5, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(6, 2, 'Étude de faisabilité', 'Recherche et analyse technique', NULL, NULL, 'pending', 1, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(7, 2, 'Prototypage', 'Création des premiers prototypes', NULL, NULL, 'pending', 2, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(8, 3, 'Cahier des charges', 'Spécifications fonctionnelles', NULL, NULL, 'pending', 1, '2025-10-27 09:07:31', '2025-10-27 09:07:31'),
(9, 6, 'Phase 1', '1.1- Inscription/Connexion\n1.2- Interface admin\n1.3- Interface client\n1.4- Choix du design\n1.5- Intégration dynamique (PHP)\n1.6- CRUD Admin (Produits)\n1.7- Rendre dynamique l\'interface admin\n1.8- Récupération dynamique de produits', NULL, NULL, 'pending', 1, '2025-10-28 09:53:15', '2025-10-28 09:53:15'),
(10, 6, 'Phase 2', '2.1- Ajout au panier\n2.2- Passer une commande\n2.3- Validation de la commande (Physique)\n2.4- Récupération des commandes\n2.5- Suivi et gestion des commandes\n2.6- Suivi et historique des commandes\n2.7- Commande spéciale (Client)\n2.8- Récupération de commande spéciale par l\'admin\n2.9- Gestion du stock\n2.10- Génération de facture', NULL, NULL, 'pending', 2, '2025-10-28 09:53:15', '2025-10-28 09:53:15'),
(11, 6, 'Phase 3', '3.1- Paiement en ligne\n3.2- Notification push\n3.3- Génération de rapport (admin)\n3.4- Promotion et réduction\n3.5- Personnaliser une notification\n3.6- Récupération du mot de passe\n3.7- Modification du profil utilisateur', NULL, NULL, 'pending', 3, '2025-10-28 09:53:15', '2025-10-28 09:53:15'),
(12, 6, 'Phase 4', 'Test', NULL, NULL, 'pending', 4, '2025-10-28 09:53:15', '2025-10-28 09:53:15');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_activity_logs_phase` FOREIGN KEY (`phase_id`) REFERENCES `project_phases` (`phase_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_activity_logs_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_activity_logs_user` FOREIGN KEY (`user_id`) REFERENCES `members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_phase` FOREIGN KEY (`related_phase_id`) REFERENCES `project_phases` (`phase_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_notifications_project` FOREIGN KEY (`related_project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_notifications_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_notifications_sender` FOREIGN KEY (`sender_id`) REFERENCES `members` (`member_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `progress`
--
ALTER TABLE `progress`
  ADD CONSTRAINT `fk_progress_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_progress_phase` FOREIGN KEY (`phase_id`) REFERENCES `project_phases` (`phase_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_progress_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `fk_projects_created_by` FOREIGN KEY (`created_by`) REFERENCES `members` (`member_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Contraintes pour la table `project_members`
--
ALTER TABLE `project_members`
  ADD CONSTRAINT `fk_project_members_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `members` (`member_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_project_members_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_project_members_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `project_phases`
--
ALTER TABLE `project_phases`
  ADD CONSTRAINT `fk_phases_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
