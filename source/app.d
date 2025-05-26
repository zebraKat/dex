import files;
import editor;
//
import std.stdio;
import std.string;
import std.conv:to;
import std.datetime;
import std.format:format;
//
import core.runtime;
import core.thread.osthread;
import core.stdc.stdlib;
import core.sys.posix.termios;
import core.sys.posix.unistd;
import core.sys.posix.sys.ioctl;
import core.sys.posix.fcntl;

struct Winsize {
    ushort ws_row;
    ushort ws_col;
    ushort ws_xpixel;
    ushort ws_ypixel;
}



editor.Editor session;
winsize ws;
string commandString;

void main(string[] args) {
    enableRawMode();
 
    if (args[1]) {
        session.fromString(files.openFile(args[1]));
        session.currentFile = args[1];
    }

    char input;

    while (true) {
        //clear screen
        clearScreen();

        // Check terminal Size
        if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) == -1) {
            writeln("Error: Unable to get terminal size");
            return;
        }

        // input
        if (read(STDIN_FILENO, &input, 1) == 1) {
            if (session.currentMode == Mode.NORMAL) {
                if (input == 'h') {session.cursor['x'] -= 1;} else
                if (input == 'j') {session.cursor['y'] += 1;} else
                if (input == 'k') {session.cursor['y'] -= 1;} else
                if (input == 'l') {session.cursor['x'] += 1;} else
                if (input == '$') {session.cursor['x'] = session.lines[session.cursor['y']].length;} else
                if (input == '0') {session.cursor['x'] = 0;} else
                if (input == 'i') {session.currentMode = Mode.INSERT;} else
                if (input == ':') {session.currentMode = Mode.COMMAND;} else 
                if (input == 'd') {session.lines[session.cursor['y']] = new char[0];}
            } else if (session.currentMode == Mode.INSERT) {
                if (input == '\033') { session.currentMode = Mode.NORMAL; } else 
                if (input == '\177') { session.log = "BACKSPACE RPESSED"; session.backSpace(); } else
                if (input == '\n') { /* TODO: newline support */} else
                {session.typeChar(input);}
            } else if (session.currentMode == Mode.COMMAND) {
                if (input == '\033') { session.currentMode = Mode.NORMAL; }else
                if (input == '\n') { useCommand(); session.currentMode = Mode.NORMAL; commandString = ""; } else 
                if (input == '\010') {
                    commandString = commandString.ptr[0..commandString.length-2];
                    if (commandString == "\0") {commandString = "";}
                } else {
                    commandString ~= input;     
                }

            }

        }

        // rendering
        render();

        //refresh rate
        Thread.sleep(15.msecs);
    }
}

void render() {
    write(session.asString());
    drawStatus();
    drawCursor();
    std.stdio.stdout.flush();
}

void clearScreen() {
    write("\033c");
}

void drawText(string text , int row , int col) {
    writef("\033[%d;%dH%s", row, col, text);
    stdout.flush();
}

void drawStatus() {
    drawText(format("Mode: %s   |   %s  |   %d, %d",session.currentMode, commandString, session.cursor['y'], session.cursor['x']),ws.ws_row - 2, 0);
    drawText(session.log,ws.ws_row -1, 0);
}

void drawCursor() {
    writef("\x1b[%d;%dH", session.cursor['y'] + 1, session.cursor['x'] + 1);
}

void useCommand() {
    if (commandString == "w") {
        writeFile(session.currentFile, session.asString());
        session.log = "Saved file to " ~ session.currentFile;
    }else if ( commandString == "q" ) {
        exit(0);
    }
}

void enableRawMode() {
    termios oldt, newt;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);
}
