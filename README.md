= moab-versioning

{<img src="https://travis-ci.org/sul-dlss/moab-versioning.svg?branch=master" alt="Build Status" />}[https://travis-ci.org/sul-dlss/moab-versioning]

== License

Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
All rights reserved.  See {file:LICENSE.rdoc} for details.

== API Documentation

http://rubydoc.info/github/sul-dlss/moab-versioning/master/frames

{rdoc-image:https://www.omniref.com/ruby/gems/moab-versioning.png}[https://www.omniref.com/ruby/gems/moab-versioning]

== Design Documentation

http://journal.code4lib.org/articles/8482

== Modules

=== Serializer

{Serializer} is a module containing classes whose methods faciliate serialization
of data fields to various formats.  To obtain those benefits, a dependent class
should inherit from {Serializable} or {Manifest}
depending on whether XML serialization is required.

* <b>{Serializable} = utility methods to faciliate serialization to Hash, JSON, or YAML</b>
  * {Manifest} = adds methods for marshalling/unmarshalling data to a persistent XML file format

=== Moab

{Moab} is a module that provides a distinctive namespace for the collection of classes it contains.

* <b>{FileInventory} = container for recording information about a collection of related files</b>
  * {FileGroup} [1..*] = subset allow segregation of content and metadata files
    * {FileManifestation} [1..*] = snapshot of a file's filesystem characteristics
      * {FileSignature} [1] = file fixity information
      * {FileInstance} [1..*] = filepath and timestamp of any physical file having that signature

* <b>{SignatureCatalog} = lookup table containing a cumulative collection of all files ever ingested</b>
  * {SignatureCatalogEntry} [1..*] = an row in the lookup table containing storage information about a single file
    * {FileSignature} [1] = file fixity information

* <b>{FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames</b>
  * {FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects
    * {FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type
      * {FileInstanceDifference} [1..*] = contains difference information at the file level
        * {FileSignature} [1..2] = contains the file signature(s) of two file instances being compared

* <b>{VersionMetadata} = descriptive information about a digital object's versions</b>
  * {VersionMetadataEntry} [1..*] = attributes of a digital object version
    * {VersionMetadataEvent} [1..*] = object version lifecycle events with timestamps

* <b>{StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods</b>
  * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
    * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination

=== Stanford

{Stanford} is a module that isolates classes specific to the Stanford Digital Repository

* <b>{Stanford::DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)</b>
  * {Stanford::ActiveFedoraObject} [1..*] = utility for extracting content or other information from a Fedora Instance

== Usage

Require the following:
  require 'moab'

=== Configuration

```ruby
Moab::Config.configure do
  storage_roots yer_first_storage_root_dir_except_last_part_of_path
  storage_trunk the_last_piece_of_the_path_containing_objects
  deposit_trunk presumably_last_piece_of_path_where_you_want_to_put_new_objects
  path_method :druid # part of Stanford::StorageRepository;  valid values are :druid or :druid_tree
end
```

==== Get Latest Version number

```ruby
current_version = StorageServices.current_version('666') # where 666 is the id
expect(current_version).to be_an_instance_of Integer
```


=== Stanford

==== Configuration

```ruby
Moab::Config.configure do
  path_method :druid # valid values are :druid or :druid_tree
end
```

- when path_method is :druid_tree, expect this directory structure: 'jq/937/jp/0017/jq937jp0017'
- when path_method is :druid, expect this directory structure: 'jq937jp0017'

==== Get Latest Version number

```ruby
current_version = Stanford::StorageServices.current_version('oo000oo0000') # where oo000oo0000 is the id
expect(current_version).to be_an_instance_of Integer
```
