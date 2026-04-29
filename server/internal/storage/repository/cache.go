package repository

import (
	"fmt"
	dbmodels "server/internal/storage/models"
	"sync"
)

type LocalCache[T dbmodels.LogItem] struct {
	mu    *sync.RWMutex
	data  []T
	limit uint
}

func New[T dbmodels.LogItem](limit uint) *LocalCache[T] {
	return &LocalCache[T]{
		limit: limit,
		data:  make([]T, 0, limit),
		mu:    &sync.RWMutex{},
	}
}

func (c *LocalCache[T]) Add(item T) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if len(c.data) >= int(c.limit) {
		c.data = c.data[1:]
	}
	c.data = append(c.data, item)
}

func (c *LocalCache[T]) GetAll() []T {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.data
}

func (c *LocalCache[T]) GetLast() (T, error) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	if len(c.data) == 0 {
		var zero T
		return zero, fmt.Errorf("Cache is empty")
	}
	return c.data[len(c.data)-1], nil
}

func (c *LocalCache[T]) MaxSize() int {
	return c.MaxSize()
}
func (c *LocalCache[T]) Size() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return len(c.data)
}
