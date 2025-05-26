module editor;
import std.array;
import std.conv:to;
import std.algorithm;
import std.string;

enum Mode {
    NORMAL,
    INSERT,
    COMMAND 
}

struct Editor {
    size_t[char] cursor = [
        'x':0,
        'y':0
    ];
    string currentFile;
    Mode currentMode;
    string log;
    char[][] lines;    

    void fromString(string src) {
        string[] sp = splitLines(src);
        char[][] sp2 = [];
        ulong i = 0;

        foreach( str; sp ) {
            sp2 ~= str.dup;
            i++;
        }

        this.lines = sp2;
    }

    void typeChar(char c) {
        insertAtPosition(c, this.cursor['y'], this.cursor['x'] + 1);
        this.cursor['x'] += 1;
    }

    void backSpace() {
        size_t removeIndex = this.cursor['x'] - 1;
        size_t lineIndex = this.cursor['y'];
        this.lines[lineIndex] = this.lines[lineIndex][0..removeIndex] ~ this.lines[lineIndex][removeIndex +1..this.lines[lineIndex].length];
        this.cursor['x'] -= 1;
        // TODO: check if cursor index is 0/1 if so then concat the line with the line before it.
    }
    
    void insertAtPosition(char c,size_t line, size_t index) {
       if (line + 1 > this.lines.length) {
           this.log = format("line: %d, length: %d", line, this.lines.length);
           while (line + 1 > this.lines.length )  {
                this.lines ~= new char[0];
           }
            this.log = format("line: %d, length: %d", line, this.lines.length);
       }

       if (this.lines[line].length < index ) {
            this.lines[line] ~= c;
            this.cursor['x'] = this.lines[line].length - 1;
       } else {
            insertInPlace(this.lines[line],index,c);
       }
    }

    string asString() {
        string str;
        foreach (line; this.lines) {
           str ~= to!string(line) ~ '\n'; 
        }
        return str;
    }
}

