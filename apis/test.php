<?php
// api/member/test_phases.php
header('Content-Type: application/json');

$test_data = [
    "success" => true,
    "message" => "Test réussi",
    "data" => [
        [
            "phase_id" => 1,
            "project_id" => 1,
            "titre" => "Phase test",
            "description" => "Description test",
            "date_de_début" => null,
            "date_de_fin" => null,
            "statut" => "pending",
            "numéro_de_commande" => 1,
            "created_at" => "2025-10-27 00:00:00",
            "updated_at" => "2025-10-27 00:00:00"
        ]
    ]
];

echo json_encode($test_data);
?>