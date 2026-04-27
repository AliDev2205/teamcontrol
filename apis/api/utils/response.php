<?php
/**
 * Fonctions utilitaires pour les réponses JSON
 */

class Response {
    
    /**
     * Réponse de succès
     */
    public static function success($message, $data = null, $code = 200) {
        http_response_code($code);
        echo json_encode([
            "success" => true,
            "message" => $message,
            "data" => $data
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Réponse d'erreur
     */
    public static function error($message, $code = 400) {
        http_response_code($code);
        echo json_encode([
            "success" => false,
            "message" => $message
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Validation des données
     */
    public static function validateRequired($data, $required_fields) {
        foreach ($required_fields as $field) {
            if (empty($data->$field)) {
                self::error("Le champ '$field' est requis");
            }
        }
    }
}
?>