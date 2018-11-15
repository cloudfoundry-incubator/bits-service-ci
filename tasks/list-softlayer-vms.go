package main

import (
	"fmt"
	"os"
	"sync"

	"github.com/softlayer/softlayer-go/datatypes"

	"github.com/softlayer/softlayer-go/services"

	"github.com/softlayer/softlayer-go/session"
)

func main() {
	username := os.Getenv("USERNAME")
	if username == "" {
		panic("Empty USERNAME")
	}
	password := os.Getenv("API_KEY")
	if password == "" {
		panic("Empty API_KEY")

	}
	s := session.New(username, password)
	as := services.GetAccountService(s)
	vgs := services.GetVirtualGuestService(s)
	ts := services.GetTagService(s)

	guests, e := as.GetHourlyVirtualGuests()
	panicOnError(e)

	lines := make(chan string)
	semaphore := make(chan bool, 20)
	numGuests := 0
	var wg sync.WaitGroup
	for _, item := range guests {
		wg.Add(1)
		go func(item datatypes.Virtual_Guest) {
			defer wg.Done()
			semaphore <- true
			defer func() { <-semaphore }()
			vg := vgs.Id(*item.Id)
			dc, e := vg.GetDatacenter()
			panicOnError(e)
			if *dc.Name != "ams03" {
				return
			}
			numGuests++
			tagRefs, e := vg.GetTagReferences()
			panicOnError(e)
			var tags []string
			for _, tagRef := range tagRefs {
				tag, e := ts.Id(*tagRef.TagId).GetObject()
				panicOnError(e)
				tags = append(tags, *tag.Name)
			}

			lines <- fmt.Sprintf("%v\t%v\t%v\t%v\n", *item.Id, *item.Hostname, *item.CreateDate, tags)
		}(item)
	}
	go func() {
		for {
			select {
			case line := <-lines:
				fmt.Printf(line)
			}
		}
	}()
	wg.Wait()
	close(lines)
}

func panicOnError(e error) {
	if e != nil {
		panic(e)
	}
}
