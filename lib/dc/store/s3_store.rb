module DC
  module Store
    
    # An implementation of an AssetStore.
    module S3Store
      
      BUCKET_NAME = "dcloud_#{RAILS_ENV}"
      
      module ClassMethods
        def asset_root
          "http://s3.amazonaws.com/#{BUCKET_NAME}"
        end
      end
      
      def initialize
        @key, @secret = SECRETS['aws_access_key'], SECRETS['aws_secret_key']
      end
      
      def save(document, assets)
        save_file(assets[:pdf], document.pdf_path)
        save_file(assets[:thumbnail], document.thumbnail_path)
        save_file(document.text, document.full_text_path, false)
      end
      
      def destroy(document)
        bucket.delete_folder(document.path)
      end
      
      # Delete the assets store entirely.
      def delete_database!
        bucket.delete_folder("docs")
      end
      
      
      private 
      
      def bucket
        @s3 ||= RightAws::S3.new(@key, @secret, :protocol => 'http', :port => 80)
        @bucket ||= (@s3.bucket(BUCKET_NAME) || @s3.bucket(BUCKET_NAME, true))
      end
      
      # Saves a local file to a location on S3, and returns the public URL.
      def save_file(file, s3_path, path=true)
        file = path ? File.open(file) : file
        bucket.put(s3_path, file, {}, 'public-read')
        bucket.key(s3_path).public_link
      end
      
    end
    
  end
end