package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"time"
)

var (
	verbose = flag.Bool("v", false, "Show verbose logging")
	binary  = flag.String("D", "", "Path of the elf file to load")
	verify  = flag.Bool("y", false, "Verify flash after upload")
	version = "0.0.0-dev" // CI will take care of it
)

// PrintlnVerbose executes Println of the interface if verbose
func PrintlnVerbose(a ...interface{}) {
	if *verbose {
		fmt.Println(a...)
	}
}

// PrintVerbose executes Print of the interface if verbose
func PrintVerbose(a ...interface{}) {
	if *verbose {
		fmt.Print(a...)
	}
}

func main() {
	name := filepath.Base(os.Args[0])
	path, _ := filepath.Abs(filepath.Dir(os.Args[0]))
	flag.Parse()

	PrintlnVerbose(name + " " + version + " - compiled with " + runtime.Version())

	convert := []string{filepath.Join(path, "elf2uf2"), *binary, *binary + ".uf2"}
	launchCommandAndWaitForOutput(convert, false, false)

	info := []string{filepath.Join(path, "picotool"), "info"}
	_, _, err := launchCommandAndWaitForOutput(info, false, true)
	for i := 0; i < 20 && err != nil; i++ {
		_, _, err = launchCommandAndWaitForOutput(info, false, true)
		time.Sleep(500 * time.Millisecond)
	}
	if err != nil {
		fmt.Println("")
		os.Exit(1)
	}

	load := []string{filepath.Join(path, "picotool"), "load"}
	if *verify {
		load = append(load, "-v")
	}
	load = append(load, *binary+".uf2")
	_, _, err = launchCommandAndWaitForOutput(load, true, false)
	if err != nil {
		fmt.Println("")
		os.Exit(1)
	}

	reboot := []string{filepath.Join(path, "picotool"), "reboot"}
	_, _, err = launchCommandAndWaitForOutput(reboot, false, false)
	if err != nil {
		fmt.Println("")
		os.Exit(1)
	}

	fmt.Println("")
	os.Exit(0)
}

func launchCommandAndWaitForOutput(command []string, printOutput bool, showSpinner bool) (bool, string, error) {
	oscmd := exec.Command(command[0], command[1:]...)
	tellCommandNotToSpawnShell(oscmd)
	stdout, _ := oscmd.StdoutPipe()
	stderr, _ := oscmd.StderrPipe()
	multi := io.MultiReader(stdout, stderr)

	if printOutput && *verbose {
		oscmd.Stdout = os.Stdout
		oscmd.Stderr = os.Stderr
	}
	err := oscmd.Start()
	in := bufio.NewScanner(multi)
	in.Split(bufio.ScanRunes)
	found := false
	out := ""
	if showSpinner {
		fmt.Printf(".")
	}
	lastPrint := time.Now()
	for in.Scan() {
		if showSpinner && time.Since(lastPrint) > time.Second {
			fmt.Printf(".")
			lastPrint = time.Now()
		}
		out += in.Text()
	}
	err = oscmd.Wait()
	return found, out, err
}

func launchCommandBackground(command []string) (bool, error) {
	oscmd := exec.Command(command[0], command[1:]...)
	tellCommandNotToSpawnShell(oscmd)
	err := oscmd.Start()
	return false, err
}
