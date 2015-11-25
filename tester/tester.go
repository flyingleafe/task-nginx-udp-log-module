package main

import (
    "os"
    "fmt"
    "net"
    "sync"
    "strings"
)

func checkError(err error) {
    if err != nil {
        fmt.Println("Error: ", err)
        os.Exit(1)
    }
}

func listenUDP(port string) {
    addr, err := net.ResolveUDPAddr("udp", "localhost:" + port)
    checkError(err)

    conn, err := net.ListenUDP("udp", addr)
    checkError(err)
    defer conn.Close()

    fmt.Println("Listening on port", port)
    buf := make([]byte, 1024)

    for {
        n, _, err := conn.ReadFromUDP(buf)

        fields := strings.Fields(string(buf[:n]))

        fmt.Println("Received on port", port)
        fmt.Println("    Method: ", fields[0])
        fmt.Println("    URI:    ", fields[1])
        fmt.Println("    CRC32:  ", fields[2])

        if err != nil {
            fmt.Println("Error (port ", port, "): ", err)
        }
    }
}

func main() {
    ports := os.Args[1:]
    var wg sync.WaitGroup

    wg.Add(len(ports))
    for _, port := range ports {
        go func(port string) {
            defer wg.Done()
            listenUDP(port)
        }(port)
    }

    fmt.Println("Server started")
    wg.Wait()
}
