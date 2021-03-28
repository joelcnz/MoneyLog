//# place holder would be good
module maingui;

import jmisc;

import base;

class MyHeaderBar : HeaderBar {
	bool decorationsOn = true;
	string title = "MoneyLog";
	string subtitle = "Poorly Programmed Productions";

	this() {
		super();
		setShowCloseButton(decorationsOn); // turns on all buttons: close, max, min
		version(Windows)
			setDecorationLayout("close:minimize,maximize,icon"); // no spaces between button IDs
		version(OSX)
			setDecorationLayout("close:maximize,icon");
		setTitle(title);
		setSubtitle(subtitle);
	}

} // class MyHeaderBar

class AppBox : Box {
    private:
	string loginName;
    bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;
    LeftPanelBox leftPanelBox;
    BigRightBox bigRightBox;

    public:
    this(string loginName) {
		this.loginName = loginName;
        super(Orientation.HORIZONTAL, globalPadding);

        leftPanelBox = new LeftPanelBox(loginName);
        bigRightBox = new BigRightBox();

		packStart(leftPanelBox, expand, fill, localPadding);
		packStart(bigRightBox, expand, fill, localPadding);

		addOnKeyPress(&keySelectFocusCallBack);

		if (! (loginName~".ini").exists) {
			writeln(`Invalid login name! Using "joelcnz"`);
			this.loginName = "joelcnz";
		}
    }

	auto getLeftPanelBox() {
		return leftPanelBox;
	}

	auto getBigRightBox() {
		return bigRightBox;
	}

	bool keySelectFocusCallBack(Event ev, Widget w) {
		if (ev.key.state == GdkModifierType.CONTROL_MASK) {
			switch(ev.key.keyval) {
				default: break;
				case GdkKeysyms.GDK_r: g_World.setFocus(leftPanelBox.getRefNumEntry); return true;
				case GdkKeysyms.GDK_d: g_World.setFocus(leftPanelBox.getDateEntry); return true;
				case GdkKeysyms.GDK_h: g_World.setFocus(leftPanelBox.getShopEntry); return true;
				case GdkKeysyms.GDK_g: g_World.setFocus(leftPanelBox.getCostEntry); return true;
				case GdkKeysyms.GDK_b: g_World.setFocus(bigRightBox.getCommandHorizontalBox.getCommandEntry); return true;
				case GdkKeysyms.GDK_i: g_World.setFocus(bigRightBox.getItemLabelEntryHorizontalBox.getEntry); return true;
				case GdkKeysyms.GDK_m: g_World.setFocus(bigRightBox.getCommentLabelEntryHorizontalBox.getEntry); return true;
			}
		}

		return false;  
	}
}

class LeftPanelBox : VerticalBox {
	private:
    Label loginHeaderLabel;
    string loginHeaderString = "-=| Login |=-";
    Entry loginNameEntry;
    Label refNumLabel;
    string refNumString = "Ref Num";
	Entry refNumEntry;
	string refNumPlaceHolderString = "(Ctrl + R)";
    Button loadRefNumButton;
    string loadRefNumString = "Load Ref";
    Label dateLabel;
    string dateString = "Date (D M Y)";
    Entry dateEntry;
	string datePlaceHolderString = "(Ctrl + D)";
	Label shopLabel;
	string shopString = "Shop";
	Entry shopEntry;
	string shopPlaceHolderString = "(Ctrl + H)";
	Label costLabel;
	string costString = "Cost";
	Entry costEntry;
	string costPlaceHolderString = "(Ctrl + G)";
	Button addButton;
	string addString = "Add";
	Button setButton;
	string setString = "Set";
	Button refreshButton;
	string refreshString = "Refresh";
	Button saveButton;
	string saveString = "Save";
	Button miscButton;
	string miscString = "misc";
	
    public:
    this(string loginName) {
        loginHeaderLabel = new Label(loginHeaderString);
        loginNameEntry = new Entry(loginName);
        refNumLabel = new Label(refNumString);
		refNumEntry = new Entry();
        loadRefNumButton = new Button(loadRefNumString, &loadRefNumClick);
        dateLabel = new Label(dateString);
        dateEntry = new Entry();
		shopLabel = new Label(shopString);
		shopEntry = new Entry();
		costLabel = new Label(costString);
		costEntry = new Entry();
		addButton = new Button(addString, &addClick);
		setButton = new Button(setString, &setClick);
		refreshButton = new Button(refreshString, &refreshClick);
		saveButton = new Button(saveString, &saveClick);
		miscButton = new Button(miscString, &miscClick);
		
		refNumEntry.setPlaceholderText(refNumPlaceHolderString);
		dateEntry.setPlaceholderText(datePlaceHolderString);
		shopEntry.setPlaceholderText(shopPlaceHolderString);
		costEntry.setPlaceholderText(costPlaceHolderString);

		import std.datetime : DateTime, Clock;
		import std.conv : text;

		auto dt = cast(DateTime)Clock.currTime();
		dateEntry.setText = text(dt.day, " ", cast(int)dt.month, " ", dt.year);

        expand = fill = false;
        packStart(loginHeaderLabel, expand, fill, localPadding);
        packStart(loginNameEntry, expand, fill, localPadding);
        packStart(refNumLabel, expand, fill, localPadding);
		packStart(refNumEntry, expand, fill, localPadding);
        packStart(loadRefNumButton, expand, fill, localPadding);
        packStart(dateLabel, expand, fill, localPadding);
        packStart(dateEntry, expand, fill, localPadding);
		packStart(shopLabel, expand, fill, localPadding);
		packStart(shopEntry, expand, fill, localPadding);
		packStart(costLabel, expand, fill, localPadding);
		packStart(costEntry, expand, fill, localPadding);
		packStart(addButton, expand, fill, localPadding);
		packStart(setButton, expand, fill, localPadding);
		packStart(refreshButton, expand, fill, localPadding);
		packStart(saveButton, expand, fill, localPadding);

		packStart(miscButton, expand, fill, localPadding);

		loginNameEntry.addOnActivate(&loginNameEnterCallBack);
    }

	void loginNameEnterCallBack(Entry e) {
		immutable name = loginNameEntry.getText~".ini";
		if (exists(name)) {
			g_World.loadAccount(loginNameEntry.getText);
			g_World.upDateDump;
			moneyLogUpDateStatus("'", name, "' - account loaded");
		} else {
			moneyLogUpDateStatus("'", name, "' - account doesn't exist");
		}
	}

    void loadRefNumClick(Button b) {
		size_t index;
		long numForException;
		try {
			numForException = refNumEntry.getText.to!long;
			index = numForException.to!size_t;
		} catch(Exception e) {
			moneyLogUpDateStatus("Invalid reference number! - ", numForException);
			return;
		}

		try {
			auto entry = g_World.getFromIndex(index);

			with(entry) {
				dateEntry.setText = text(day, " ", month, " ", year);
				if (shop != "")
					shopEntry.setText = shop;
				else
					shopEntry.setText = "";

				if (cost.to!string[0 .. $ - 3] != "")
					costEntry.setText = cost.to!string[0 .. $ - 3];
				else
					costEntry.setText = "0";

				if (item != "")
					g_World.getAppBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry.setText = item;
				else
					g_World.getAppBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry.setText = "";
					
				if (comment != "")
					g_World.getAppBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry.setText = comment;
				else
					g_World.getAppBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry.setText = "";
			}
		} catch(Exception e) {
			moneyLogUpDateStatus("Some error with load reference, check it!");
			return;
		}
		moneyLogUpDateStatus("Loaded reference. - ", index);
	}

    void addClick(Button b) {
		auto entry = g_World.getEntry;

		if (entry.index == fail) {
			moneyLogUpDateStatus("Error adding entry!");

			return;
		} else {
			try {
				g_World.addEntry(entry);
			} catch(Exception e) {
				moneyLogUpDateStatus("Some thing went wrong!");
				return;
			}
			g_World.upDateDump;
		}
    }

    void setClick(Button b) {
		auto entry = g_World.getEntry;

		if (entry.index == fail) {
			moneyLogUpDateStatus("Entry fail!");
			return;
		}

		size_t refNum = size_t.max;

		try {
			refNum = getRefNumEntry.getText.to!size_t;
		} catch(Exception e) {
			moneyLogUpDateStatus("Set entry - ", getRefNumEntry.getText, ", failed");

			return;
		}

		if (refNum == size_t.max) {
			moneyLogUpDateStatus("Error with reference number!");

			return;
		}
		g_World.setEntry(entry, refNum);
		g_World.upDateDump;
		moneyLogUpDateStatus("Entry set - ", refNum);
    }

    void refreshClick(Button b) {
		g_World.upDateDump;
		moneyLogUpDateStatus("Refreshed");
    }

    void saveClick(Button b) {
		immutable fileName = loginNameEntry.getText ~ ".ini";

		g_World.saveAccount(fileName);
		jm_backUp(fileName);
		moneyLogUpDateStatus("Saved ", fileName, " - saved the old one as back_", fileName);
    }

	void miscClick(Button b) {
		moneyLogUpDateStatus("Misc clicked!");
	}

	auto getLoginNameEntry() {
		return loginNameEntry;
	}

	auto getRefNumEntry() {
		return refNumEntry;
	}

	auto getDateEntry() {
		return dateEntry;
	}

	auto getShopEntry() {
		return shopEntry;
	}

	auto getCostEntry() {
		return costEntry;
	}

/+
	auto getBigRightBoxScrolled() {
		return ;
	}
+/
}

class BigRightBox : VerticalBox {
    private:
    Label mainViewHeaderLabel;
    string mainViewHeaderString = "-=| Dump |=-";
    ScrolledTextWindow scrolledTextWindowMain;
	Label historyHeaderLabel;
	string historyHeaderString = "-=| History |=-";
	ScrolledTextWindow historyScrolledTextWindow;
	CommandHorizontalBox commandHorizontalBox;
	LabelEntryHorizontalBox itemLabelEntryHorizontalBox;
	string itemLabelEntryHorizontalBoxString = "Item:";
	string itemLabelEntryHorizontalBoxPlaceHolderString = "(Ctrl + I)";
	LabelEntryHorizontalBox commentLabelEntryHorizontalBox;
	string commentLabelEntryHorizontalBoxString = "Comment:";
	string commentLabelEntryHorizontalBoxPlaceHolderString = "(Ctrl + M)";
	Label statusLabelHeader;
	string statusLabelHeaderString = "-=| Status |=-";
	Label statusLabel;
	string statusLabelString = "Loading..";

	TextBuffer shortCutTextBuffer;

    public:
    this() {
        mainViewHeaderLabel = new Label(mainViewHeaderString);
        scrolledTextWindowMain = new ScrolledTextWindow();
		historyHeaderLabel = new Label(historyHeaderString);
		historyScrolledTextWindow = new ScrolledTextWindow();
		commandHorizontalBox = new CommandHorizontalBox();
		itemLabelEntryHorizontalBox = new LabelEntryHorizontalBox(itemLabelEntryHorizontalBoxString,
			itemLabelEntryHorizontalBoxPlaceHolderString);
		commentLabelEntryHorizontalBox = new LabelEntryHorizontalBox(commentLabelEntryHorizontalBoxString,
			commentLabelEntryHorizontalBoxPlaceHolderString);
		statusLabelHeader = new Label(statusLabelHeaderString);
		statusLabel = new Label(statusLabelString);

		int width = 1_200, height = 440;
		scrolledTextWindowMain.setSizeRequest(width, height);
		height = 100;
		historyScrolledTextWindow.setSizeRequest(width, height);

        expand = fill = false;
        packStart(mainViewHeaderLabel, expand, fill, localPadding);
        expand = fill = true;
        packStart(scrolledTextWindowMain, expand, fill, localPadding);
		packStart(historyHeaderLabel, expand, fill, localPadding);
		packStart(historyScrolledTextWindow, expand, fill, localPadding);
		packStart(commandHorizontalBox, expand, fill, localPadding);
		packStart(itemLabelEntryHorizontalBox, expand, fill, localPadding);
		packStart(commentLabelEntryHorizontalBox, expand, fill, localPadding);
		packStart(statusLabelHeader, expand, fill, localPadding);
		packStart(statusLabel, expand, fill, localPadding);

		shortCutTextBuffer = scrolledTextWindowMain.getMyTextView.getTextBuffer;
    }

	auto getTextBufferMain() {
		//assert(scrolledTextWindowMain.getMyTextView.getTextBuffer);
		return shortCutTextBuffer;
	}

	auto getMainTextScrolled() {
		return scrolledTextWindowMain;
	}

	auto getHistoryScrolled() {
		return historyScrolledTextWindow;
	}

	auto getHistoryTextBuffer() {
		assert(historyScrolledTextWindow.getMyTextView.getTextBuffer);
		return historyScrolledTextWindow.getMyTextView.getTextBuffer;
	}

	auto getCommandHorizontalBox() {
		return commandHorizontalBox;
	}

	auto getItemLabelEntryHorizontalBox() {
		return itemLabelEntryHorizontalBox;
	}

	auto getCommentLabelEntryHorizontalBox() {
		return commentLabelEntryHorizontalBox;
	}

	auto getStatus() {
		return statusLabel;
	}
}

class CommandHorizontalBox : HorizontalBox {
	private:
	Label commandLabel;
	string commandLabelString = "Command:";
	Entry commandEntry;
	string commandEntryPlaceHolder = "(Ctrl + B)";
	Button processLineButton;
	string processLineString = "Process";
	CheckButton appendCheckButton;
	string appendString = "Append";

	public:
	this() {
		commandLabel = new Label(commandLabelString);
		commandEntry = new Entry();
		processLineButton = new Button(processLineString, &processClick);
		appendCheckButton = new CheckButton(appendString);

		commandEntry.setPlaceholderText(commandEntryPlaceHolder);
		
		expand = fill = false;
		packStart(commandLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(commandEntry, expand, fill, localPadding);
		expand = fill = false;
		packStart(processLineButton, expand, fill, localPadding);
		packStart(appendCheckButton, expand, fill, localPadding);

		commandEntry.addOnActivate(&commandEnterCallBack);
	}

	void commandEnterCallBack(Entry e) {
		auto editBoxDump() {
			return g_World.getAppBox.getBigRightBox.getTextBufferMain;//g_World.getAppBox.getBigRightBox.getTextWindowMain;
		}

		moneyLogUpDateStatus("Activate - ", e.getText);
		string outPut;

		void doDump() {
			if (! appendCheckButton.getActive)
				editBoxDump.setText = "";
			auto text = editBoxDump.getText;
			editBoxDump.setText(text ~ (text.length > 0 ? "\n" : "") ~ outPut);
		}

		if (e.getText == "cls"
			||
			e.getText == "clear") {
			e.setText = "";
			g_World.doClear;
			moneyLogUpDateStatus("Clear");

			return;
		}
		string status;
		if (! g_World.activate(e.getText, outPut, appendCheckButton.getActive, status)) {
			moneyLogUpDateStatus("Activate ", e.getText, " error!");
			doDump;

			return;
		}
		doDump;
		if (status.length) {
			moneyLogUpDateStatus(status);
		}
	}

	auto getCommandEntry() {
		return commandEntry;
	}

	void processClick(Button b) {
		// moneyLogUpDateStatus("Process clicked!");
		import std.string : split, strip, indexOf;
		auto raw = commandEntry.getText;
		auto d = raw.to!(char[]);
		if (d.indexOf("$") == -1) {
			moneyLogUpDateStatus("Error (no dollar sign), check data..");
			return;
		}
		d[d.indexOf("$")] = ';';
		auto data = d.to!string;
		auto getSegs = data.split(";");
		if (getSegs.length > 5) {
			moneyLogUpDateStatus("Error (too many sections - ",getSegs.length , "), check data..");
			return;
		}

		string[5] segs;
		foreach(i, s; getSegs)
				segs[i] = s.strip;
		writeln(segs);
		enum {DATE,COST,SHOP,ITEM,COMMENT}
		auto getAppBox() {
			return g_World.getAppBox;
		}
		try {
			getAppBox.getLeftPanelBox.getDateEntry.setText = segs[DATE].length ? segs[DATE] : "";
			getAppBox.getLeftPanelBox.getShopEntry.setText = segs[SHOP].length ? segs[SHOP] : "";
			getAppBox.getLeftPanelBox.getCostEntry.setText = segs[COST].length ? segs[COST] : "";
			getAppBox.getBigRightBox.getItemLabelEntryHorizontalBox.getEntry.setText = segs[ITEM].length ? segs[ITEM] : "";
			getAppBox.getBigRightBox.getCommentLabelEntryHorizontalBox.getEntry.setText = segs[COMMENT].length ? segs[COMMENT] : "";
		} catch(Exception e) {
			moneyLogUpDateStatus("Some error, check the data..");
			return;
		}
		moneyLogUpDateStatus("Processed: ", raw);
	}
}

class LabelEntryHorizontalBox : HorizontalBox {
	private:
	Label label;
	string labelString;
	Entry entry;
	string placeHolder;

	public:
	this(string labelString, string placeHolder) {
		label = new Label(labelString);
		entry = new Entry();

		entry.setPlaceholderText(placeHolder);

		expand = fill = false;
		packStart(label, expand, fill, localPadding);
		expand = fill = true;
		packStart(entry, expand, fill, localPadding);
	}

	auto getEntry() {
		return entry;
	}
}

class VerticalBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	public:
	this()
	{
		super(Orientation.VERTICAL, globalPadding);
		
	} // this()
	
} // class VerticalBox

class HorizontalBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	public:
	this()
	{
		super(Orientation.HORIZONTAL, globalPadding);
		
	} // this()
	
} // class HorizontalBox

class ScrolledTextWindow : ScrolledWindow {
	MyTextView myTextView;
	
	this()
	{
		super();
		
		myTextView = new MyTextView("");
		add(myTextView);
		
	} // this()

	auto getMyTextView() {
		return myTextView;
	}
}

class MyTextView : TextView
{
	private:
	TextBuffer textBuffer;
	string _content;
	//TextIter textIter;
	
	public:
	this(string content)
	{
		super();
		textBuffer = getBuffer();
		//textIter = new TextIter();
		_content = content;
		setWrapMode(GtkWrapMode.WORD);

		textBuffer.setText(_content);
	}

	auto getTextBuffer() {
		return textBuffer;
	}

/+
	auto getTextIter() {
		return textIter;
	}
	+/
} // class MyTextView
