require 'spec_helper'

describe WordnetPl::Sense do

  describe '#extract_definition' do
    let!(:importer) { WordnetPl::Sense.new }

    def test(source, expected)
      expect(
        importer.send(:extract_definition, source)
      ).to eq(expected)
    end

    it 'recognizes simple definition' do
      test(
        '##D:foobar.',
        'foobar'
      )
    end

    it 'ignores spaces' do
      test(
        '  ##D:  foobar  .  ',
        'foobar'
      )
    end

    it 'can end with [##' do
      test(
        '  ##D:  foobar . [## . ',
        'foobar'
      )
    end

    it 'can end with {##L:' do
      test(
        '  ##D:  foobar.  {##L: . ',
        'foobar'
      )
    end

    it 'can end with <#' do
      test(
        '  ##D:  foobar.  <# . ',
        'foobar'
      )
    end

    it 'properly recognizes some real-world example with many dots' do
      test(
        'NP ##D: postać biblijna, król Izraela od ok. 1010 p.n.e., poeta; najmłodszy syn Jessego z Betlejem, ojciec Salomona.',
        'postać biblijna, król Izraela od ok. 1010 p.n.e., poeta; najmłodszy syn Jessego z Betlejem, ojciec Salomona',
      )
    end


    it 'parses real-world example that means nothing' do
      test(
        '##K:  ##D: . [##P: ] {##L: }',
        nil
      )
    end

    it 'can deal with new lines' do
      test(
        "##K:  .\n##D: foobar\nfooz .\n [##P: ] {##L: }",
        "foobar\nfooz"
      )
    end

    it 'deals with another real-world example' do
      test(
        "##K: og. ##D: skrót/symbol złotego. {##L: http://pl.wikipedia.org/wiki/Złoty}",
        "skrót/symbol złotego"
      )
    end
  end

end
