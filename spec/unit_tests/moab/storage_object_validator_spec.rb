# frozen_string_literal: true

describe Moab::StorageObjectValidator do
  let(:druid) { 'xx000xx0000' }
  let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/xx/000/xx/0000/xx000xx0000' }
  let(:storage_obj) { Moab::StorageObject.new(druid, druid_path) }
  let(:storage_obj_validator) { described_class.new(storage_obj) }
  let(:error_list) { storage_obj_validator.validation_errors }

  before { described_class::IMPLICIT_DIRS = ['.', '..', '.keep'].freeze }

  after { described_class::IMPLICIT_DIRS = ['.', '..'].freeze }

  describe '#initialize' do
    it 'sets storage_obj_path' do
      expect(storage_obj_validator.storage_obj_path.to_s).to eq druid_path
    end
  end

  describe '#validation_errors' do
    it 'returns an Array of Hashes' do
      expect(error_list).to be_an(Array)
      expect(error_list).to all be_a(Hash)
    end

    describe 'for invalid_moab' do
      context 'with errors under version directory' do
        it 'has missing items' do
          expect(error_list).to include(described_class::MISSING_DIR => 'Missing directory: ["data", "manifests"] Version: v0001')
        end

        it 'has unexpected directory' do
          expect(error_list).to include(described_class::EXTRA_CHILD_DETECTED => 'Unexpected item in path: ["extra_dir"] Version: v0002')
        end

        it 'has unexpected file' do
          expect(error_list).to include(described_class::EXTRA_CHILD_DETECTED => 'Unexpected item in path: ["extra_file.txt"] Version: v0003')
        end

        it 'has missing data directory' do
          expect(error_list).to include(described_class::MISSING_DIR => 'Missing directory: ["data"] Version: v0004')
        end
      end

      context 'with errors under data directory' do
        it 'has unexpected file' do
          expect(error_list).to include(described_class::EXTRA_CHILD_DETECTED => 'Unexpected item in path: ["extra_file.txt"] Version: v0005')
        end

        it 'has missing metadata directory' do
          expect(error_list).to include(described_class::MISSING_DIR => 'Missing directory: ["metadata"] Version: v0006')
        end

        describe 'content directory' do
          it 'must contain files' do
            expect(error_list).to include(described_class::NO_FILES_IN_CONTENT_DIR => 'Version v0009: No files present in content dir')
          end

          it 'has errors for directories with disallowed names' do
            # vnnnn
            expect(error_list).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0011: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
            # manifests
            expect(error_list).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0012: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
            # data
            expect(error_list).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0013: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
            # content
            expect(error_list).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0014: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
            # metadata
            expect(error_list).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0015: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
          end

          context 'when multiple level sub directories' do
            let(:druid) { 'gg000gg0000' }
            let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/gg/000/gg/0000/gg000gg0000' }

            it 'does not return any error codes' do
              expect(error_list).to be_empty
            end
          end

          context 'with allow_content_subdirs argument' do
            context 'without subdirectories' do
              let(:druid) { 'bj102hs9687' }
              let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/bj/103/hs/9687/bj103hs9687' }

              it 'defaults to true and does not error' do
                expect(error_list).to be_empty
              end

              it 'explicitly set to true and does not error' do
                expect(storage_obj_validator.validation_errors(true)).to be_empty
              end

              it 'explicitly set to false and does not error' do
                expect(storage_obj_validator.validation_errors(false)).to be_empty
              end
            end

            context 'with non-forbidden subdirectories' do
              let(:druid) { 'gg000gg0000' }
              let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/gg/000/gg/0000/gg000gg0000' }

              it 'defaults to true and does not error' do
                expect(error_list).to be_empty
              end

              it 'explicitly set to true does not error' do
                expect(storage_obj_validator.validation_errors(true)).to be_empty
              end

              it 'explicitly set to false and errors' do
                expect(storage_obj_validator.validation_errors(false).size).to be > 0
              end
            end

            context 'with forbidden subdirectories' do
              it 'defaults to true and errors' do
                expect(error_list).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0011: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
              end

              it 'explicitly set to true and errors' do
                expect(storage_obj_validator.validation_errors(true)).to include(described_class::BAD_SUB_DIR_IN_CONTENT_DIR => 'Version v0011: content directory has forbidden sub-directory name: vnnnn or ["data", "manifests", "content", "metadata"]')
              end

              it 'explicitly set to false and errors' do
                expect(storage_obj_validator.validation_errors(false)).to include(described_class::CONTENT_SUB_DIRS_DETECTED => 'Version v0015: content directory should only contain files, not directories. Found directory: metadata')
              end
            end
          end
        end

        describe 'metadata directory' do
          it 'must only contain files' do
            expect(error_list).to include(described_class::METADATA_SUB_DIRS_DETECTED => 'Version v0008: metadata directory should only contain files, not directories. Found directory: test1')
          end

          it 'must contain files' do
            expect(error_list).to include(described_class::NO_FILES_IN_METADATA_DIR => 'Version v0010: No files present in metadata dir')
          end
        end
      end

      context 'with errors under manifest directory' do
        let(:druid) { 'cc000cc0000' }
        let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/cc/000/cc/0000/cc000cc0000' }

        it 'errors for missing signatureCatalog.xml' do
          expect(error_list).to include(described_class::NO_SIGNATURE_CATALOG => 'Version v0001: Missing signatureCatalog.xml')
        end

        it 'errors for missing manifestInventory.xml' do
          expect(error_list).to include(described_class::NO_MANIFEST_INVENTORY => 'Version v0002: Missing manifestInventory.xml')
        end

        it 'errors for missing signatureCatalog.xml or manifestInventory.xml' do
          expect(error_list).to include(described_class::NO_MANIFEST_INVENTORY => 'Version v0003: Missing manifestInventory.xml')
          expect(error_list).to include(described_class::NO_SIGNATURE_CATALOG => 'Version v0003: Missing signatureCatalog.xml')
        end

        it 'errors for missing files' do
          expect(error_list).to include(described_class::NO_FILES_IN_MANIFEST_DIR => 'Version v0004: No files present in manifest dir')
        end

        it 'errors for missing files when it has a folder' do
          expect(error_list).to include(described_class::NO_FILES_IN_MANIFEST_DIR => 'Version v0005: No files present in manifest dir')
        end
      end

      context 'with errors in version directories' do
        let(:druid) { 'yy000yy0000' }
        let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/yy/000/yy/0000/yy000yy0000' }

        it 'errors for non contiguous version directories' do
          expect(error_list).to include(described_class::TEST_OBJECT_VERSIONS_NOT_IN_ORDER => 'Should contain only sequential version directories. Current directories: ["v0001", "v0003", "v0004", "v0006"]')
        end
      end

      context 'when version directory name ends with letter' do
        let(:druid) { 'aa000aa0000' }
        let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/aa/000/aa/0000/aa000aa0000' }

        it 'errors' do
          expect(error_list).to include(described_class::VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format: v0001a")
        end
      end

      context 'with version sub directories' do
        let(:druid) { 'bb000bb0000' }
        let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/bb/000/bb/0000/bb000bb0000' }

        it 'errors for incorrect files' do
          files_present_err_msg = 'should not contain files; only the manifests and data directories'
          expect(error_list.size).to eq 7
          expect(error_list).to include(described_class::INCORRECT_DIR_CONTENTS => 'Incorrect items under v0001 directory')
          expect(error_list).to include(described_class::FILES_IN_VERSION_DIR => "Version directory v0001 #{files_present_err_msg}")
          expect(error_list).to include(described_class::FILES_IN_VERSION_DIR => "Version directory v0002 #{files_present_err_msg}")
          expect(error_list).to include(described_class::FILES_IN_VERSION_DIR => "Version directory v0003 #{files_present_err_msg}")
          expect(error_list).to include(described_class::EXTRA_CHILD_DETECTED => 'Unexpected item in path: ["test2.txt"] Version: v0004')
          expect(error_list).to include(described_class::INCORRECT_DIR_CONTENTS => 'Incorrect items under v0005 directory')
          expect(error_list).to include(described_class::FILES_IN_VERSION_DIR => "Version directory v0005 #{files_present_err_msg}")
        end
      end

      context 'when version directory name starts with letter' do
        let(:druid) { 'zz000zz0000' }
        let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/zz/000/zz/0000/zz000zz0000' }

        it 'errors if it does not start with v' do
          expect(error_list).to include(described_class::VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format: x0001")
        end
      end

      context 'when moab does not have the expected version sub dirs' do
        let(:druid) { 'ee000ee0000' }
        let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/ee/000/ee/0000/ee000ee0000' }

        it 'does not call #check_expected_data_sub_dirs' do
          expect(storage_obj_validator).not_to receive(:check_expected_data_sub_dirs)
          error_list
        end
      end
    end

    context 'with valid_moab' do
      let(:druid) { 'bj103hs9687' }
      let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/bj/103/hs/9687/bj103hs9687' }

      it 'returns true when moab is in correct format' do
        expect(error_list.empty?).to be true
      end

      describe 'manifest directory' do
        it 'may only have required files' do
          expect(error_list).to be_empty
        end
      end

      describe 'content directory' do
        it 'can be present' do
          expect(error_list).to be_empty
        end

        context 'when content dir is missing' do
          let(:druid) { 'mm000mm0000' }
          let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/mm/000/mm/0000/mm000mm0000' }

          it 'no error message' do
            expect(error_list).to be_empty
          end
        end

        context 'when content dir contains sub-dirs' do
          let(:druid) { 'nn000nn0000' }
          let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/nn/000/nn/0000/nn000nn0000' }

          it 'not verboten sub-dir name' do
            expect(error_list).to be_empty
          end
        end
      end
    end
  end
end
