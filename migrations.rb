migration "create teh articles table" do
  database.create_table :articles do
    primary_key :id
    text        :title
    text        :body
    timestamp   :published_at
  end
end
