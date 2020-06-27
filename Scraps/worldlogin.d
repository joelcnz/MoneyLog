//#login
	void loginMenu() {
		void menu() {
			/+
			std.stdio.writeln(
				"login Menu\n"
				"1. Login (and use)\n"
				"2. Sign up\n"
				"3. Erase login\n"
				"4. List handles\n"
				"5/q. Exit to OS");
				+/
		}
		string ip=['0'];
		bool done=false;
		do {
			menu();
			do {
				//ip[0]=getch;
				ip=getLine("");
			} while( ip.length==0 );
			ip=ip[0..1];
			switch( ip ) {
				case "1":
					if ( login() ) {
						std.stdio.writefln("You are logged in as %s",lgns[_loginIndex].handle);
						_acnt=new Account( lgns[_loginIndex].handle~".ini" );
					}
					else
						std.stdio.writefln("You are not logged in!");
				break;
				case "2":
					SignUp();
				break;
				case "3":
					eraseLogin();
				break;
				case "4":
					listLogins();
				break;
				case "5", "q": // exit
					std.stdio.writefln("Ok, Exiting...");
					done=true;
				break;
				default:
					std.stdio.writefln("Ok, try again!");
				break;
			}
		} while( ! done );
	}
	
	bool login() {
		std.stdio.writeln("\nList of handles to choose from:");
		foreach(i,l;lgns) {
			std.stdio.writefln("%d. %s",i+1,l.handle);
		}
		std.stdio.writeln("Enter handle to login with:");
		string strnum=getLine(""); // string number
		int lgn; // login number
		try {
			lgn=to!int(strnum)-1;
		} catch( Exception e ) {
			std.stdio.writeln("No, that wont do!");
			return false;
		}
		if ( lgn>=0 && lgn<lgns.length )
			_loginIndex=lgn;
		
		return true;
	}
	
	int getIndex(string handle) {
		foreach(i,l;lgns) {
			if ( l.handle==handle )
				return cast(int)i;
		}
		throw new Exception("In world.d getIndex missing handle"); // this will caught in main.d I think
	}

	void SignUp() {
		string han="".dup; //#I don't think you put a dup here at all, unless I wanted to change the lieral(sp) text
		bool done=false;
		do {
			done=true;
			//std.stdio.writef("Enter your handle: ");
			han=getLine("Enter your handle: ");
			if ( checkHandle(han)==true ) // if there is a handle with the same name
				std.stdio.writefln("Handle taken, try another"), done=false;
		} while( ! done ); // check to see if handle already taken
		Login login={han,"Ezra"};
		lgns~=login;
		saveLogin();
	}
	
	void eraseLogin() {
		string handle;
		//std.stdio.writef("Enter login handle to erase: ");
		handle=getLine("Enter login handle to erase: ");
		if ( checkHandle( handle,"","handle not listed, try again (try 4. List handles)" )==false )
			return;
		Login[] ls;
		foreach( i,l;lgns )
			if ( l.handle!=handle )
				ls~=l;
		lgns=ls;
		//if ( checkHandle(lgns[_loginIndex].handle)==false )
		//	_loginIndex=-1;
		saveLogin();
	}

	void listLogins() {
		std.stdio.writefln("\nList of handles:");
		foreach(l;lgns) {
			std.stdio.writefln("%s",l.handle);
		}
		std.stdio.writeln();
	}
	
	bool checkHandle(string handle, string iftrue="".dup,string iffalse="".dup) {
		foreach(l;lgns) {
			if ( l.handle==handle ) {
				if ( iftrue!="" )
					std.stdio.writefln(iftrue);
				return true;
			}
		}
		if ( iffalse!="" )
			std.stdio.writefln(iffalse);
		return false;
	}
	
	void loadLogins() {
		try {
			lgns.length=0;
			core.stdc.stdio.FILE* file = fopen(toStringz(HANDLE_FILE), "rb");
			//if ((file = FILE.fopen(std.string.toStringz(HANDLE_FILE), "rb")) == null)
			//{}
			//#temp
			version(none) {
				if (file is null) {
					writefln("\'%s\' can\'t be opened\n", HANDLE_FILE);
					return;
				}
			}
			int ver;
			fread( &ver, 1, 4, file); // 1 version
			int noli=0; // number of logins
			fread( &noli, 1, 4, file); // 2
			for( int i=0;i<noli;i++ ) {
				string handle="",password="";
				int handleNum=0;
				fread( &handleNum, 1, 4, file); // 3 number of handle letters
				for( int i2=0;i2<handleNum;i2++ ) {
					char l;
					fread( &l,1,1,file); // 4
					handle~=l;
				}
				int passwordLength=0;
				fread( &passwordLength, 1, 4, file); // 5
				for( int i3=0;i3<passwordLength;i3++ ) {
					char l;
					fread( &l,1,1,file); // 6
					password~=l;
				}
				Login l={handle,password};
				lgns~=l;
			}
			fclose( file );
		}
		catch ( Exception e ) {
			std.stdio.writefln("In world.loadLogins: %s",e.to!string());
			return;
		}
		std.stdio.writefln("Logins loaded");
	}
	
	void saveLogin() {
		try {
			FILE* file;
			if ((file = fopen(std.string.toStringz(HANDLE_FILE), "wb")) == null) {
				std.stdio.writefln("save: \'%s\' can\'t be opened\n", HANDLE_FILE);
				return;
			}
			int ver=1;
			fwrite( &ver, 1, 4, file); // 1 version
			int numoflogins=cast(int)lgns.length;
			fwrite( &numoflogins, 1, 4, file); // 2 number of logins
			foreach( l;lgns ) {
				int handleNum=cast(int)l.handle.length;
				fwrite( &handleNum, 1, 4, file); // 3 number of handle letters
				for( int i=0;i<handleNum;i++ )
					fwrite( &l.handle[i],1,1,file); // 4
				int passwordLength=cast(int)l.password.length;
				fwrite( &passwordLength, 1, 4, file); // 3 number of handle letters
				for( int i=0;i<passwordLength;i++ )
					fwrite( &l.password[i],1,1,file); // 4
			}
			fclose( file );
		}
		catch ( Exception e ) {
			std.stdio.writefln("In world.saveLogin: %s", e.toString());
			return;
		}
		std.stdio.writefln("Logins saved");
	}
