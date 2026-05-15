package period

import "server/pb"

type PeriodType int

const (
	Day PeriodType = iota
	Week
	Month
)

func FromProtobuf(p pb.PeriodType) PeriodType {
	switch p {
	case pb.PeriodType_PERIOD_TYPE_DAY:
		return Day
	case pb.PeriodType_PERIOD_TYPE_WEEK:
		return Week
	case pb.PeriodType_PERIOD_TYPE_MONTH:
		return Month
	default:
		return Day
	}
}
