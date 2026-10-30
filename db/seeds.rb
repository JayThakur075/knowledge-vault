# Demo data is intended for local development and automated tests only.
unless Rails.env.development? || Rails.env.test?
  puts "Skipping demo seed data outside development and test environments."
else
  demo_email = "demo@knowledgevault.local"
  demo_password = "VaultDemo123!"

  user = User.find_or_initialize_by(email_address: demo_email)
  user.password = demo_password
  user.password_confirmation = demo_password
  user.save!

  categories = %w[Ruby Rails JavaScript Databases Debugging Interviews].to_h do |name|
    [ name, user.categories.find_or_create_by!(name: name) ]
  end

  note_data = [
    {
      title: "Ruby Enumerable patterns",
      content: "Use map when transforming every item, select when keeping matching items, and reduce when building one result.\n\nExample:\n[1, 2, 3].map { |number| number * 2 }",
      note_type: "ruby",
      favorite: true,
      category: "Ruby",
      tags: %w[enumerable ruby]
    },
    {
      title: "Rails association basics",
      content: "belongs_to represents the child side of an association. has_many describes the collection owned by a parent. Use dependent: :destroy only when child records should be removed with the parent.",
      note_type: "rails",
      favorite: true,
      category: "Rails",
      tags: %w[associations rails]
    },
    {
      title: "Find slow SQL queries",
      content: "Start with the Rails development log, identify repeated queries, and run EXPLAIN on expensive SQL. Add an index only after checking the query pattern and write cost.",
      note_type: "sql",
      favorite: false,
      category: "Databases",
      tags: %w[database performance]
    },
    {
      title: "Debug a Rails request",
      content: "Follow the request through routes, controller callbacks, the action, model validations, and the rendered template. Check the server log for redirects, SQL, and exceptions.",
      note_type: "troubleshooting",
      favorite: false,
      category: "Debugging",
      tags: %w[debugging rails]
    },
    {
      title: "Interview: explain database indexes",
      content: "An index helps the database find rows without scanning the whole table. It speeds up matching reads but uses storage and adds work to inserts and updates.",
      note_type: "interview",
      favorite: true,
      category: "Interviews",
      tags: %w[interview-prep database]
    },
    {
      title: "JavaScript async and await",
      content: "async functions return promises. await pauses that function until a promise settles, making asynchronous code easier to read while keeping errors available through try/catch.",
      note_type: "javascript",
      favorite: false,
      category: "JavaScript",
      tags: %w[javascript async]
    }
  ]

  note_data.each do |attributes|
    tag_names = attributes.delete(:tags)
    category = categories.fetch(attributes.delete(:category))
    note = user.notes.find_or_initialize_by(title: attributes.fetch(:title))
    note.assign_attributes(attributes.merge(category: category))
    note.save!
    note.tags = tag_names.map { |name| user.tags.find_or_create_by!(name: name) }
  end

  link_data = [
    {
      title: "Ruby Documentation",
      url: "https://www.ruby-lang.org/en/documentation/",
      description: "Official Ruby language documentation and learning resources.",
      category: "Ruby",
      tags: %w[ruby documentation]
    },
    {
      title: "Rails Guides",
      url: "https://guides.rubyonrails.org/",
      description: "Official guides for Rails features and conventions.",
      category: "Rails",
      tags: %w[rails documentation]
    },
    {
      title: "MDN JavaScript Guide",
      url: "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide",
      description: "A detailed guide to JavaScript language features.",
      category: "JavaScript",
      tags: %w[javascript reference]
    },
    {
      title: "PostgreSQL Documentation",
      url: "https://www.postgresql.org/docs/",
      description: "Official PostgreSQL manuals and reference material.",
      category: "Databases",
      tags: %w[database documentation]
    }
  ]

  link_data.each do |attributes|
    tag_names = attributes.delete(:tags)
    category = categories.fetch(attributes.delete(:category))
    link = user.links.find_or_initialize_by(url: attributes.fetch(:url))
    link.assign_attributes(attributes.merge(category: category))
    link.save!
    link.tags = tag_names.map { |name| user.tags.find_or_create_by!(name: name) }
  end

  puts "Seeded Knowledge Vault demo account: #{demo_email}"
  puts "Demo password: #{demo_password}"
end
