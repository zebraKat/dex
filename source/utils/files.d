module files;
public import std.file;
import std.conv:to;



string openFile(string path) {
    if (exists(path)) {
        return to!string(cast(char[])std.file.read(path));
    }
    return "";
}

void writeFile(string path, string src) {
    std.file.write(path,src);
}


