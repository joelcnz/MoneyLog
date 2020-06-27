module world;

/**
This module has:
Login menu. - create, erase, etc logins

*/

import std.string;
import core.stdc.stdio;
import std.stdio;
import std.file;
import std.conv;
import core.stdc.string;
import core.stdc.stdlib;

import jmisc;

import base, maingui, account, login, mmisc, data;

class World : MainWindow {
	private:
	string title = g_Title;
	auto HANDLE_FILE="LOGINS.DAT";
	int _loginIndex;
	Login[] lgns;
	Account _acnt;
	AppBox appBox;

	TextBuffer shortTextBufferMain;

	public:
	@property {
		auto ref getLogins() { return lgns; }
		auto ref account() { return _acnt; }
	}

	this(string[] args) {
		super(title);
		//loadLogins();
		appBox = new AppBox(args[1]);
		add(appBox);

		/+
		with(dt)
			_editLineDate.text = text(day, " ", cast(int)month, " ", year);

		string[] items;
		foreach(login; g_World.getLogins) {
			items ~= login.handle;
		}
		writeln("logins:");
		import std;
		items.each!writeln;
		+/

		setTitlebar(new MyHeaderBar());

		immutable iconFile = "../Res/ballicon.png";
		setIconFromFile(iconFile);

		addOnKeyPress(&controlQCallBack);

		shortTextBufferMain = appBox.getBigRightBox.getTextBufferMain;

		move(0, 30);

		showAll();
	}

	auto getAppBox() {
		return appBox;
	}

	bool controlQCallBack(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK &&
			ev.key.keyval == GdkKeysyms.GDK_q) {
			
			quitApp(w);

			return true;
		}
		
		return false;
	}

	void quitApp(Widget widget)
	{
		File("entrytext.txt", "w").writeln(
			appBox.getLeftPanelBox.getRefNumEntry.getText ~ "\n" ~
			appBox.getLeftPanelBox.getShopEntry.getText ~ "\n" ~
			appBox.getLeftPanelBox.getCostEntry.getText ~ "\n" ~
			appBox.getBigRightBox.getCommandHorizontalBox.getCommandEntry.getText ~ "\n" ~
			appBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry.getText ~ "\n" ~
			appBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry.getText);

		string exitMessage = "Bye.";
		
		writeln(exitMessage);
		
		Main.quit();
		
	} // quitApp()

	void upDateDump() {
		assert(shortTextBufferMain);
		shortTextBufferMain.setText = dump;
	}

	void doClear() {
		_acnt.doClear;
	}

	bool activate(string action, out string outPut, bool append, ref string status) {
		import std.string;
		auto args = [action.split[0], action.split[1 .. $].join(" ")];

		immutable doesntCheckOut = false;
		immutable ok = true;
		immutable couldNotCompute = false;

		bool doCheck() {
			if (_acnt is null) {
				outPut = status = "No book open!";

				return couldNotCompute;
			}
			if (args.length != 2) {
				outPut = status = "Error, no operand..";
				if (args.length > 2) {
					outPut = status = "Error, wrong number of operands.";
				}
				return couldNotCompute;
			}
			return ok;
		}

		switch(action.split[0]) {
			default:
				outPut = status = "`" ~ action ~ "` unrecognised!";
			break;
			case "help", "h":
				outPut = "Help:
	help/h             - for this help
	remove/- #         - remove from list at #
	cls/clear          - clear screen
	sort               - sort files by days
	search/st (text)   - search text
	total/t            - sum up the costs
	scope/scp # #      - Selection scope
	*tofile (name)     - copy list to file
	*quit/q            - exit to OS
";
				return true;
			case "scope", "scp":
				if (doCheck == doesntCheckOut)
					return false;
				if (args[1].split.length != 2) {
					outPut = status = "Error, wrong number of operands.";

					return false;
				}
				try {
					outPut = _acnt.getScope(args[1].split[0].to!int, args[1].split[1].to!int);
				} catch(Exception e) {
					outPut = status = "Some operant error!";

					return false;
				}
				status = "Scope: " ~ args[1];
				return true;
			case "total", "t":
				outPut = status = "Total tmp: $" ~ _acnt.getTotal.to!string[0 .. $ - 3];
				return true;
			case "sort":
				if (doCheck == doesntCheckOut)
					return false;
				_acnt.doSort();
				outPut = status = "Sorted earlier to later";

				return true;
			case "search", "st":
				if (doCheck == doesntCheckOut)
					return false;

				import std.string;

				outPut = "Search: (" ~ args[1] ~ ")\n";
				outPut ~= _acnt.doSearch(args[1]) ~ "\n";
				outPut ~= "Search: (" ~ args[1] ~ ")";
				
			return true;
			case "-", "remove":
				if (doCheck == doesntCheckOut) {
					return false;
				} else {
					try {
						import std.algorithm: sort;

						auto nums = args[1 .. $].join(" ").split.to!(int[]).sort!"a > b";
						//auto nums = args[1 .. $].to!(int[]).sort!"a > b";
						foreach(i; nums)
							if (_acnt.removeAt(i) == ok) {
								outPut = outPut ~ "Removed " ~ i.to!string ~ "\n";
							} else {
								outPut = outPut ~ "Removed error! Invalid number: " ~ i.to!string ~ "\n";
							}
					} catch(Exception e) {
						outPut = status = "Error with remove!";
						return false;
					}

					return true;
				}
		}

		return false;
	}
	
	void loadAccount(in string fileName) {
		_acnt = new Account( fileName ~ ".ini" );
		assert(_acnt);
	}

	void saveAccount(immutable string fileName) {
		_acnt.saveAccount(fileName);
	}

	auto getFromIndex(in size_t index) {
		if (index < _acnt.getDBKCount)
			return _acnt.getDBKDataEntry(index);
		else
			throw new Exception("Out of range!");
	}

	auto dump() {
		string result;

		if (! _acnt) {
			moneyLogUpDateStatus("No account loaded!");
			return "Please load an account\n";
		}

		result = _acnt.getData;

		return result;
	}

	void addEntry(Data newData) {
		if (_acnt)
			_acnt.addEntry(newData);
		else
			moneyLogUpDateStatus("No account loaded..");
	}

	void setEntry(Data changedData, size_t index) {
		if (_acnt)
			_acnt.setEntry(changedData, index);
		else
			moneyLogUpDateStatus("No account loaded..");
	}

	auto getEntry() {
		import std.string;

		auto entry = new Data;

		void printData(string title) {
			with(entry)
				moneyLogUpDateStatus(title,
					format("%s.%02s.%s, shop: %s, cost: $%.02f, item: %s, Comment: %s",
						day, month, year, shop, cost, item, comment));
		}

		auto getDateEntry() {
			return getAppBox.getLeftPanelBox.getDateEntry;
		}
		auto getShopEntry() {
			return getAppBox.getLeftPanelBox.getShopEntry;
		}
		auto getCostEntry() {
			return getAppBox.getLeftPanelBox.getCostEntry;
		}
		auto getItemEntry() {
			return getAppBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry;
		}
		auto getCommentEntry() {
			return getAppBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry;
		}
		enum Date {day, month, year}
		int[3] date;
		try {
			date = getDateEntry.getText.split.to!(int[3]);
		} catch(Exception e) {

			upDateDump;
			moneyLogUpDateStatus("Error with date! - ", getDateEntry.getText);

			entry.index = -1;

			return entry;
		}
		with(entry) {
			try {
				day = date[Date.day];
				month = date[Date.month];
				year = date[Date.year];
				shop = getShopEntry.getText;

				import money, mmisc;
				//" 0.9+ 0.1 +9.1+   0.9 \n ".getParseMonInputStr.writeln;
				getCostEntry.setText = getCostEntry.getText.getParseMonInputStr;
				cost = bdub(getCostEntry.getText);
				item = getItemEntry.getText;
				comment = getCommentEntry.getText;
			} catch(Exception e) {
				printData("Error with entry! - ");
				index = -1;

				return entry;
			}
		}
		printData("Entry set - ");

		return entry;
	}
}
