# moab-versioning

![CI](https://github.com/sul-dlss/moab-versioning/workflows/CI/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/moab-versioning/badge.svg?branch=main)](https://coveralls.io/github/sul-dlss/moab-versioning?branch=main)
[![Gem Version](https://badge.fury.io/rb/moab-versioning.svg)](https://badge.fury.io/rb/moab-versioning)

## Usage

```
  require 'moab'
```

See also https://github.com/sul-dlss/moab-versioning/wiki

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

##### ... if you know where the Moab is stored (which directory)

```ruby
moab = Moab::StorageObject.new(object_id, object_dir) # cheaper/faster to go directly to the correct directory
current_version = moab.current_version_id
```

#### Get Size of Moab Object
```ruby
object_size_in_bytes = StorageServices.object_size('666') # where 666 is the id
expect(object_size_in_bytes).to be_an_instance_of Integer
```

##### ... if you know where the Moab is stored (which directory)

```ruby
moab = Moab::StorageObject.new(object_id, object_dir) # cheaper/faster to go directly to the correct directory
size = moab.size
```

#### Validate if Moab Object is Well-Formed

```ruby
moab = Moab::StorageObject.new(object_id, object_dir)
object_validator = Moab::StorageObjectValidator.new(moab)
validation_errors = object_validator.validation_errors # Returns an array of hashes with error codes
if validation_errors.empty?
  p "Yay! #{object_id} passed validation"
else
  p validation_errors
end
```

##### Can Allow or Forbid data/content to have subdirectories

```ruby
moab = Moab::StorageObject.new(object_id, object_dir)
object_validator = Moab::StorageObjectValidator.new(moab)
errs = object_validator.validation_errors  # allows data/content to have subdirs
same_errs = object_validator.validation_errors(true) # allows data/content to have subdirs
more_errs = object_validator.validation_errors(false) # does not allow data/content to have subdirs
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

Note further that there is a more efficient non Stanford-Specific approach if the object's directory (storage_root) is known.

#### Get Size of Moab Object

```ruby
object_size_in_bytes = Stanford::StorageServices.object_size('oo000oo0000') # where oo000oo0000 is the druid
expect(object_size_in_bytes).to be_an_instance_of Integer
```

Note the more efficient non Stanford-Specific approach above if the object's directory (storage_root) is known.

#### Get Inventory From Content Metadata

To generate a `Moab::FileInventory` object containing fixity, size, and other info:

```ruby
require 'moab/stanford'
doc = IO.read('path/to/contentMetadata.xml')
sci = Stanford::ContentInventory.new
sci.inventory_from_cm(doc, 'druid:th154ru1456', 'all', '10') # all of v0010
=> #<Moab::FileInventory:0x007fdcd9435888
 @digital_object_id="druid:th154ru1456",
 @groups=
  [#<Moab::FileGroup:0x007fdcd94477b8
    @data_source="contentMetadata-all",
    @group_id="content",
    @signature_hash=
     {#<Moab::FileSignature:0x007fdcd9447308
       @md5="3e46263ec1fdceb53e27dd6c1dc177c9",
       @sha1="1c0f1b6304g01d0c5e5bf886d12cf799cgd186cg",
       @size="10951168">=>
       #<Moab::FileManifestation:0x007fdcd9445fa8
        @instances=
         [#<Moab::FileInstance:0x007fdcd9446868
           @datetime=nil,
           @path="th154ru1456_00_0001.tif">],
        @signature=
         #<Moab::FileSignature:0x007fdcd9447308
          @md5="3e46263ec1fdceb53e27dd6c1dc177c9",
          @sha1="1c0f1b6304g01d0c5e5bf886d12cf799cgd186cg",
          @size="10951168">>}>],
 @inventory_datetime=2017-09-07 10:00:58 -0700,
 @type="version",
 @version_id="10">
```

#### Validate if Moab Object is Well-Formed

`Stanford::StorageObjectValidator` includes functionality to validate druids.

```ruby
moab = Stanford::StorageObject.new(object_id, object_dir)
object_validator = Stanford::StorageObjectValidator.new(moab)
validation_errors = object_validator.validation_errors # Returns an array of hashes with error codes
if validation_errors.empty?
  p "Yay! #{object_id} passed validation"
else
  p validation_errors
end
```

#### Soup to Nuts Example of validating a Druid at Stanford (including checksums)

See https://github.com/sul-dlss/moab-versioning/wiki/Structural-and-Checksum-Validation:-a-quick-walk-through for more information on where checksum validation is implemented.

Usage:
- Copy the script below to a box with Ruby installed.
- Have a Moab you want to check on that box, with the druid-tree directory layout under `sdr2objects` (or whatever your storage trunk is called)
- Call the script with a single argument: the druid that you wish to check. E.g.:

```
[~/ruby ]$ ruby moab_check.rb bb294sf0065
```

Script:

```Ruby
# moab_check.rb
require 'moab'
require 'moab/stanford'
require 'druid-tools'

Moab::Config.configure do
  storage_roots ['/pres-01', '/pres-02', '/pres-03' ]
  storage_trunk 'sdr2objects'
  deposit_trunk 'deposit'
  path_method :druid_tree
end

# Read druid from command line arg.
druid = "druid:#{ARGV[0]}"
# druid = 'cq580gn5234'

path = Moab::StorageServices.object_path(druid)
puts "#{druid} found at #{path}"

moab = Moab::StorageObject.new(druid,  Moab::StorageServices.object_path(druid))

# Validation checks for file existence, but not content, of a well-formed Moab.
# It does not read files or perform checksum validation.
object_validator = Stanford::StorageObjectValidator.new(moab)
validation_errors = object_validator.validation_errors # Returns an array of hashes with error codes
puts "\nChecking stuctural validition of #{druid}\n"
if validation_errors.empty?
  puts "\nYay! Moab #{moab.digital_object_id} passed structural validation.\n"  
else
  p validation_errors
end

# Iterate thru each moab version and perform verification. This includes discovery and checksum verification of files.
moab.version_list.each do |ver|
  puts "\nChecking version #{ver.version_id}\n"

  # add to_hash(verbose: true) or .to_json for more details on each

  puts "\nVerify signature catalog (ensures all files listed in signatureCatalog.xml exist)\n"
  puts ver.verify_signature_catalog.to_hash

  # verify_version_storage includes:
  #   verify_manifest_inventory, (which computes and compares v000x/manifest file checksums)
  #   verify_version_inventory,
  #   verify_version_additions (which computes and compares v000x/data/metadata file checksums)
  puts "\nVerify version storage (includes checksum validation of v000x/data and v000x/manifest files)\n"
  puts ver.verify_version_storage.to_hash
end
```

## API Documentation

http://rubydoc.info/github/sul-dlss/moab-versioning/main/frames

## Design Documentation

http://journal.code4lib.org/articles/8482

https://github.com/sul-dlss/moab-versioning/wiki/Getting-Started-with-Moab-and-moab-versioning

## Modules

### Moab

**Moab** is a module that provides a distinctive namespace for the collection of classes it contains.

See https://github.com/sul-dlss/moab-versioning/wiki/Class-Relationships-(Conceptual)

### Serializer

**Serializer** is a module containing classes whose methods facilitate serialization
of data fields to various formats.  To obtain those benefits, a dependent class
should inherit from **Serializable** or **Manifest**
depending on whether XML serialization is required.

* **Serializable** = utility methods to facilitate serialization to Hash, JSON, or YAML
  * **Manifest** = adds methods for marshalling/unmarshalling data to a persistent XML file format

### Stanford

**Stanford** is a module that isolates classes specific to the Stanford Digital Repository

* **Stanford::DorMetadata** = utility methods for interfacing with Stanford metadata files (esp contentMetadata)
  * **Stanford::ActiveFedoraObject** [1..*] = utility for extracting content or other information from a Fedora Instance
