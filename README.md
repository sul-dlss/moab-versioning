# moab-versioning

[![Build Status](https://travis-ci.org/sul-dlss/moab-versioning.svg?branch=master)](https://travis-ci.org/sul-dlss/moab-versioning)
[![Dependency Status](https://gemnasium.com/badges/github.com/sul-dlss/moab-versioning.svg)](https://gemnasium.com/github.com/sul-dlss/moab-versioning)
[![Gem Version](https://badge.fury.io/rb/moab-versioning.svg)](https://badge.fury.io/rb/moab-versioning)


## Usage

```
  require 'moab'
```

#### Configuration

```ruby
Moab::Config.configure do
  storage_roots ['storage_root_dir/except_last_part_of_path', 'second/storage_root_dir', 'and/so/on']
  storage_trunk 'the_last_piece_of_the_path_containing_objects'
  deposit_trunk 'presumably_last_piece_of_path_where_you_want_to_put_new_objects'
end
```

You can alternatively use this syntax:

```ruby
Moab::Config.storage_trunk = 'my directory'
```

#### Get Latest Version number

```ruby
current_version = StorageServices.current_version('666') # where 666 is the id
expect(current_version).to be_an_instance_of Integer
```

### Stanford-Specific

#### Configuration

```ruby
Moab::Config.configure do
  path_method :druid # valid values are :druid or :druid_tree
end
```

- when path_method is `:druid_tree`, expect this directory structure: 'jq/937/jp/0017/jq937jp0017'
- when path_method is `:druid`, expect this directory structure: 'jq937jp0017'

#### Get Latest Version number

Note the below has "Stanford::StorageServices", which can be necessary if there are druid paths

```ruby
current_version = Stanford::StorageServices.current_version('oo000oo0000') # where oo000oo0000 is the druid
expect(current_version).to be_an_instance_of Integer
```

## API Documentation

http://rubydoc.info/github/sul-dlss/moab-versioning/master/frames

[rdoc-image: (https://www.omniref.com/ruby/gems/moab-versioning.png)](https://www.omniref.com/ruby/gems/moab-versioning)

## Design Documentation

http://journal.code4lib.org/articles/8482

## Modules

### Serializer

**Serializer** is a module containing classes whose methods faciliate serialization
of data fields to various formats.  To obtain those benefits, a dependent class
should inherit from **Serializable** or **Manifest**
depending on whether XML serialization is required.

* **Serializable** = utility methods to faciliate serialization to Hash, JSON, or YAML
  * **Manifest** = adds methods for marshalling/unmarshalling data to a persistent XML file format

### Moab

**Moab** is a module that provides a distinctive namespace for the collection of classes it contains.

* **FileInventory** = container for recording information about a collection of related files
  * **FileGroup** [1..*] = subset allow segregation of content and metadata files
    * **FileManifestation** [1..*] = snapshot of a file's filesystem characteristics
      * **FileSignature** [1] = file fixity information
      * **FileInstance** [1..*] = filepath and timestamp of any physical file having that signature

* **SignatureCatalog** = lookup table containing a cumulative collection of all files ever ingested
  * **SignatureCatalogEntry** [1..*] = an row in the lookup table containing storage information about a single file
    * **FileSignature** [1] = file fixity information

* **FileInventoryDifference** = compares two **FileInventory** instances based on file signatures and pathnames
  * **FileGroupDifference** [1..*] = performs analysis and reports differences between two matching **FileGroup** objects
    * **FileGroupDifferenceSubset** [1..5] = collects a set of file-level differences of a give change type
      * **FileInstanceDifference** [1..*] = contains difference information at the file level
        * **FileSignature** [1..2] = contains the file signature(s) of two file instances being compared

* **VersionMetadata** = descriptive information about a digital object's versions
  * **VersionMetadataEntry** [1..*] = attributes of a digital object version
    * **VersionMetadataEvent** [1..*] = object version lifecycle events with timestamps

* **StorageObject** = represents a digital object's repository storage location and ingest/dissemination methods
  * **StorageObjectVersion** [1..*] = represents a version subdirectory within an object's home directory
    * **Bagger** [1] = utility for creating bagit packages for ingest or dissemination

### Stanford

**Stanford** is a module that isolates classes specific to the Stanford Digital Repository

* **Stanford::DorMetadata** = utility methods for interfacing with Stanford metadata files (esp contentMetadata)
  * **Stanford::ActiveFedoraObject** [1..*] = utility for extracting content or other information from a Fedora Instance
