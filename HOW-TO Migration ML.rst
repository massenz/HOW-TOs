HOW-TO Build a ML dataset
=========================

:Author: Marco Massenzio (marco@rivermeadow.com)
:Created: 2013-12-11

Mongo queries
-------------

Find successful migrations::

    db.migration.find({"state":"success"},{_id:1, source:1})

from the list of ``source`` ``UUIDs`` (``BinData(3,"jzvkG1ErSuKQkrD8phxRhA==")``)
you can find the ``Source`` objects that succeeded::

    db.statefulmodel.find({"_id" : BinData(3,"jzvkG1ErSuKQkrD8phxRhA==")},
                          {"attributes" : 1})

**NOTE** this will change to ``source`` once my fix is in place

and finally the OS version that the successful migrations worked for::

    > db.source_attributes.find({_id: BinData(3,"4aVbSsWtTIKZdnWO0r5EGg==")}, {os:1})

    {
        "_id" : BinData(3,"4aVbSsWtTIKZdnWO0r5EGg=="),
        "os" : {
            "kernel" : "2.6.32-279.el6.x86_64",
            "vendor" : "CentOS",
            "patch_level" : "",
            "version" : "6.3",
            "release" : "6.3",
            "arch" : "x86_64",
            "desc" : "CentOS release 6.3 (Final)"
        }
    }

Repeat the same process with ``$ne: {"state": "success"}`` clause to find failed migrations
and associated OS types.


Using UUIDs instead of ObjectIDs
--------------------------------

Download UUID Helper utility for converting UUIDs::

    wget https://raw.github.com/mongodb/mongo-csharp-driver/master/uuidhelpers.js

run mongo shell with UUID Helper imported

    mongo --shell uuidhelpers.js

Find source by UUID::

    db.source.find({_id:PYUUID("c820a050-25a1-4c87-82c7-7f01bb68ccb1")}).pretty();

Find source by created date and show its id as string
 
    db.source.findOne({"created": ISODate("2013-12-20T04:25:12")})._id.toPYUUID();


Storing a copy of Mongo for later analysis
------------------------------------------

Connect to the remote host and save the data to an archive::

    $ ssh root@10.10.124.232
    # mongodump --out mongobkup/ --db phoenix
    # cd mongobkup
    # tar cvfz 20131211_phoenix_mongodump.tar.bgz phoenix
    # rm -rf phoenix
    # exit
    
On your local machine::

    $ scp root@10.10.124.232:./mongobkup/20131211_phoenix_mongodump.tar.bgz ~/
    $ tar xvfz 20131211_phoenix_mongodump.tar.bgz
    $ mongorestore phoenix/
    
will load all data to the same DB/collection as the original (**be careful** as this may corrupt
existing data).
