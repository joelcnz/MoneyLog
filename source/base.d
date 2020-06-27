module base;

public:
import std.stdio;
import std.conv;
import std.file;

import gtk.Main;
import gtk.MainWindow;
import gtk.Grid;
import gtk.ComboBoxText;
import gtk.Box;
import gtk.Entry;
import gtk.Label;
import gtk.Button;
import gtk.CheckButton;
import gtk.TextTagTable;
import gtk.TextBuffer;
import gtk.TextView;
import gtk.Clipboard;
import gtk.Adjustment;
import gtk.ScrolledWindow;
import gtk.ViewPort;
import gtk.TextIter; // probably idle
import gtk.TextMark; // idle
import gtk.AccelGroup;
import gtk.MenuItem;
import gtk.Window;
import gtk.Widget;
import gtk.HeaderBar;

import gdk.Event;
import gdk.Keysyms;

import jmisc;

import world;

World g_World;

immutable g_Title = "Welcome to MoneyLog";

immutable fail = -1;

void moneyLogUpDateStatus(T...)(T args) {
    import std.typecons: tuple; // untested
    import std.conv: text;

    auto txt = dateTimeString ~ " " ~ text(args);
    writeln(txt);
    enum newLines = 4;
    auto history = g_World.getAppBox.getBigRightBox.getHistoryTextBuffer;
    int i = cast(int)history.getText.length - 1;
    while(i >= 0 && history.getText[i] == '\n') {
        i -= 1;
    }
    i += 1;
    if (history.getText.length > newLines)
        history.setText(history.getText[0 .. $ - newLines]);
    import std.array: replicate;
    history.setText(history.getText ~ (history.getText == "" ? "" : "\n") ~ txt ~ "\n".replicate(newLines));
    immutable capAt = 150;
    g_World.getAppBox.getBigRightBox.getStatus.setText =
        txt[0 .. txt.length > capAt ? capAt : $] ~ (txt.length > capAt ? "..." : "");

    import std.file;
    append("history.txt", txt ~ "\n");

    scrollToBottom(g_World.getAppBox.getBigRightBox.getMainTextScrolled.getMyTextView);
    scrollToBottom(g_World.getAppBox.getBigRightBox.getHistoryScrolled.getMyTextView);
}

import maingui;

void scrollToBottom(MyTextView textView) {
    Adjustment adj = textView.getVadjustment();
    auto dif = adj.getUpper() - adj.getPageSize();
    adj.setValue(dif);
    textView.setVadjustment(adj);
}
