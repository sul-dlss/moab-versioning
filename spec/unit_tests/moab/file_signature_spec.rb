describe Moab::FileSignature do
  let(:title_v1_pathname) { @fixtures.join('data/jq937jp0017/v0001/content/title.jpg') }
  let(:title_v1_signature) { described_class.new.signature_from_file(title_v1_pathname) }
  let(:title_v2_signature) do
    title_v2_pathname = @fixtures.join('data/jq937jp0017/v0002/content/title.jpg')
    described_class.new.signature_from_file(title_v2_pathname)
  end
  let(:page1_v1_signature) do
    page1_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/page-1.jpg')
    described_class.new.signature_from_file(page1_v1_pathname)
  end
  let(:page1_v2_signature) do
    page1_v2_pathname = @fixtures.join('data/jq937jp0017/v0002/content/page-1.jpg')
    described_class.new.signature_from_file(page1_v2_pathname)
  end

  describe '.from_file' do
    it 'raises if unrecognized checksum requested' do
      expect { described_class.from_file('whatever', [:rot13]) }.to raise_exception(/Unrecognized algorithm/)
    end
    it 'computes all checksums by default' do
      sig = described_class.from_file(title_v1_pathname)
      expect(sig.md5).to eq '1a726cd7963bd6d3ceb10a8c353ec166'
      expect(sig.sha1).to eq '583220e0572640abcd3ddd97393d224e8053a6ad'
      expect(sig.sha256).to eq '8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5'
    end
    it 'only computes requested checksum(s)' do
      sig = described_class.from_file(title_v1_pathname, [:md5, :sha1])
      expect(sig.md5).to eq '1a726cd7963bd6d3ceb10a8c353ec166'
      expect(sig.sha1).to eq '583220e0572640abcd3ddd97393d224e8053a6ad'
      expect(sig.sha256).to be_nil
    end
  end

  specify '#initialize' do
    opts = {
      size: 75,
      md5: 'Test md5',
      sha1: 'Test sha1'
    }
    file_signature = described_class.new(opts)
    expect(file_signature.size).to eq opts[:size]
    expect(file_signature.md5).to eq opts[:md5]
    expect(file_signature.sha1).to eq opts[:sha1]
  end

  describe '#set_checksum' do
    let(:file_sig) { described_class.new }

    it 'known checksum types' do
      file_sig.set_checksum(:md5, '1a726cd7963bd6d3ceb10a8c353ec166')
      file_sig.set_checksum(:sha1, '583220e0572640abcd3ddd97393d224e8053a6ad')
      file_sig.set_checksum(:sha256, '8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5')
      expect(file_sig.checksums()).to eq(
        {
          md5: "1a726cd7963bd6d3ceb10a8c353ec166",
          sha1: "583220e0572640abcd3ddd97393d224e8053a6ad",
          sha256: "8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
        }
      )
    end
    it 'unknown checksum type' do
      expect { file_sig.set_checksum('xyz', 'dummy') }.to raise_exception(ArgumentError, /Unknown checksum type 'xyz'/)
    end
  end

  specify '#fixity' do
    expected_sig_fixity = {
      size: "40873",
      md5: "1a726cd7963bd6d3ceb10a8c353ec166",
      sha1: "583220e0572640abcd3ddd97393d224e8053a6ad",
      sha256: "8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
    }
    expect(title_v1_signature.fixity()).to eq expected_sig_fixity
  end

  specify '#checksums' do
    expected_checksums = {
      md5: "1a726cd7963bd6d3ceb10a8c353ec166",
      sha1: "583220e0572640abcd3ddd97393d224e8053a6ad",
      sha256: "8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
    }
    expect(title_v1_signature.checksums()).to eq expected_checksums
  end

  specify '#eql?' do
    expect(title_v1_signature.eql?(title_v2_signature)).to eq true
    expect(page1_v1_signature.eql?(page1_v2_signature)).to eq false
  end

  specify '#==' do
    expect(title_v1_signature == title_v2_signature).to eq true
    expect(page1_v1_signature == page1_v2_signature).to eq false
  end

  specify '#hash' do
    expect(title_v1_signature.hash).to be_kind_of Numeric
    expect(title_v1_signature.hash == title_v2_signature.hash).to eq true
    expect(page1_v1_signature.hash == page1_v2_signature.hash).to eq false
  end

  specify '#signature_from_file' do
    expect(title_v1_signature.size).to eq 40873
    expect(title_v1_signature.md5).to eq "1a726cd7963bd6d3ceb10a8c353ec166"
    expect(title_v1_signature.sha1).to eq "583220e0572640abcd3ddd97393d224e8053a6ad"
  end

  describe '#normalized_signature' do
    let(:page2_v1_pathname) { @packages.join('v0001/data/content/page-2.jpg') }
    let(:page2_fixity) do
      {
        size: "39450",
        md5: "82fc107c88446a3119a51a8663d1e955",
        sha1: "d0857baa307a2e9efff42467b5abd4e1cf40fcd5",
        sha256: "235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"
      }
    end

    specify 'when given all checksums' do
      fs = described_class.new(page2_fixity)
      signature = fs.normalized_signature(page2_v1_pathname)
      expect(signature.fixity).to eq(page2_fixity)
    end
    specify 'when given partial checksums' do
      fs = described_class.new(size: "39450", sha1: 'd0857baa307a2e9efff42467b5abd4e1cf40fcd5')
      signature = fs.normalized_signature(page2_v1_pathname)
      expect(signature.fixity).to eq(page2_fixity)
    end
    specify 'when given bad checksum' do
      fs = described_class.new(sha1: 'dummy')
      exp_err_regex = /Signature inconsistent between inventory and file/
      expect { fs.normalized_signature(page2_v1_pathname) }.to raise_exception(exp_err_regex)
    end
  end

  specify '.checksum_names_for_type' do
    expect(described_class.checksum_names_for_type).to eq(
      {
        md5: ["MD5"],
        sha1: ["SHA-1", "SHA1"],
        sha256: ["SHA-256", "SHA256"]
      }
    )
  end

  specify '.checksum_type_for_name' do
    expect(described_class.checksum_type_for_name).to eq(
      {
        "MD5" => :md5,
        "SHA1" => :sha1,
        "SHA-1" => :sha1,
        "SHA256" => :sha256,
        "SHA-256" => :sha256
      }
    )
  end
end
