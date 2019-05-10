// Mean to scrap this - I guess I could put it in a class definition
module login;

struct Login {
	string handle;
	string password;
	// unused as follows:
	string fullName;
	string discription;
	/* don't know what I'm doing here - don't think this could do any thing*/
	void opCall(string handle0,string password0) {
		handle=handle0;
		password=password0;
	}
}
