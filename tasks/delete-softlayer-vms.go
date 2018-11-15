package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"

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
	vgs := services.GetVirtualGuestService(s)

	scanner := bufio.NewScanner(os.Stdin)
	semaphore := make(chan bool, 20)
	var wg sync.WaitGroup
	for scanner.Scan() {
		wg.Add(1)
		go func(text string) {
			defer wg.Done()
			semaphore <- true
			defer func() { <-semaphore }()

			parts := strings.Split(text, "\t")
			vmID := parts[0]
			i, e := strconv.Atoi(vmID)
			panicOnError(e)
			guest := vgs.Id(i)
			response, e := guest.DeleteObject()
			if e != nil {
				fmt.Println("Could not delete VM", i, e)
				return
			}
			if !response {
				fmt.Println("Could not delete VM", i)
				return
			}
			fmt.Println("Done deleting", i)
		}(scanner.Text())
	}
	wg.Wait()
}

func panicOnError(e error) {
	if e != nil {
		panic(e)
	}
}
