//#I don't think this is even used
module data;

import std.stdio;
import std.string;

import money;

import jmisc;

import mmisc;

final class Data {
private:
	int _index;
	int _day,_month,_year;
	string _shop;
	string _item;
	bdub _cost;
	string _comment;
public:
	int index() { return _index; }
	int index(int index0) { return _index=index0; }
	int day() { return _day; }
	int month() { return _month; }
	int year() { return _year; }
	int day(int day0) { return _day=day0; }
	int month(int month0) { return _month=month0; }
	int year(int year0) { return _year=year0; }
	
	auto jdate() {
		import std.datetime;

		Date date;
		try {
			date = Date(year, month, day);
		} catch(Exception e) {
			date = Date(1,1,1);
		}

		return date;
	}
	
	string shop() { return _shop; }
	string shop(string shop0) { return _shop=shop0; }
	string item() { return _item; }
	string item(string item0) { return _item=item0; }
	bdub cost() { return _cost; }
	bdub cost(bdub cost0 ) { return _cost=cost0; }
	string comment() { return _comment; }
	string comment(string comment0) { return _comment=comment0; }
	
	override string toString() {
		import std.conv;
		import std.datetime;
		import std.ascii: toUpper;

		string dayOfWeek;
		try {
			dayOfWeek = Date(year, month, day).dayOfWeek.to!string;
		} catch(Exception e) {
			dayOfWeek = "#:#:# Error!";
		}

		return text("(", index, ") ", dayOfWeek[0].toUpper, dayOfWeek[1 .. $], " ", day, ".", month, ".", year,
			" $", cost.to!string[0 .. $ - 3], // remove 'NZD'
			(item == "" ? "" : ", Item: "), item,
			(shop == "" ? "" : ", Shop: "), shop,
			(comment == "" ? "" : ", Comment: "), comment);
	}

	//#I don't think this is even used
	this() {
		day=month=year=0;
		shop=""; //#or should I put null
		item="";
		cost=bdub(0.0);
		comment="";
	}

	this(int day, int month,int year, string item, bdub cost, string shop, string comment) {
		this.day=day; this.month=month; this.year=year;
		this.shop=shop;
		this.item=item.dup;
		this.cost=cost; 
		this.comment=comment;
	}
	
	Data display() { // int index) {
		writef(lot);
		return this;
	}
	
	Data newline() {
		writeln;
		return this;
	}

	string lot() {
		string date=format("%2d/%02d/%d",day,month,year);
		string all=format("%-10s (%3d) %-50s %s",date, index, item,cashToString(cost,"   "));
		auto nothing = "";

		if (shop != nothing || comment != nothing)
			all ~= "\n";
		if (shop != nothing)
			all ~= "Shop: " ~ shop;
		if (comment != nothing) // or should I put 'comment !is null' or ' if comment != nothing (and define nothing of course)
			 all ~= " Comment: " ~ comment;
		import std.range;
		all ~= "\n" ~ "-".replicate(10);

		return all;
	}
}
