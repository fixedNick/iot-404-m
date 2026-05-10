CREATE TABLE IF NOT EXISTS wind_speed (
    id INT AUTO_INCREMENT PRIMARY KEY,
    voltage FLOAT NOT NULL,
    speed FLOAT NOT NULL,
    ts BIGINT UNSIGNED NOT NULL
);

CREATE TABLE IF NOT EXISTS temperature (
    id INT AUTO_INCREMENT PRIMARY KEY,
    val FLOAT NOT NULL,
    ts BIGINT UNSIGNED NOT NULL
);

CREATE TABLE IF NOT EXISTS humidity (
    id INT AUTO_INCREMENT PRIMARY KEY,
    val FLOAT NOT NULL,
    ts BIGINT UNSIGNED NOT NULL
);

CREATE TABLE IF NOT EXISTS auto_collect_status (
    sensor_id INT NOT NULL,
    sensor_name VARCHAR(128) NOT NULL,
    sensor_status TINYINT(1) NOT NULL,
    UNIQUE (sensor_id)
);

INSERT INTO auto_collect_status (sensor_id, sensor_name, sensor_status) VALUES 
(1, 'temperature', 0),
(2, 'wind_speed', 0),
(3, 'humidity', 0);