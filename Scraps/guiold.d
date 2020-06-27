struct Gui {
	void setup(string loginName) {
		import std.datetime : Clock, DateTime;

		auto dt = cast(DateTime)Clock.currTime();
		with(dt)
			_editLineDate.text = text(day, " ", cast(int)month, " ", year);

		string[] items;
		foreach(login; g_World.getLogins) {
			items ~= login.handle;
		}
		//_comboBoxAccounts.items(items);
		//_comboBoxAccounts.selectedItemIndex = 0;

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
			g_World.loadAccount(fileName.to!string);
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
				auto entry = g_World.getFromIndex(index);

				with(entry) {
					import std.string;

					_editLineDate.text = text(day, " ", month, " ", year).to!string;
					_editLineShop.text = shop.to!string;

					_editLineCost.text = cost.to!string[0 .. $ - 3].to!string; // cost to string doesn't work money 2.2.0
					_editLineItem.text = item.to!string;
					_editLineComment.text = comment.to!string;
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
					g_World.addEntry(entry);
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
			g_World.setEntry(entry, refNum);
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

			g_World.saveAccount(fileName);
			backUp(fileName);
			upDateStatus("Saved ", fileName, " - saved the old one as back_", fileName);

			return true;
		};

		// Activate
		_window.mainWidget.childById!Button("buttonActivate").click = delegate(Widget w) {
			upDateStatus("Activate - ", _editLineActivate.text);
			string outPut;

			void doDump() {
				if (! _checkBoxAppend.checked)
					_editBoxDump.text = "";
				_editBoxDump.text = _editBoxDump.text ~ (_editBoxDump.text.length > 0 ? "\n"d : ""d) ~ outPut;
			}

			if (_editLineActivate.text == "cls" //#startsWith("cls", "clear")
				||
				_editLineActivate.text == "clear") {
				_editBoxDump.text = "";
				g_World.doClear;
				upDateStatus("Clear");

				return true;
			}
			string status;
			if (! g_World.activate(_editLineActivate.text, outPut, _checkBoxAppend.checked, status)) {
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
	}

	void upDateDump() {
		_editBoxDump.text = g_World.dump;
	}

	void upDateStatus(T...)(T args) {
		import std.typecons: tuple; // untested
		import std.conv: text;

		auto txt = dateTimeString.to!string ~ " "d ~ text(args).to!string;
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
