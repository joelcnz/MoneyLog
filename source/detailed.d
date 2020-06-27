//#Should get rid of it altogether
//# $ - 3 - get rid of the 'NZD' part

//#what is 'count' for?
//#not work with DUB
//#(temp)_date.month = m; - What is this?!
//#toFile - question here
//#question here
//#Need to further the search to include shops and comments
//#not used
//#it would be better not to save at this point
//#I don't think I need this 'dup', (if in dought, add it)
//#don't know if this is right for getting the right date etc
//#I think this is half a day out. The time seems to be wrong before midday.
//#convertToTango, armm I don't seem to be able to find some thing in tango that would use this
//#toFile
//#load configuration file
module detailed;

//version = ini;
version = djini;

import std.stdio;
import std.string;
import std.file;
import std.conv; // convert
import std.datetime;

//#new
version(ini)
	import ini.ini;
version(djini) {
	import dini.dini;
	import dini.jinisav;
}

import money;

import jmisc;

import base, data, mmisc;

//#not work with DUB - works by putting in the dub.json file, though.
//pragma(lib, "readline");
//pragma(lib, "curses");

//final
class DetailedBookKeeping {
	private:
	Data[] _data;
	Data[] _dataTmp;
	string shoppingCfg;
	DetailedBookKeeping _DBKLast; //#not used
	bool inBounds(int index) {
		if (index < 0 || index >= data.length) {
			writefln("Index out of bounds");
			return false;
		}
		return true;
	}

	Date _date;
	ulong _index;
	public:
	Data[] data() { return _data; }
	Data[] data(Data[] data0) { return _data = data0; }
	Data[] dataTmp() { return _dataTmp; }
	Data[] dataTmp(Data[] tmp) { return _dataTmp = tmp; }
	int count() { return cast(int)data.length; } //#what is 'count' for?
	void count(long count0) { _data.length = count0; }
	this(string shoppingCfg) {
		this.shoppingCfg=shoppingCfg; // and this.shoppingCfg is private - so why does it not have a underscore
		auto d = cast(DateTime)Clock.currTime();

		_date.day = d.day;
		_date.month = d.month;
		_date.year = d.year;
		/+
		_date(d.day,
			d.month,
		      d.year);
		+/
		//long d=UTCtoLocalTime(getUTCtime());
		//_date(DateFromTime(d), MonthFromTime(d) + 1, YearFromTime(d));
		_index = 0; //data.length - 1;
	}

	auto getTotal() {
		bdub total = 0;
		foreach(d;dataTmp)
			total += d.cost;

		return total;
	}

	void doClear() {
		_dataTmp.length = 0;
	}
	
	void displayData() {
		foreach( d;dataTmp )
			d.display, writeln;
	}

	auto getData() {
		assert(data.length);
		string result;
		foreach(d; data) {
			result ~= d.toString ~ "\n";
		}
		dataTmp = data.dup;

		return result;
	}

	void doAppend() {
		writefln("Enter account to merge with:");
		DetailedBookKeeping second;
		try {
			second=new DetailedBookKeeping(getLine(""));
		} catch (Exception e) {
			writefln("Error: file not found probably.");
			return;
		}
		foreach(d; second.data)
			_dataTmp ~= d;
	}
	
	void doSort() {
		import std.algorithm: sort;

		sort!"a.jdate() < b.jdate()"(_data);
		//#Should get rid of it altogether
		foreach(i, d; _data)
			d.index = cast(int)i;

		_dataTmp = data.dup;
		writeln("All sorted .. maybe.");
	}

	auto getScope(int start, int end) {
		if (end < start || start < 0 || start > data.length - 1 ||
			end < 0 || end > data.length - 1) {

			return "Out of bounds, try again.";
		}
		//Display list
		string result;

		_dataTmp.length = 0;
		foreach(d; data[start .. end + 1]) {
			_dataTmp ~= d;
			result ~= d.toString.to!string ~ "\n";
		}

		return result;
	}

	auto doSearch(string searchText) {
		import std.conv;

		string result;
		int itemCount;

		searchText = toLower(searchText);
		Data[] tmp = _dataTmp.dup;
		_dataTmp.length = 0;
		foreach(d; tmp) {
			//#Need to further the search to include shops and comments
			/+
			if (indexOf(toLower(d.item), searchText) != -1
				||
				indexOf(format("%s %s %s", d.day, d.month, d.year), searchText) != -1
				||
				indexOf(toLower(d.comment), searchText) != -1
				||
				indexOf(toLower(d.shop), searchText) != -1
				||
				indexOf(text("$", d.cost), searchText) != -1
				) { //#question here
			+/
			import std.algorithm: canFind;
			if (toLower(d.to!string).canFind(searchText)) {
				result ~= d.toString.to!string ~ "\n";
				itemCount += 1;

				_dataTmp ~= d;
			}
		}
		result ~= text("Item count: ", itemCount).to!string;
		
		return result;
	}

	// list all elements with the search text inside
	void searchTextPrint( string text ) {
		text=toLower(text);
		auto tmp = _dataTmp.dup;
		_dataTmp.length=0;
		foreach( d;data )
			//#Need to further the search to include shops and comments
			if ( indexOf(toLower(d.item),text)!=-1 ) { //#question here
				_dataTmp~=d;
				writefln(d.lot());
			}
		writefln("Item count: ",dataTmp.length);
	}
	
	//#toFile - question here
	void toFile(string filen) {
		string all_data;
		foreach( l;data ) { // l - line of item
			all_data~=l.lot~"\n";
		}
		File(filen~".txt").write(all_data);
	}
	
	void setComment(int index) {
		writefln( "index: ", index );
		if ( !inBounds( index  ) ) {
			writefln( "Out of bounds!" );
			return;
		}
		writef("Enter comment (or q): ");
		string comment0 = getLine("Enter comment (or q): "); // get user input
		if ( comment0!="q" ) {
			data[ index ].comment = comment0;
		} else {
			writefln( "Comment aborted!" );
		}
	}
	/+
	void setCommentOld(int index) {
		if ( ! inBounds(index) )
			return;
		string comment0;
//		writef("Enter comment: ");
		comment0=getLine("Enter comment: "); // get user input
		if ( comment0!="q" ) {
			data[index].comment=comment0;
		}
	}
	+/

	bool setDate(int index) {
		if ( ! inBounds(index) )
			return false;
		string day0,month0,year0;
		bool done=true;
		do {
			done=true;
			try {
				writefln("Enter 'q' to cancel at any time:");
				day0 = getLine("Day: ");
				if ( day0[0]!='q' ) {
					//writef("Month: ")
					month0 = getLine("Month: ");
					if ( month0[0]!='q' ) {
						//writef("Year: ")
						year0 = getLine("Year: ");
					}
				}
				if ( day0=="q" || month0=="q" || year0=="q" ) {
					writefln("Data editing canceled");
					return false;
				}
				with ( data[index] ) {
					day=to!int( day0 );
					month=to!int( month0 );
					year=to!int( year0 );
				}
			}
			catch ( Exception e ) {
				if ( ! (day0[0]=='q' || month0[0]=='q' || year0[0]=='q') )
					writefln(`'%s'. Error with day, month or year input, try again`,e.to!string);
				done=false;
			}
		} while( ! done	);
		with (data[index]) {
			_date = Date(year, month, day);
			//int d = day;
			//int m = month;
			//int y = year;

			//_date = Date(d, m, y);
			//_date.day = d;
			//#(temp)_date.month = m; - What is this?!
			//_date.month = m; // this has been added, I'm not sure what I'm doing!
			//_date.year = y;
		}
		return true;
	}

	bool setItem(int index) {
		if ( ! inBounds(index) )
			return false;
		string item0;
//		writef("Item: ");
		item0=getLine("Item: ");
		if ( item0!="q" ) {
			data[index].item=item0;
			return true;
		}
		return false;
	}

	bool setCost(int index) {
		if ( ! inBounds(index) )
			return false;
		string cost0;
		bdub cost=0.0f;
		bool done=true;
		do {
			done=true;
			try {
//				writef("Cost: ");
				cost0=getLine("Cost: ");
				if ( cost0[0]!='q' ) {
					auto a = to!float(cost0);
					//cost = to!float( cost0 );
					cost = bdub(a);
				}
				else
					return false;
			}
			catch( Exception e ) {
				writefln("Decimal number error: %s Try again.", e.toString );
				done=false;
			}
		} while( ! done );
		data[index].cost=cost;
		return true;		
	}
	
	bool setShop(int index) {
		if ( ! inBounds(index) )
			return false;
		string shop0;
		//writef("Shop: ");
		shop0=getLine("Shop: ");
		if (shop0 != "q") {
			data[index].shop=shop0;
			return true;
		}
		return false;
	}
	
	void add(Data d) {
		_data ~= d;
		reIndex;
	}

	void setData(Data changedData, size_t index) {
		if (index >= _data.length)
			writeln("Out of bounds!");
		else {
			_data[index] = changedData;
			reIndex;
		}
	}

	bool getUserInputData() {
		add( new Data() );
		writef("(%d)", data.length - 1);
		
		/*
		//d_time d=getUTCtime();
		long d=UTCtoLocalTime(getUTCtime()); //#I think ignore these other #'s with this 
		with ( data[$-1] ) {
			//d+=1000*60*60*12; //#don't know if this is right for getting the right date etc
			day=DateFromTime(d); //#why date and not day, this is incosistant(sp)
			//day=DateFromTime(d); //#I think this is half a day out. The time seems to be wrong before midday.
			month=MonthFromTime(d)+1;
			year=YearFromTime(d);
		} // with tmpData (just the date changed)
		*/
		/*
		with (data[$ - 1]) {
			day = _date.day;
			month = _date.month;
			year = _date.year;
		}
		*/
		// enter item and cost
		if (setShop(cast(int)data.length - 1) == false || setItem(cast(int)data.length - 1) == false ||
		    setCost(cast(int)data.length - 1) == false || setDate(cast(int)data.length - 1) == false) {
			count = count - 1;
			wf("Action canceled!");
			return false;
		}
		dataTmp=data.dup; //#I don't think I need this 'dup', (if in dought, add it)
		_index = data.length - 1;
		return true;
	}
	
	//#load configuration file
	void loadInFiles() { // read data
		_dataTmp.length=0;
		int i=0;
		Ini ini;
		string sec;
		int geti( string name ) {
			version(ini)
				string str=ini[sec][name];
			version(djini)
				string str=ini[sec].getKey(name);
			return to!int(str);
		}
		try {
			version(djini) {
				ini = Ini.Parse(shoppingCfg);
				if (ini["section0"].getKey("day") is null) {
					writefln(shoppingCfg, " - File empty!");
				}
			}
			version(ini) {
				ini=new Ini( shoppingCfg ); // does it clear the ini file?
				if ( ini["section0"] is null ) {
					writefln("File empty!");
				}
			}
		}
		catch ( Exception e ) {
			writefln("In detailed.loadInFiles (new Ini..): %s",e.to!string);
		}

//#stuff
		try {
			auto tmp=new Data;
			bool done=false;
			count = 0;
			do {
				sec=format("section%d",i);
				with ( tmp ) {
					version(ini) {
						if ( ini[sec]["day"] !is null ) {
							day=geti("day");
							month=geti("month");
							year=geti("year");
							item=ini[sec]["item"];
							cost=to!float(ini[sec]["cost"]);
							shop=ini[sec]["shop"];
							comment=ini[sec]["comment"];
							add( new Data(day,month,year,item,cost,shop,comment) );
						} else {
							done=true;
						}
					}
					version(djini) {
						//if (ini[sec].getKey("day") != "") {
						try {
							day=geti("day");
							month=geti("month");
							year=geti("year");
							item=ini[sec].getKey("item");
							
							auto a = to!float(ini[sec].getKey("cost"));
							//cost=to!float(ini[sec].getKey("cost"));
							cost = bdub(a);
							
							shop=ini[sec].getKey("shop");
							comment=ini[sec].getKey("comment");
							add( new Data(day,month,year,item,cost,shop,comment) );
							//} else {
						} catch(Exception e) {
							done = true;
						}
							//}
					}
				} // with tmp
				i++;
			} while (! done);
		} // try
		catch ( Exception e ) {
			writefln("In detailed.loadInFile loop: %s",e.to!string);
		}
		dataTmp=data.dup;
		_index = data.length - 1;
	}
	/+
	0day=31
	0month=7
	+/
//#convertToTango, armm I don't seem to be able to find some thing in tango that would use this
	void convertToTango() {
		string filen="shopping.dat";
		string dat;
		foreach(i,d;data) {
			with( d ) {
				// not sure about the '\n''s, can't see spacing working either
				append(filen,format("%dday=%d\n%dmonth=%d\n%dyear=%d" ~ // append?
						"\n%ditem=%s\n%dcost=%0.2f\n%dshop=%s\n%dcomment=%s\n",
						i,day,i,month,i,year,
						i,item,i,cost,i,shop,i,comment));
			}
		}
	}

	//#populate_cfgFile
	/// makes a back up of cfg file
	/// then erases cfg file, it goes through the data and adds it
	void populate_cfgFile(in string fileName) { // write data to HDD
		// 1st part
		Ini ini;
		int i=0;
		string sec="";
		//#What's this!? I guess this might go in at the end of djini saveIni..
		/+
		try {
			// wipe configure file
			std.file.write( shoppingCfg,cast(string)"" );
		}
		catch ( Exception e ) {
			wf("In dbk populate_cfgFile (1st part): %s",e.toString );
		}
		+/
		
		version(djini) {
	    	SectionNameAndKey[] snaks;
		}
		
		version(ini)
			ini = new Ini(shoppingCfg);

		// Second part
		try {		
			/// Now we go and save to the configuration file
			i=0;
			foreach(d;data ) {
				sec=format("section%d",i);
				version(ini)
					ini.addSection(sec);
//				writefln("[%s]",sec);
				with( d ) {
					version(djini) {
						snaks ~= SectionNameAndKey(sec, "day", to!string(day));
						snaks ~= SectionNameAndKey(sec, "month", to!string(month));
						snaks ~= SectionNameAndKey(sec, "year", to!string(year));
						snaks ~= SectionNameAndKey(sec, "item", item);
						snaks ~= SectionNameAndKey(sec, "cost", to!string(cost)[0 .. $ - 3]); //# $ - 3 - get rid of the 'NZD' part
						snaks ~= SectionNameAndKey(sec, "shop", shop);
						snaks ~= SectionNameAndKey(sec, "comment", comment);
					}

					version(ini) {
						try { ini[sec]["day"]=to!string( day ); }     catch ( Exception e ) { writefln("%s: %s",day.stringof,     e.to!string); }
						try { ini[sec]["month"]=to!string( month ); } catch ( Exception e ) { writefln("%s: %s",month.stringof,   e.to!string); }
						try { ini[sec]["year"]=to!string( year ); }   catch ( Exception e ) { writefln("%s: %s",year.stringof,    e.to!string); }
						try { ini[sec]["item"]=item.dup; }            catch ( Exception e ) { writefln("%s: %s",item.stringof,    e.to!string); }
						try { ini[sec]["cost"]=to!string( cost ); }   catch ( Exception e ) { writefln("%s: %s",cost.stringof,    e.to!string); }
						try { ini[sec]["shop"]=shop.dup;  }           catch ( Exception e ) { writefln("%s: %s",shop.stringof,    e.to!string); }
						try { ini[sec]["comment"]=comment.dup; }      catch ( Exception e ) { writefln("%s: %s",comment.stringof, e.to!string); }
					}
				}
				i++;
			}
		} // try
		catch ( Exception e ) {
			writefln("In dbk populate function (2nd part): %s",e.to!string );
		}

		version(djini) {
			string fileName0 = fileName; // from immutable to just string
			saveIni(fileName0, snaks, /* doCounter */ true);
		}
		
		version(ini)
			try { ini.save(); } catch( Exception e ) { writefln("ini.save in populate..: %s", e.to!string ); }
		
		writeln(fileName, " - file saved");
	} // populate function
	
	//#removeAt
	auto removeAt(int at) {
		if (data.length == 0
			||
			at < 0
			||
			at >= count) {
			writefln(`Can't remove at %d`,at );
			return false;
		}
		if (at != data.length-1) {
			writeln("Remove an item -> ", data[at]);
			_data = data[0 .. at] ~ data[at + 1 .. $];
		} else {
			writeln("count one knotch back");
			count = count - 1;
		}
		_dataTmp = data;
		reIndex;
		//#it would be better not to save at this point
		//populate_cfgFile; // save to HDD
		//loadInFiles; // update

		return true;
	}
	
	void reIndex() {
		foreach(i, d; _data)
			d.index=cast(int)i;
	}
}
