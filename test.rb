require 'bundler'
Bundler.require

require 'active_record'
require 'minitest/autorun'
require 'logger'

$LOAD_PATH << File.join(__dir__, 'lib')

ActiveRecord::Base.establish_connection
ActiveRecord::Base.logger = Logger.new(STDOUT)

# DATABASE_URL=mysql2://mysql/database?pool=1 ruby test.rb

begin
  ActiveRecord::Tasks::DatabaseTasks.create_current('default_env')
rescue
end

ActiveRecord::Base.establish_connection

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def setup
    Post.destroy_all
    Comment.destroy_all
  end

  def test_association_stuff
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 1, post.comments.count
    assert_equal 1, Comment.count
    assert_equal post.id, Comment.first.post.id
  end

  def test_transaction
    assert_equal 0, Post.count

    Post.transaction do
      Post.create!
      Post.transaction(requires_new: true) do
        Post.create!

        raise ActiveRecord::Rollback
      end
    end

    assert_equal 1, Post.count
  end
end
