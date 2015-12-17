package main

import (
	"fmt"
	"net"
	"os"
)

func checkError(err error, info string) (res bool) {
	if err != nil {
		fmt.Println(info + " " + err.Error())
		return false
	}
	return true
}

func handler(conn net.Conn, message chan string) {
	fmt.Println("connect from " + conn.RemoteAddr().String())
	buff := make([]byte, 1024)
	for {
		length, err := conn.Read(buff)
		if checkError(err, "connect") == false {
			conn.Close()
			break
		}
		if length > 0 {
			buff[length] = 0
		}
		receiveStr := string(buff[0:length])
		message <- receiveStr
	}
}

func echoHandler(conns *map[string]net.Conn, messages chan string) {
	for {
		msg := <-messages
		fmt.Println(msg)
		for key, value := range *conns {
			fmt.Println("connection is connected from ...", key)
			_, err := value.Write([]byte(msg))
			if err != nil {
				fmt.Println(err.Error())
				delete(*conns, key)
			}
		}
	}
}

func StartServer(port string) {
	service := ":" + port
	tcpAddr, err := net.ResolveTCPAddr("tcp4", service)
	checkError(err, "ResolveTCPAddr")
	listener, err := net.ListenTCP("tcp", tcpAddr)
	checkError(err, "Listener")
	conns := make(map[string]net.Conn)
	messages := make(chan string, 10)

	go echoHandler(&conns, messages)
	for {
		fmt.Println("Listener...")
		con, err := listener.Accept()
		if checkError(err, "accept") {
			conns[con.RemoteAddr().String()] = con
			go handler(con, messages)
		}
	}
}
func chatSend(conn net.Conn) {
	var input string
	username := conn.LocalAddr().String()
	for {
		fmt.Scanln(&input)
		if input == "/quit" {
			fmt.Println("byebye...")
			conn.Close()
			os.Exit(0)
		}

		lens, err := conn.Write([]byte("[" + username + "]=say:" + input))
		fmt.Println(lens)
		if err != nil {
			fmt.Println(err.Error())
			conn.Close()
			break
		}
	}
}

func StartClient(host string) {
	tcpaddr, err := net.ResolveTCPAddr("tcp4", host)
	checkError(err, "ResolveTCPAddr")
	conn, err := net.DialTCP("tcp", nil, tcpaddr)
	checkError(err, "DialTCP")

	go chatSend(conn)
	buff := make([]byte, 1024)
	for {
		length, err := conn.Read(buff)
		if checkError(err, "read data") == false {
			conn.Close()
			fmt.Println("server is dead ... bye bye")
			os.Exit(0)
		}
		fmt.Println(string(buff[0:length]))
	}
}

func usge() {
	fmt.Println("chat server [port]\nchat client [server Ip addr]:[server port]")
}

func main() {
	if len(os.Args) != 3 {
		usge()
		os.Exit(0)
	}
	if os.Args[1] == "server" && len(os.Args) == 3 {
		StartServer(os.Args[2])
		return
	}
	if os.Args[1] == "client" && len(os.Args) == 3 {
		StartClient(os.Args[2])
		return
	}
	usge()
}
