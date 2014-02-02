# -*- encoding: UTF-8 -*-

def setup
  Groonga::Context.default_options = {encoding: :utf8}
  path = Pathname.new(__FILE__).dirname.join('db/njslyr.db')
  if path.exist?
    Groonga::Database.open(path.to_s)
  else
    Groonga::Database.create(path: path.to_s)
    define_schema()
  end
end

def define_schema
  Groonga::Schema.define do |schema|
    schema.create_table('Togetters', type: :array) do |table|
      table.short_text('title')
      table.short_text('url')
    end
    schema.create_table('Tweets', type: :array) do |table|
      table.reference('togetter', 'Togetters')
      table.short_text('text')
      table.short_text('url')
      table.time('created')
    end

    schema.create_table("Terms", {
      type: :patricia_trie,
      normalizer: :NormalizerAuto,
      default_tokenizer: 'TokenBigram',
    }) do |table|
      table.index('Tweets.text')
    end
  end
end

setup()
