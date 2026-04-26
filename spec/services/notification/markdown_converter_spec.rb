# frozen_string_literal: true

RSpec.describe Notification::MarkdownConverter do
  describe '.to_html' do
    let(:cases) do
      {
        'Hello, *world*!' => 'Hello, <strong>world</strong>!',
        'Hello, _world_!' => 'Hello, <em>world</em>!',
        'Run `bundle install` first' => 'Run <code>bundle install</code> first',
        'See [site](https://e.com) please' => 'See <a href="https://e.com">site</a> please',
        "first line\nsecond line" => 'first line<br>second line',
        "a\nb\nc" => 'a<br>b<br>c',
        "*b* _i_ `c` [l](https://e.com)\nx" =>
          '<strong>b</strong> <em>i</em> <code>c</code> <a href="https://e.com">l</a><br>x',
        "*line1\nline2*" => '<strong>line1<br>line2</strong>',
        '*one* and *two*' => '<strong>one</strong> and <strong>two</strong>',
        'plain text without formatting' => 'plain text without formatting',
        '' => '',
        '[*bold*](https://e.com)' => '<a href="https://e.com"><strong>bold</strong></a>',
      }
    end

    it 'converts markdown text to HTML' do
      aggregate_failures do
        cases.each do |input, expected|
          expect(described_class.to_html(input)).to eq(expected)
        end
      end
    end
  end
end
