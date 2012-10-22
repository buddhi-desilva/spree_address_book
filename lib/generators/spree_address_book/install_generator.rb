module SpreeAddressBook
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def add_javascripts
        append_file "app/assets/javascripts/store/all.js", "//= require store/spree_address_book\n"
      end
      
      def add_stylesheets
        source_stylesheet = Rails.root.join('app', 'assets', 'stylesheets', 'store', 'all.css')
        destination_stylesheet = Rails.root.join('app', 'assets', 'stylesheets', 'store', 'all.css.scss')
        
        # If the files isn't an SASS file, we'll convert it into a SASS file
        unless File.exists?(destination_stylesheet)
          FileUtils.mv source_stylesheet, destination_stylesheet          
        end

        inject_into_file destination_stylesheet, "\n *= require store/index\n", :before => /\*\//, :verbose => true
      end
          
      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_address_book'
      end

      def run_migrations
         res = ask "Would you like to run the migrations now? [Y/n]"
         if res == "" || res.downcase == "y"
           run 'bundle exec rake db:migrate'
         else
           puts "Skiping rake db:migrate, don't forget to run it!"
         end
      end
    end
  end
end
