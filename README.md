CSVManipulator
==============

CSVManipulator was started because I needed to work with CSV files often, if only to remove a column or to sort the file, and using Numbers (or other office applications) is just too clumsy for simple stuff like that.

It's very unfinished but many things work, I'm putting it here due to low activity from my side on the project.


Features
--------

* Open CSV, TSV (and potentially any-SV) files
* Save as CSV
* Add, remove, rearrange columns
* Add, remove, sort rows
* Change cell data (currently everything is treated as NSString)
* Undo
* Perform math operations on columns, e.g. write the result from `col_a` + `col_b` into a third column
* Export to various formats which the user can create. Predefined formats include CSV, XML, SQL, LaTeX and MediaWiki (Wikipedia) tables.


Exporting
---------

The application contains a potentially powerful but unfinished export format creator. It lets you define how you want your data exported in a very flexible way, take a look at the predefined formats (XML, SQL, LaTeX) and how they are implemented.
