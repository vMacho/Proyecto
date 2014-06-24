class Quest extends Object;

var (Quest) int _id;
var (Quest) string _title;
var (Quest) string _description;
var (Quest) bool doIt;

function Quest( int id, string title, string description )
{
	_id 		 = id;
	_title 		 = title;
	_description = description;
}

DefaultProperties
{ 
	doIt = false;
}