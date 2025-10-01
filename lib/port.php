<?php
// Database connection
$host = 'localhost';
$dbname = 'portfolio_db';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]));
}

// Enable CORS (adjust as needed for production)
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Start session for admin authentication
session_start();

// Handle API requests
$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'] ?? '', '/'));

// API Endpoints
switch ($request[0]) {
    case 'login':
        if ($method === 'POST') {
            $data = json_decode(file_get_contents('php://input'), true);
            $admin_username = $data['username'] ?? '';
            $admin_password = $data['password'] ?? '';

            // Simple admin check (in production, use hashed passwords)
            if ($admin_username === 'admin' && $admin_password === 'admin123') {
                $_SESSION['admin'] = true;
                echo json_encode(['message' => 'Login successful']);
            } else {
                http_response_code(401);
                echo json_encode(['error' => 'Invalid credentials']);
            }
        }
        break;

    case 'portfolio':
        // Check if admin is logged in
        if (!isset($_SESSION['admin'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized']);
            exit;
        }

        if ($method === 'POST') {
            // Add portfolio item
            $data = json_decode(file_get_contents('php://input'), true);
            $title = $data['title'] ?? '';
            $description = $data['description'] ?? '';
            $image = $data['image'] ?? ''; // Assuming base64 encoded image or URL

            if (empty($title) || empty($description)) {
                http_response_code(400);
                echo json_encode(['error' => 'Title and description are required']);
                exit;
            }

            try {
                $stmt = $pdo->prepare('INSERT INTO portfolio (title, description, image) VALUES (:title, :description, :image)');
                $stmt->execute([
                    'title' => $title,
                    'description' => $description,
                    'image' => $image
                ]);
                echo json_encode(['message' => 'Portfolio item added successfully']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Failed to add portfolio item: ' . $e->getMessage()]);
            }
        } elseif ($method === 'GET') {
            // Get all portfolio items
            try {
                $stmt = $pdo->query('SELECT * FROM portfolio');
                $portfolio = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo json_encode($portfolio);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Failed to fetch portfolio: ' . $e->getMessage()]);
            }
        } elseif ($method === 'PUT' && isset($request[1])) {
            // Update portfolio item
            $id = $request[1];
            $data = json_decode(file_get_contents('php://input'), true);
            $title = $data['title'] ?? '';
            $description = $data['description'] ?? '';
            $image = $data['image'] ?? '';

            if (empty($title) || empty($description)) {
                http_response_code(400);
                echo json_encode(['error' => 'Title and description are required']);
                exit;
            }

            try {
                $stmt = $pdo->prepare('UPDATE portfolio SET title = :title, description = :description, image = :image WHERE id = :id');
                $stmt->execute([
                    'title' => $title,
                    'description' => $description,
                    'image' => $image,
                    'id' => $id
                ]);
                echo json_encode(['message' => 'Portfolio item updated successfully']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Failed to update portfolio item: ' . $e->getMessage()]);
            }
        } elseif ($method === 'DELETE' && isset($request[1])) {
            // Delete portfolio item
            $id = $request[1];
            try {
                $stmt = $pdo->prepare('DELETE FROM portfolio WHERE id = :id');
                $stmt->execute(['id' => $id]);
                echo json_encode(['message' => 'Portfolio item deleted successfully']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Failed to delete portfolio item: ' . $e->getMessage()]);
            }
        }
        break;

    case 'logout':
        if ($method === 'POST') {
            session_destroy();
            echo json_encode(['message' => 'Logged out successfully']);
        }
        break;

    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
        break;
}
?>