package domain

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"time"
)

// Linked list

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

func NewStorage(path string) (*Storage, error) {

	lstat, err := os.Lstat(path)
	if err != nil {
		_, err := os.Create(path)
		if err != nil {
			return nil, err
		}
		lstat, err = os.Lstat(path)
		if err != nil {
			return nil, err
		}
	}
	if !lstat.Mode().IsRegular() {
		return nil, fmt.Errorf("Storage file must be a regular file")
	}

	return &Storage{
		path:      path,
		localList: List{max_size: 10},
	}, nil
}
func (s *Storage) Save(v Indication) (int, error) {
	f, err := os.OpenFile(s.path, os.O_APPEND, 0644)
	if err != nil {
		return 0, err
	}

	defer f.Close()

	bytes, err := json.Marshal(v)
	bytes = append(bytes, '\n')
	if err != nil {
		return 0, err
	}
	n, err := f.Write(bytes)
	if err != nil {
		return 0, err
	}

	s.localList.Save(&v)
	return n, nil
}

func (s *Storage) Last() *Indication {
	return s.localList.LastIn()
}

func (s *Storage) LoadLast() error {
	f, err := os.OpenFile(s.path, os.O_RDONLY, 0644)
	if err != nil {
		return err
	}
	rd := bufio.NewReader(f)

	var lastErr error = nil
	var counter int = 0
	for lastErr == nil && counter < 10 {
		l, err := rd.ReadBytes('\n')
		if err != nil && err != io.EOF {
			return err
		}

		indication := Indication{}
		err = json.Unmarshal(l, &indication)
		if err != nil {
			return err
		}

		s.localList.Save(&indication)
	}
	return nil
}
