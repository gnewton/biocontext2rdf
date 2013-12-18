biocontext2rdf
==============

Convert Biocontext Mysql to n3

Port of PHP program originally written by Alison Callahan, PhD student, Carleton university to JRuby.
Differences: some logic moved to external JSON map.


Dependencies
============
- JRuby (tested with `jruby 1.7.8 (1.9.3p392) 2013-11-14 0ce429e on Java HotSpot(TM) 64-Bit Server VM 1.7.0_25-b15 [linux-amd64]`)
- MySql JDBC driver needs to be in CLASSPATH
- dbi, rdf, digest/md5, jdbc/mysql; if these one or more of these are missing, JRuby will fail and complaing about them. 
Use `jruby -S gem install foobar` to install.
- `biocontext_mapping.json` must be in the cwd

Running
============
- Change the MySql userid and password in biocontext_rdfizer.rb 
- Make sure MySql JDBC jar file (included) is in CLASSPATH
- Assumes MySql database called 'events' on localhost, which has loaded export of biocontext http://biocontext.smith.man.ac.uk/data/events.tar.gz 

`jruby biocontext_rdfizer.rb`






