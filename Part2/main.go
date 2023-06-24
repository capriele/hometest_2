package main

import (
    "fmt"
    "os"
    "io/ioutil"
	"math/rand"
)

func printFileContent(path string) (error) {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		fmt.Println("Can't read file:")
		fmt.Printf("%s\r\n", err)
	} else {
		fmt.Println("Current file content is:")
		fmt.Printf("%x\r\n", data)
	}
	return err
}

func Shred(path string) (error) {
	for i := 0; i < 3; i++ {
		// Reading current file content and print it
		err := printFileContent(path)
		if err != nil {
			return err
		}

		// Generate random content (max 512 bytes)
		randomBuffer := make([]byte, rand.Intn(512))
		_, err = rand.Read(randomBuffer)
		if err != nil {
			fmt.Println("Error while generating random string:")
			fmt.Printf("%s\r\n", err)
			return err
		}

		
		// Write the random buffer to the file
		err = ioutil.WriteFile(path, randomBuffer, 0644)
		if err != nil {
			fmt.Printf("Error while writing the new file content: %s", err)
			return err
		}
	}

	// Reading current file content and print it
	err := printFileContent(path) 
	if err != nil {
		return err
	}

	// Remove the file
	err = os.Remove(path)
    if err != nil {
		fmt.Println("Error while removing the file:")
		fmt.Printf("%s\r\n", err)
    }

	return err
}

func main() {
	// First element in os.Args is always the program name,
	// So we need at least 2 arguments to have a file name argument.
	if len(os.Args) < 2 {
		fmt.Println("Missing parameter, provide file name!")
		return
	}
	Shred(os.Args[1])
}
