package util

import "time"

func SameDay(a, b time.Time) bool {
	ay, am, ad := a.Date()
	by, bm, bd := b.Date()
	return ay == by && am == bm && ad == bd
}

func IsYesterday(last, now time.Time) bool {
	yesterday := now.Add(-24 * time.Hour)
	return SameDay(last, yesterday)
}
