require 'cap_recipes/tasks/utilities.rb'

Capistrano::Configuration.instance(true).load do

=begin # Set these vars. 
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa.pub")]

  set :public_key, "id-KEYNAME" # the keypair to use for the instance
  set :cert_code, "CERT_CODE" # the code for the private key and for the certificate
  set :bundle_host, "DOMAIN.com" # the domain for the site
  set :account_id, "ACCOUNTID" # your account_id without dashes
  set :bundle_name, "BUNDLE" # the name of the bundle
  set :store_bucket, "BUCKET" # the name of the bucket
  set :access_key_id, "ACCESS KEY"
  set :access_secret_key, "SECRET KEY"
=end


  namespace :ec2 do
    desc "bundles up our innercalm image"
    task :bundle do
      utilities.with_credentials :user => 'root' do
        system("scp -i ~/.ec2/#{public_key} ~/.ec2/pk-#{cert_code}.pem ~/.ec2/cert-#{cert_code}.pem root@#{bundle_host}:/mnt")
        run "rm -f /mnt/#{bundle_name}"
        run "export PATH=/usr/bin:$PATH; ec2-bundle-vol -d /mnt -k /mnt/pk-#{cert_code}.pem -c /mnt/cert-#{cert_code}.pem -u #{account_id} -r i386 -p #{bundle_name}"
        run "ls -l /mnt/#{bundle_name}.*"
        run "export PATH=/usr/bin:$PATH; ec2-upload-bundle -b #{store_bucket} -m /mnt/#{bundle_name}.manifest.xml -a #{access_key_id} -s #{access_secret_key}"
        system("ec2-register #{store_bucket}/#{bundle_name}.manifest.xml")
      end
    end
  end
end
