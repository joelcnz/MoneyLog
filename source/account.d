//#What's with this - null this error?!
//#new
//# eg co 123 (_op being '123')
//#cool
//#how do I get rid of the extra space at the start of (cash..)
//#not sure how static works here
module account;

/*
Logged in. Calls detailed module
*/

import std.stdio;
import std.string;
import std.conv; // convert

import money;

import detailed;
import mmisc;
import data;

final static class Account { //#not sure how static works here, and isn't final for class's
	private:
	struct Operand {
		int i; // integer
		bdub f; // float (or what ever the bdub type is (it's in mmisc.d)
		string s; // string
	} // struct
	Operand opr;
//	allegro_init();
	// (date) - (item or shop) - (amount)
	/*
	12 6 2009 whare_house_Snickers 1.39
	*/
	DetailedBookKeeping dbk;
	//string select;
	int _op; //# eg co 123 (_op being '123')
	bool saved, done;
	string _handle;
	public:
	string handle() { return _handle; }
	string handle(string handle0) { return _handle=handle0; }
	this( string handle ) {
		dbk=new DetailedBookKeeping( this.handle=handle ); // for writing to file
		dbk.loadInFiles; // read files - detailed.d
		/+
		writefln("Enter help for help");
		opr=Operand(-1, bdub(0),""); //#cool
		with (opr)
			assert(i == -1 && f == bdub(0.0) && s == "");
		//select="";
		saved=true;
		done=false;
		//run(); // And this is run from the construtor
		+/
	}

	auto getScope(int start, int end) {
		return dbk.getScope(start, end);
	}

	auto getTotal() {
		return dbk.getTotal;
	}

	void doClear() {
		dbk.doClear;
	}

	void doSort() {
		dbk.doSort();
	}

	auto doSearch(in dstring searchText) {
		return dbk.doSearch(searchText);
	}

	void saveAccount(immutable string fileName) {
		import std.file;

		copy(fileName, "back_" ~ fileName); // back up
		dbk.populate_cfgFile(fileName);
	}

	auto getDBKCount() {
		return dbk.data.length;
	}

	auto getDBKDataEntry(in size_t index) {
		return dbk.data[index];
	}

	void addEntry(Data newData) { //#What's with this - null this error?!
		//dbk.data = dbk.data ~ newData;
		dbk.add(newData);
		dbk.dataTmp = dbk.data.dup;
		//writeln(dbk.data[$ - 1]);
	}

	void setEntry(Data changedData, size_t index) {
		dbk.setData(changedData, index);
		dbk.dataTmp = dbk.data.dup;
	}

	auto getData() {
		return dbk.getData;
	}

	void run() {
		while ( ! done ) {
			getInputReady();
			//executeInput();
		}
	}
	
	bool foundNums( string operand ) {
		return isNumeric(operand);
	}

	void getInputReady() {
		//writef("D>");
		//select=getLine("D>"); // get input from end user
//		char* rline = readline("D>");
//		select = rline.to!string;
//		if (select.length)
//			add_history(rline);
		long i=0;
		opr=Operand(-1,bdub(0),""c); //#What's this -> ""c
		/+
		try {
			// In this if statement:
			// what types are worked out (int, float, or string)
			if ( (i=select.indexOf(' '))!=-1 ) { // if is a space
				string operand=select[i+1..$];
				select=select[0..i]; // get the command piece
				if ( foundNums(operand)==true ) {
					try {
						opr.i=to!int( operand );
					} catch( Exception e ) {
						writefln("Integer number error: %s", e.toString);
						opr.i=-1;
					}
					if ( operand.indexOf('.')!=-1 ) {
						try {
							float a = to!float(operand);
							//opr.f=to!bdub( operand );
							opr.f = bdub(a);
						}
						catch( Exception e ) {
							writefln("Decimal number error: %s", e.toString);
							opr.f=bdub(0.0);
						}
					}
				} // if gotNums
				opr.s=operand;
			} // if (i=select.find(' ')
		} // try
		catch ( Exception e ) {
			writefln("Opps.. %s",e.toString);
		}
		+/
	}
	
	void executeInput(in string select) {
		switch(select) {
			case "help","h":
		writefln(
	"Help:
	help/h            - for help
	list/l            - display items
	add/a             - add new item
	remove/- #        - remove from list at #
	setDate/sd #      - set the date of slot #
	setItem/si #      - set the item slot
	setCost/sc #      - set the cost of the item
	setShop/sh #      - set what shop the items from 
	setComment/co /#  - Add a comment
	cls/clear         - clear screen
	total/t           - sum up the costs
	scope/scp         - Selection scope
	tofile (name)     - copy list to file
	search/st (text)  - search text
	save/sv           - write to HDD with the login name
	load              - load from HDD with the login name
	convert/c         - convert data tango version of this program
	sort              - sort files by days
	quit/q            - exit to OS
");
			break;
			case "append","ap":
				dbk.doAppend;
			break;
			case"sort":
				dbk.doSort();
			break;
			case "scope","scp":
				//dbk.getScope;
			break;
			case "setDate","sd":
				if ( opr.i!=-1 ) {
					dbk.setDate(opr.i);
				} else {
					writefln("Set date error: need an operand!");
				}
				saved=false;
			break;
			case "setItem","si":
				if ( opr.i!=-1 ) {
					dbk.setItem(opr.i);
				} else {
					writefln("Set item error: need an operand!");
				}
				saved=false;
			break;
			case "setCost","sc":
				if ( opr.i!=-1 ) {
					//float dummy=dbk.setCost(opr.i);
					auto dummy=dbk.setCost(opr.i);
				} else {
					writefln("Set cost error: need an operand!");
				}
				saved=false;
			break;
			case "setComment","co":
				long index;
				if ( opr.i != -1) // if eg 'co 126'
					index = opr.i;
				else
					index = dbk.data.length - 1; // just change the last entry
				//dbk.setComment(opr.i);
				try {
					dbk.setComment(cast(int)index);
				} catch(Exception e) {
					writefln("Add comment operand error!");
				}
				saved=false;
			break;
			case "setShop","sh":
				if (opr.s != "") {
					dbk.setShop(opr.i);
				} else {
					writefln("Needs a number for what entry.");
				}
				saved=false;
			break;
			case "convert","c":
				dbk.convertToTango();
				wf("Coverted file for tango version - called shopping.dat");
			break;
			case "search","st":
				if ( opr.s!="" )
					dbk.searchTextPrint(opr.s);
				else
					wf("search text operandChar missing!");
			break;
			case "load":
				dbk.loadInFiles;
			break;
			case "save","sv":
				//dbk.populate_cfgFile;
				saved=true;
				writefln("Saved.");
			break;
			case "tofile":
				dbk.toFile(opr.s);
			break;
			case "cls","clear":
				for( int l=0;l<60;l++ )
					writeln;
			/* D2
			 * foreach(l; 0 .. 60)
			 * 		wf;
			 */
			break;
			case "list","l":
				writefln("Display data");
				dbk.displayData();
			break;
			case "add", "a":
				dbk.getUserInputData();
				saved=false;
			break;
			case "remove", "rm", "-":
				dbk.removeAt(opr.i);
				saved=false;
			break;
			case "total","t":
				writefln( "The grand total is (drum roll please): " ~ cashToString(dbk.getTotal)); //#how do I get rid of the extra space at the start of (cash..)
			break;
			case "quit", "exit", "q","go out side and play":
				done=saveNExit();
			break;
			default:
				if ( select!="\n" && select!="" ) {
					writefln("Unidentefiled flying entry");
				}
			break;
		}
	}

	auto removeAt(int i) {
		return dbk.removeAt(i);
	}

	bool saveNExit() {
		if (saved == false) {
			writefln(`You have unsaved changes, would you like to save now Y\N\[C]ancel?`);
			bool done=false;
			do {
				/*
				string yn=getLine("");
				yn=toLower(yn);
				if ( yn.indexOf('c')>-1 ) {
					writefln("Exiting Canceled!");
					return false;
				}
				if ( yn.indexOf('y')>-1 )
					dbk.populate_cfgFile, done=true, writefln("Saved.");
				if ( yn.indexOf('n')>-1 )
					done=true, writefln("Not saved.");
				*/
			} while(! done);
		}
		return true;
	}
}
