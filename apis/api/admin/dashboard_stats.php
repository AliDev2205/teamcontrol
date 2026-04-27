<?php
// api/admin/dashboard_stats.php
require_once '../config/headers.php';
require_once '../config/database.php';
require_once '../utils/response.php';

// Vérifier que c'est une requête GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error("Méthode non autorisée", 405);
}

// Connexion DB
$database = new Database();
$db = $database->getConnection();

try {
    // 1. Statistiques des membres
    $query = "SELECT COUNT(*) as total_members FROM members WHERE status = 'active'";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $total_members = $stmt->fetch(PDO::FETCH_ASSOC)['total_members'];

    // 2. Statistiques des projets
    $query = "SELECT 
                COUNT(*) as total_projects,
                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_projects,
                SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_projects,
                SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_projects
              FROM projects";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $project_stats = $stmt->fetch(PDO::FETCH_ASSOC);

    // 3. Projets non attribués
    $query = "SELECT COUNT(DISTINCT p.project_id) as unassigned_projects
              FROM projects p
              LEFT JOIN project_members pm ON p.project_id = pm.project_id
              WHERE pm.assignment_id IS NULL";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $unassigned_projects = $stmt->fetch(PDO::FETCH_ASSOC)['unassigned_projects'];

    // 4. Calcul avancement global (basé sur les statuts)
    $total_projects = $project_stats['total_projects'];
    $completed_projects = $project_stats['completed_projects'];
    $in_progress_projects = $project_stats['in_progress_projects'];
    
    $overall_progress = 0;
    if ($total_projects > 0) {
        $overall_progress = (($completed_projects * 100) + ($in_progress_projects * 50)) / $total_projects;
    }

    // 5. Activités récentes
    $query = "SELECT al.log_id, al.user_id, al.user_type, al.action, al.description,
                     CONCAT(m.first_name, ' ', m.last_name) as user_name,
                     al.created_at
              FROM activity_logs al
              LEFT JOIN members m ON al.user_id = m.member_id
              ORDER BY al.created_at DESC
              LIMIT 10";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $recent_activities = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Préparer la réponse
    $stats = [
        'total_members' => (int)$total_members,
        'total_projects' => (int)$project_stats['total_projects'],
        'pending_projects' => (int)$project_stats['pending_projects'],
        'in_progress_projects' => (int)$project_stats['in_progress_projects'],
        'completed_projects' => (int)$project_stats['completed_projects'],
        'unassigned_projects' => (int)$unassigned_projects,
        'overall_progress' => round($overall_progress, 2),
        'recent_activities' => $recent_activities
    ];

    Response::success("Statistiques du dashboard", $stats);

} catch (Exception $e) {
    Response::error("Erreur lors du calcul des statistiques: " . $e->getMessage(), 500);
}
?>