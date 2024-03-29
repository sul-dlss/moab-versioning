# frozen_string_literal: true

describe Moab::FileInstance do
  let(:v1_base_directory) { fixtures_dir.join('data/jq937jp0017/v0001/content') }
  let(:v2_base_directory) { fixtures_dir.join('data/jq937jp0017/v0002/content') }
  let(:title_v1_instance) do
    title_v1_pathname = fixtures_dir.join('data/jq937jp0017/v0001/content/title.jpg')
    described_class.new.instance_from_file(title_v1_pathname, v1_base_directory)
  end
  let(:title_v2_instance) do
    title_v2_pathname = fixtures_dir.join('data/jq937jp0017/v0002/content/title.jpg')
    described_class.new.instance_from_file(title_v2_pathname, v2_base_directory)
  end
  let(:page1_v1_instance) do
    page1_v1_pathname = fixtures_dir.join('data/jq937jp0017/v0001/content/page-1.jpg')
    described_class.new.instance_from_file(page1_v1_pathname, v1_base_directory)
  end
  let(:page1_v2_instance) do
    page1_v2_pathname = fixtures_dir.join('data/jq937jp0017/v0002/content/page-1.jpg')
    described_class.new.instance_from_file(page1_v2_pathname, v2_base_directory)
  end

  it '#initialize' do
    opts = {
      path: temp_dir.join('path').to_s,
      datetime: 'Apr 18 21:51:31 UTC 2012'
    }
    file_instance = described_class.new(opts)
    expect(file_instance.path).to eq opts[:path]
    expect(file_instance.datetime).to eq '2012-04-18T21:51:31Z'
  end

  it '#datetime reformats as ISO8601 (UTC Z format)' do
    fi = described_class.new
    fi.datetime = 'Wed Apr 18 21:51:31 UTC 2012'
    expect(fi.datetime).to eq '2012-04-18T21:51:31Z'
  end

  it '#instance_from_file' do
    expect(title_v1_instance.path).to eq 'title.jpg'
    expect(title_v1_instance.datetime).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
  end

  it '#eql?' do
    expect(title_v1_instance.eql?(title_v2_instance)).to be true
    expect(page1_v1_instance.eql?(page1_v2_instance)).to be true
    expect(title_v1_instance.eql?(page1_v2_instance)).to be false
  end

  it '#==' do
    expect(title_v1_instance == title_v2_instance).to be true
    expect(page1_v1_instance == page1_v2_instance).to be true
    expect(title_v1_instance == page1_v2_instance).to be false
  end

  it '#hash' do
    expect(title_v1_instance.hash == title_v2_instance.hash).to be true
    expect(page1_v1_instance.hash == page1_v2_instance.hash).to be true
    expect(title_v1_instance.hash == page1_v2_instance.hash).to be false
  end
end
