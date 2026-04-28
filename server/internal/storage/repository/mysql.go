package repository

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	dbmodels "server/internal/storage/models"
)

// TODO:
// Save methods is `async safe`, based on buffered channels to stick to saving order
// ----
// NOT ASYNC RN
type MysqlRepository struct {
	db *sql.DB

	// windSave    chan dbmodels.WindSpeed
	// tempSave    chan dbmodels.WindSpeed
	// humidiySave chan dbmodels.WindSpeed
}

func (m *MysqlRepository) Close() {
	if err := m.db.Close(); err != nil {
		log.Printf("Error on close db: %v\n", err)
	}
}
func InitDB(dsn string) (*sql.DB, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}
func NewMysqlRepository(db *sql.DB) *MysqlRepository {
	return &MysqlRepository{
		db: db,
	}
}

func (r *MysqlRepository) SaveWindSpeed(ctx context.Context, data dbmodels.WindSpeed) error {
	query := `INSERT INTO wind_speed (voltage, speed, ts) VALUES (?, ?, ?)`
	_, err := r.db.ExecContext(ctx, query, data.Voltage, data.Speed, data.Time)
	if err != nil {
		return fmt.Errorf("failed to save wind speed: %w", err)
	}
	return nil
}
func (r *MysqlRepository) SaveTemperature(ctx context.Context, data dbmodels.Temperature) error {
	query := `INSERT INTO temperature (val, ts) VALUES (?, ?)`
	_, err := r.db.ExecContext(ctx, query, data.Temperature, data.Time)
	if err != nil {
		return fmt.Errorf("failed to save temperature: %w", err)
	}
	return nil
}
func (r *MysqlRepository) SaveHumidity(ctx context.Context, data dbmodels.Humidity) error {
	query := `INSERT INTO humidity (val, ts) VALUES (?, ?)`
	_, err := r.db.ExecContext(ctx, query, data.Humidity, data.Time)
	if err != nil {
		return fmt.Errorf("failed to save humidity: %w", err)
	}
	return nil
}

// GetWindSpeed returns slice of WindSpeed
// limit is <= 0 returns All rows
// Otherwise returns last 'limit' rows
func (r *MysqlRepository) GetWindSpeed(ctx context.Context, limit int) ([]dbmodels.WindSpeed, error) {
	var query string
	if limit > 0 {
		query = `SELECT voltage, speed, ts FROM wind_speed ORDER BY id DESC LIMIT ?;`
	} else {
		query = `SELECT voltage, speed, ts FROM wind_speed ORDER BY id DESC;`
	}

	ws := make([]dbmodels.WindSpeed, 0, limit)
	rows, err := r.db.QueryContext(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var w dbmodels.WindSpeed
		err := rows.Scan(&w.Voltage, &w.Speed, &w.Time)
		if err != nil {
			return nil, err
		}
		ws = append(ws, w)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	if len(ws) == 0 {
		return nil, fmt.Errorf("Database(windspeed) is empty")
	}
	return ws, nil
}

// GetTemperature returns slice of Temperature
// limit is <= 0 returns All rows
// Otherwise returns last 'limit' rows
func (r *MysqlRepository) GetTemperature(ctx context.Context, limit int) ([]dbmodels.Temperature, error) {
	var query string
	if limit > 0 {
		query = `SELECT val, ts FROM temperature ORDER BY id DESC LIMIT ?;`
	} else {
		query = `SELECT val, ts FROM temperature ORDER BY id DESC;`
	}

	ts := make([]dbmodels.Temperature, 0, limit)
	rows, err := r.db.QueryContext(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var t dbmodels.Temperature
		err := rows.Scan(&t.Temperature, &t.Time)
		if err != nil {
			return nil, err
		}
		ts = append(ts, t)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	if len(ts) == 0 {
		return nil, fmt.Errorf("Database(temperature) is empty")
	}
	return ts, nil
}

// GetHumidity returns slice of Humidity
// limit is <= 0 returns All rows
// Otherwise returns last 'limit' rows
func (r *MysqlRepository) GetHumidity(ctx context.Context, limit int) ([]dbmodels.Humidity, error) {
	var query string
	if limit > 0 {
		query = `SELECT val, ts FROM humidity ORDER BY id DESC LIMIT ?;`
	} else {
		query = `SELECT val, ts FROM humidity ORDER BY id DESC;`
		limit = 16
	}

	hs := make([]dbmodels.Humidity, 0, limit)
	rows, err := r.db.QueryContext(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var h dbmodels.Humidity
		err := rows.Scan(&h.Humidity, &h.Time)
		if err != nil {
			return nil, err
		}
		hs = append(hs, h)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	if len(hs) == 0 {
		return nil, fmt.Errorf("Database(humidity) is empty")
	}
	return hs, nil
}
