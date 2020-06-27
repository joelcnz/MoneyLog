// GUI Detailed Book Keeping Program - Joel's 12 1 2017 (it said 2016, but I've changed it to 2017)
//#not work 14 12 2016, works now 14 4 2019! Not so fast - buggy

/*
To do's:
sort by cost
*/

//#startsWith("cls", "clear")
//#not work 14 12 2016
 
import std.stdio;
import std.conv;
import std.utf;
import std.algorithm;
import std.path;

import jmisc;

import base, world, login;

enum fail = -1;

/// entry point for dlangui based application
void main(string[] args) {
	import std.stdio;

	if (args.length == 1) {
		args ~= "test";
	}

	scope(exit) {
		writeln;
		writeln("# #");
		writeln("###");
		writeln("# #");
		writeln("# #");
		writeln("# #");
		writeln;
	}

	Main.init(args);

	g_World = new World(args); // world.d

/+
		File("entrytext.txt", "w").writeln(
			appBox.getLeftPanelBox.getRefNumEntry.getText ~ "\n" ~
			appBox.getLeftPanelBox.getShopEntry.getText ~ "\n" ~
			appBox.getLeftPanelBox.getCostEntry.getText ~ "\n" ~
			appBox.getBigRightBox.getCommandHorizontalBox.getCommandEntry.getText ~ "\n" ~
			appBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry.getText ~ "\n" ~
			appBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry.getText);
+/
	import std.string : chomp;

	immutable fileName = "entrytext.txt";
	enum Type {REFERENCE, SHOP, COST, COMMAND, ITEM, COMMENT}
	int i;
	foreach(data; File(fileName).byLine) {
		auto line = data.to!string.chomp;
		if (line.length)
			switch(i) with (Type) {
				default: gh(fileName ~ " - error"); return;
				case REFERENCE: g_World.getAppBox.getLeftPanelBox.getRefNumEntry.setText = line; break;
				case SHOP: g_World.getAppBox.getLeftPanelBox.getShopEntry.setText = line; break;
				case COST: g_World.getAppBox.getLeftPanelBox.getCostEntry.setText = line; break;
				case COMMAND: g_World.getAppBox.getBigRightBox.getCommandHorizontalBox.getCommandEntry.setText = line; break;
				case ITEM: g_World.getAppBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry.setText = line; break;
				case COMMENT: g_World.getAppBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry.setText = line; break;
			}
		i += 1;
	}
	if (i - 1 < Type.max.to!int) {
		gh(fileName ~ " - error");
		return;
	}

	moneyLogUpDateStatus(g_Title);

	Main.run();
}
