# VMtranslator

1. Created by Connor Barnes. I used the following resources:

- [Swift Package Manager arguments](https://forums.swift.org/t/add-arguments-to-swift-run-without-argumentparser/10363/2)

2. I spent ~10 hours total on this project. 
3. There wasn't anything too difficult about this project for me, it just took a while for me to implement. There were quite a few errors when I first tested out aspects of the program, but i was able to fix them using the included tools. This took a little while just because it was hard to keep track of which line I was in in the VM emulator because comments and string labels are not shown.
4. To build the project follow the following steps:

- If your computer does not have the Swift 5.0+ installed, install [Swift 5.0+](https://swift.org/download/#releases)
- `cd` to the directory that this file is in.
- Run the command `swift run VMtranslator <input>` where `<input>` is replaced with the path to the input VM file or folder.

### Possible Errors

- Exit code 1: All known errors will report an exit code of 1 and print out a description of the error.

*Tested successfully on Arch Linux with Swift 5.2.5*
*Tested successfully on macOS 11.2.2 with Swift 5.3.2*
