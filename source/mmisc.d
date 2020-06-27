//#remove NZD
//#I don't think this is used
//#messy
module mmisc;

import std.stdio;
import std.string;
import core.stdc.stdio;
import core.stdc.stdlib; // for malloc, there must be a better way - I think there is! :-) - :-( no I don't think there is so far other than Tango
import std.math;
import std.conv, std.string;

import money;

public {
//	alias float bdub; // detailed Book keeping Double (or real or float (having numbers seperated by a dot) 
	alias bdub = currency!("NZD", 2);
	alias wf = writefln;

	//Eg. " 0.9+ 0.1 +9.1+   0.9 \n ".getParseMonInputStr.writeln;
	auto getParseMonInputStr(in string input) {
		import money;

		alias NZD = currency!("NZD", 2);

		import std.conv : to;
		import std.string : replace, split, chomp;

		NZD total = 0;
		try {
			//auto zeroSpaces = input.replace(" ", "").chomp.to!string;
			//auto prices = zeroSpaces.split("+");
			//auto prices = input.replace(" ", "").chomp.split("+").to!string;
			/+
			foreach(price; input.replace(" ", "").chomp.split("+").to!string) {
				total += NZD(price);
			}
			+/
			import std.algorithm : each;

			input.replace(" ", "").chomp.split("+").each!(price => total += NZD(price.to!string));
		} catch(Exception e) {
			import std.stdio : writeln;

			writeln("Error with input, returning 0");

			return "0";
		}

		return total.to!string[0 .. $ - 3].to!string; //#remove NZD
	}

	//#renamed getline trying to compile on Linux
	string getLine(string dpre) {
		writeln("Depracated ", __FILE__, " ", __FUNCTION__);

		return ""; //input;
		//return s[0..std.c.string.strlen(s)]; // looky here, doesn't use an import?! - I don't understand it!
	}

	//#I don't think this is used
	string cashToString(bdub money,string paddingForCents="".dup) {
		string amount;
		if ( money<bdub(1) && money>bdub(0.99) ) {
			/* now this in this instance produces 88.999999 - or does it, I've changed real to float
			- Yes, it worked thanks to some help from the D community
				Update: what's this?
			*/
			/+
			bdub cents=money*100f;
			amount=format("%s%d",paddingForCents,cast(int)cents); // I put .89 and get 88c - narrowed it down, it's the money*100f thing
			+/
			amount="1"; // just stuck this in here
		}
		else
			amount=format("%0.2f",money);
		//#messy
		return format("%s%s%s", (money>=bdub(1.0) || money<=bdub(-1.0) ? "$" : ""), amount, money>=bdub(0.0) && money<bdub(1.0) ? "c" : "");
	}
} // public