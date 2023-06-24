package main

import (
	"io/ioutil"
	"os"
	"testing"
	"log"
)

func TestPrintFileContent(t *testing.T) {
	// Create a temporary file
	file, err := ioutil.TempFile("", "testfile.txt")
	if err != nil {
		t.Fatalf("Failed to create temporary file: %s", err)
	}
	defer os.Remove(file.Name())

	// Write some content to the file
	content := []byte("Hello, World!")
	err = ioutil.WriteFile(file.Name(), content, 0644)
	if err != nil {
		t.Fatalf("Failed to write file content: %s", err)
	}

	// Call the function under test
	err = printFileContent(file.Name())

	// Check the error
	if err != nil {
		t.Errorf("Expected no error, got: %s", err)
	}
}

func TestShred(t *testing.T) {
	// Create a temporary file
	file, err := ioutil.TempFile("", "testfile.txt")
	if err != nil {
		t.Fatalf("Failed to create temporary file: %s", err)
	}
	defer os.Remove(file.Name())

	// Write some initial content to the file
	initialContent := []byte("Initial content")
	err = ioutil.WriteFile(file.Name(), initialContent, 0644)
	if err != nil {
		t.Fatalf("Failed to write initial file content: %s", err)
	}

	// Call the function under test
	err = Shred(file.Name())

	// Check the error
	if err != nil {
		t.Errorf("Expected no error, got: %s", err)
	}

	// Check if the file has been removed
	if _, err := os.Stat(file.Name()); !os.IsNotExist(err) {
		t.Error("Expected the file to be removed, but it still exists")
	}
}


func TestFakeFile(t *testing.T) {
	t.Run("Main: Fake file", func(t *testing.T) {
		if err := Shred("fakefile.txt"); err == nil {
			t.Error("The file doesn't exists there should be an error!")
		}
	})
}

func TestMainSubtest(t *testing.T) {
	t.Run("Main: Missing parameter", func(t *testing.T) {
		// Temporarily redirect stdout
		old := os.Stdout
		r, w, _ := os.Pipe()
		os.Stdout = w

		// Clear command-line arguments
		oldArgs := os.Args
		os.Args = []string{"source"}

		// Call the main function
		main()

		// Close the pipe
		w.Close()

		// Restore stdout
		os.Stdout = old

		// Read the output
		out, _ := ioutil.ReadAll(r)

		// Verify the output
		expectedOutput := "Missing parameter, provide file name!\n"
		if string(out) != expectedOutput {
			t.Errorf("Expected output: %s, got: %s", expectedOutput, string(out))
		}

		// Restore command-line arguments
		os.Args = oldArgs
	})
}

func TestMain(m *testing.M) {
	// Save original command-line arguments
	oldArgs := os.Args

	// Create a temporary file
	file, err := ioutil.TempFile("", "testfile.txt")
	if err != nil {
		log.Fatalf("Failed to create temporary file: %s", err)
	}
	defer os.Remove(file.Name())

	// Write some initial content to the file
	initialContent := []byte("Initial content")
	err = ioutil.WriteFile(file.Name(), initialContent, 0644)
	if err != nil {
		log.Fatalf("Failed to write initial file content: %s", err)
	}

	// Set the command-line arguments to test the main function
	os.Args = []string{file.Name()}

	// Run the tests
	result := m.Run()

	// Restore original command-line arguments
	os.Args = oldArgs

	// Perform additional checks
	if result != 0 {
		log.Fatal("TestMain: Tests failed")
	}

	// Run subtests using the top-level m parameter
	m.Run()
}