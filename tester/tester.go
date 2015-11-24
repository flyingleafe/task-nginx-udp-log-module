package main

import (
    "os"
    "fmt"
    "net"
    "sync"
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
        fmt.Print("Received on port ", port, ": ", string(buf[:n]))

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
        fmt.Println(port)
        go func(port string) {
            defer wg.Done()
            listenUDP(port)
        }(port)
    }

    fmt.Println("Server started")
    wg.Wait()
}
