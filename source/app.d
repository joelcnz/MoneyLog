// GUI Detailed Book Keeping Program - Joel's 12 1 2017 (it said 2016, but I've changed it to 2017)
//#not work 14 12 2016, works now 14 4 2019! Not so fast - buggy

/*
To do's:
sort by cost
*/

//#startsWith("cls", "clear")
//#not work 14 12 2016
 
import dlangui;
import std.stdio;
import std.conv;
import std.utf;
import std.algorithm;
import std.path;

import jmisc;

import world, login;

const SCALE_FACTOR = 2.0f;
enum fail = -1;
World wld;

mixin APP_ENTRY_POINT;

struct MainWindow {
	Window _window;
	EditLine    _editLineRefNum,
				_editLineDate,
				_editLineShop,
				_editLineCost,
				_editLineItem,
				_editLineComment,
				_editLineActivate;
	EditBox _editBoxHistory,
			_editBoxDump;
	TextWidget _textWidgetStatus;
	ComboBox _comboBoxAccounts;
	CheckBox _checkBoxAppend;
	Button _buttonWrap;

	void setup() {
		_window = Platform.instance.createWindow(
			"MoneyLog - Detailed Book Keeping", null, WindowFlag.Resizable, 1280, 800);

		// create some widget to show in window
		_window.mainWidget = parseML(q{
			HorizontalLayout {
				margins: 3
				padding: 3
				backgroundColor: "#C0E0E070" // semitransparent yellow background
				HorizontalLayout {
					VerticalLayout {
						TextWidget { text: "Login:"; textColor: "#0000FF" }
						ComboBox { id: comboBoxAccounts; }

						Button { id: buttonLoadLogin; maxWidth: 100; text: "Load login" }
						
						TextWidget { text: "Ref Num:" }
						EditLine { id: editLineRefNum; minWidth: 100; maxWidth: 100 }
						Button { id: buttonLoadRef; maxWidth: 100; text: "Load Ref" }

						TextWidget { text: "Date (d m y):" }
						EditLine {
							id: editLineDate
							minWidth: 100
							maxWidth: 100
						}

						TextWidget { text: "Shop:" }
						EditLine { id: editLineShop; minWidth: 100; maxWidth: 100 }
						
						TextWidget { text: "Cost:" }
						EditLine { id: editLineCost; text: "0.00"; minWidth: 100;  maxWidth: 100 }
						
						Button { id: buttonAdd; maxWidth: 100; text: "Add" }
						Button { id: buttonSet; maxWidth: 100; text: "Set" }
						
						Button { id: buttonRefresh; maxWidth: 100; text: "Refresh" }

						Button { id: buttonSave; maxWidth: 100; text: "Save" }
						TextWidget { text: "---" }
						Button { id: buttonWrap; maxWidth: 100; }
					}
					
					VerticalLayout {
						VerticalLayout {
							TextWidget { text: "Dump:" }
							EditBox	{ id: editBoxDump;
								minWidth: 2280; minHeight: 950; maxHeight: 950;
							}

							TextWidget { text: "History:" }
							EditBox	{ id: editBoxHistory;
								minWidth: 1480; minHeight: 230; maxHeight: 230;
							}

							HorizontalLayout {
								Button { id: buttonActivate; text: "Activate" }
								EditLine { id: editLineActivate; minWidth: 1200 }
								CheckBox { id: checkBoxAppend; text: "Append" }
							}
						
							TextWidget { text: "Item:" }
							EditLine { id: editLineItem; maxWidth: 200 }

							TextWidget { text: "Comment:" }
							EditLine { id: editLineComment; maxWidth: 200 }

							TextWidget { text: "Status:" }
							TextWidget { id: textWidgetStatus; }
						}
					}
				} // HoriontalLayout
			}
		});

		// you can access loaded items by id - e.g. to assign signal listeners
		_editLineRefNum     = _window.mainWidget.childById!EditLine("editLineRefNum");
		_editLineDate       = _window.mainWidget.childById!EditLine("editLineDate");
		_editLineShop       = _window.mainWidget.childById!EditLine("editLineShop");
		_editLineCost       = _window.mainWidget.childById!EditLine("editLineCost");
		_editLineItem       = _window.mainWidget.childById!EditLine("editLineItem");
		_editLineComment    = _window.mainWidget.childById!EditLine("editLineComment");
		_editBoxHistory     = _window.mainWidget.childById!EditBox("editBoxHistory");
		_textWidgetStatus   = _window.mainWidget.childById!TextWidget("textWidgetStatus");
		_comboBoxAccounts   = _window.mainWidget.childById!ComboBox("comboBoxAccounts");
		_checkBoxAppend     = _window.mainWidget.childById!CheckBox("checkBoxAppend");
		_checkBoxAppend.checked = true;
		_editLineActivate   = _window.mainWidget.childById!EditLine("editLineActivate");
		_editBoxDump        = _window.mainWidget.childById!EditBox("editBoxDump");
		_buttonWrap         = _window.mainWidget.childById!Button("buttonWrap");
		
		_editBoxDump.wordWrap = true; //#not work 14 12 2016, works now 14 4 2019! Not so fast - buggy
		_editBoxHistory.wordWrap = true;
		_buttonWrap.text = "UnWrap";

		_window.mainWidget.childById!Button("buttonWrap").click = delegate(Widget w) {
			if (true == _editBoxDump.wordWrap) {
				_editBoxDump.wordWrap = false;
				_editBoxHistory.wordWrap = false;
				_buttonWrap.text = "Wrap"d;
			} else {
				_editBoxDump.wordWrap = true;
				_editBoxHistory.wordWrap = true;
				_buttonWrap.text = "Unwrap"d;
			}
			return true;
		};

		import std.datetime : Clock, DateTime;
		auto dt = cast(DateTime)Clock.currTime();
		with(dt) _editLineDate.text = text(day, " ", cast(int)month, " ", year).to!dstring;

		dstring[] items;
		foreach(login; wld.getLogins) {
			items ~= login.handle.to!dstring;
		}
		_comboBoxAccounts.items(items);
		_comboBoxAccounts.selectedItemIndex = 0;


		upDateStatus("Program loaded. Enter `help` in Activate box and press the Activate button");

		import std.file;
		import std.path;
		import std.conv;
			
		// Load login
		_window.mainWidget.childById!Button("buttonLoadLogin").click = delegate(Widget w) {
			auto fileName = _comboBoxAccounts.selectedItem;

			if (! (fileName ~ ".ini").exists) {
				upDateStatus("Error: Login ", fileName, ".ini not found!");

				return false;
			}
			wld.loadAccount(fileName.to!string);
			upDateDump;
			upDateStatus("Login ", fileName, " loaded");
			
			return true;
		};

		// Load Reference
		_window.mainWidget.childById!Button("buttonLoadRef").click = delegate(Widget w) {
			import data;

			size_t index;
			try {
				index = _editLineRefNum.text.to!size_t;
			} catch(Exception e) {
				upDateStatus("Invalid reference number! - ", index);

				return false;
			}

			try {
				auto entry = wld.getFromIndex(index);

				with(entry) {
					import std.string;

					_editLineDate.text = text(day, " ", month, " ", year).to!dstring;
					_editLineShop.text = shop.to!dstring;

					_editLineCost.text = cost.to!string[0 .. $ - 3].to!dstring; // cost to dstring doesn't work money 2.2.0
					_editLineItem.text = item.to!dstring;
					_editLineComment.text = comment.to!dstring;
				}
			} catch(Exception e) {
				upDateStatus("Some error with load reference, check it!");

				return false;
			}
			upDateStatus("Loaded reference. - ", index);
			
			return true;
		};

		// Add commit
		_window.mainWidget.childById!Button("buttonAdd").click = delegate(Widget w) {
			auto entry = getEntry;

			if (entry.index == fail) {
				upDateStatus("Error adding entry!");

				return false;
			} else {
				try {
					wld.addEntry(entry);
				} catch(Exception e) {
					upDateStatus("Some thing went wrong!");
				}
				upDateDump;
			}
			
			return true;
		};

		// Set Commit
		_window.mainWidget.childById!Button("buttonSet").click = delegate(Widget w) {
			auto entry = getEntry;

			if (entry.index == fail) {
				upDateStatus("Entry fail!");

				return false;
			}

			size_t refNum;

			try {
				refNum = _editLineRefNum.text.to!size_t;
			} catch(Exception e) {
				upDateStatus("Set entry - ", _editLineRefNum.text, ", failed");

				return false;
			}

			if (_editLineRefNum is null) {
				upDateStatus("Error with reference number!");

				return false;
			}
			upDateStatus("Entry set - ", refNum);
			wld.setEntry(entry, refNum);
			upDateDump;
			
			return true;
		};
		
		// Commit
		_window.mainWidget.childById!Button("buttonRefresh").click = delegate(Widget w) {
			upDateStatus("Refresh..");
			upDateDump;
			
			return true;
		};

		// Save
		_window.mainWidget.childById!Button("buttonSave").click = delegate(Widget w) {
			immutable fileName = _comboBoxAccounts.selectedItem.to!string ~ ".ini";

			wld.saveAccount(fileName);
			upDateStatus("Saved ", fileName, " - saved the old one as back_", fileName);

			return true;
		};

		// Activate
		_window.mainWidget.childById!Button("buttonActivate").click = delegate(Widget w) {
			upDateStatus("Activate - ", _editLineActivate.text);
			dstring outPut;

			void doDump() {
				if (! _checkBoxAppend.checked)
					_editBoxDump.text = "";
				_editBoxDump.text = _editBoxDump.text ~ (_editBoxDump.text.length > 0 ? "\n"d : ""d) ~ outPut;
			}

			if (_editLineActivate.text == "cls" //#startsWith("cls", "clear")
				||
				_editLineActivate.text == "clear") {
				_editBoxDump.text = "";
				wld.doClear;
				upDateStatus("Clear");

				return true;
			}
			dstring status;
			if (! wld.activate(_editLineActivate.text, outPut, _checkBoxAppend.checked, status)) {
				upDateStatus("Activate ", _editLineActivate.text, " error!");
				doDump;

				return false;
			}
			doDump;
			if (status.length) {
				upDateStatus(status);
			}

			return true;
		};

		// show window
	    _window.show();
//		return Platform.instance.enterMessageLoop();
	}

	void upDateDump() {
		_editBoxDump.text = wld.dump;
	}

	void upDateStatus(T...)(T args) {
		import std.typecons: tuple; // untested
		import std.conv: text;

		auto txt = dateTimeString.to!dstring ~ " "d ~ text(args).to!dstring;
		writeln(txt);
		enum newLines = 4;
		auto htext = _editBoxHistory.text;
		int i = cast(int)htext.length - 1;
		while(i >= 0 && htext[i] == '\n') {
			i -= 1;
		}
		i += 1;
		if (_editBoxHistory.text.length > newLines)
			_editBoxHistory.text = _editBoxHistory.text[0 .. $ - newLines];
		import std.array: replicate;
		_editBoxHistory.text = _editBoxHistory.text ~
			(_editBoxHistory.text == ""d ? ""d : "\n"d) ~ txt ~ "\n"d.replicate(newLines);
		_textWidgetStatus.text = txt;

		import std.file;
		append("history.txt", txt.to!string ~ "\n");
	}

	auto getEntry() {
		import data, std.string;

		auto entry = new Data;

		auto printData(string title) {
			with(entry)
				upDateStatus(title,
					format("%s.%02s.%s, shop: %s, cost: $%.02f, item: %s, Comment: %s",
						day, month, year, shop, cost, item, comment));
		}

		enum Date {day, month, year}
		int[3] date;
		try {
			date = _editLineDate.text.split.to!(int[3]);
		} catch(Exception e) {

			upDateDump;
			upDateStatus("Error with date! - ", _editLineDate.text);

			entry.index = -1;

			return entry;
		}
		with(entry) {
			try {
				day = date[Date.day];
				month = date[Date.month];
				year = date[Date.year];
				shop = _editLineShop.text.to!string;

				import money, mmisc;
				//" 0.9+ 0.1 +9.1+   0.9 \n ".getParseMonInputStr.writeln;
				_editLineCost.text = _editLineCost.text.getParseMonInputStr;
				cost = bdub(_editLineCost.text.to!string);
				item = _editLineItem.text.to!string;
				comment = _editLineComment.text.to!string;
			} catch(Exception e) {
				printData("Error with entry! - ");
				index = -1;

				return entry;
			}
		}
		printData("Entry set - ");

		return entry;
	}
} // struct MainWindow

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
	import std.stdio;
	
	scope(exit) {
		writeln;
		writeln("# #");
		writeln("###");
		writeln("# #");
		writeln("# #");
		writeln("# #");
		writeln;
	}

	overrideScreenDPI = cast(int)(96f * SCALE_FACTOR);
	
	wld = new World(args); // world.d

	MainWindow mainWindow;
	mainWindow.setup;

    // run message loop
    return Platform.instance.enterMessageLoop();
}
