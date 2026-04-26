package domain

import (
	"time"
)

// Linked list

// TODO:
// rewrite linked list
// current error: on max_size exceed and next save - panic
type List struct {
	head         *Indication
	end          *Indication
	current_size int
	max_size     int
}

func (l *List) Save(head *Indication) {
	if l.current_size == l.max_size {
		tmp := l.end
		l.end = l.end.prev
		tmp.prev = nil
		l.head.prev = head
		l.head = head
		return
	}

	if l.head == nil {
		l.head = head
		return
	}

	l.current_size++
	l.head.prev = head
	l.head = head
}

func (l *List) LastIn() *Indication {
	return l.head
}

func (l *List) All() []Indication {
	result := make([]Indication, 0, l.current_size)
	current := l.head

	for {
		result = append(result, *current)
		if current.next == nil {
			break
		}
		current = current.next
	}

	return result
}

//

type Indication struct {
	voltage float64
	speed   float64
	time    time.Time

	next *Indication
	prev *Indication
}

func NewIndication(voltage float64, speed float64, t time.Time) Indication {
	return Indication{
		voltage: voltage,
		speed:   speed,
		time:    t,
	}
}

type Storage struct {
	path      string
	localList List
}

func NewStorage() *Storage {
	return &Storage{
		localList: List{max_size: 10},
	}
}
func (s *Storage) Save(v Indication) error {
	s.localList.Save(&v)
	return nil
}

func (s *Storage) Last() *Indication {
	return s.localList.LastIn()
}
