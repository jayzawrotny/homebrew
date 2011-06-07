require 'formula'

class Php <Formula
  @url='http://www.php.net/get/php-5.3.6.tar.bz2/from/www.php.net/mirror'
  @version='5.3.6'
  @homepage='http://php.net/'
  @md5='2286f5a82a6e8397955a0025c1c2ad98'

  depends_on 'jpeg'
  # depends_on 'freetype'
  # depends_on 'libpng'
  depends_on 'mcrypt'
  depends_on 'libiconv'
  # depends_on 'mysql'

  def options
    [
      ['--with-apache', "Install the Apache module"],
      ['--with-mysql',  "Build with MySQL (PDO) support"]
      # ['--with-pear', "Install PEAR PHP package manager after build"]
    ]
  end

  def caveats
    <<-END_CAVEATS
Pass --without-mysql to build without MySQL (PDO) support
    END_CAVEATS
  end

  def skip_clean? path
    path == bin+'php'
  end

  def install
    x11_dir = ENV.x11
    configure_args = [
      "--prefix=#{prefix}", "--disable-debug",
        "--mandir=#{man}",
        "--with-ldap=/usr",
        "--with-kerberos=/usr",
        "--enable-cli",
        "--enable-cgi",
        "--with-zlib-dir=/usr",
        "--enable-exif",
        "--enable-ftp",
        "--enable-mbstring",
        "--enable-mbregex",
        "--enable-sockets",
        "--with-iodbc=/usr",
        "--with-curl=/usr",
        "--with-config-file-path=#{etc}",
        "--sysconfdir=/private/etc",
        "--with-openssl=/usr",
        "--with-xmlrpc",
        "--with-xsl=/usr",
        "--with-pear=#{lib}/php",
        "--with-libxml-dir=/usr",
        "--with-iconv=#{Formula.factory('libiconv').prefix}",
        "--with-gd",
        "--with-jpeg-dir=#{Formula.factory('jpeg').prefix}",
        "--with-png-dir=#{x11_dir}",
        "--with-freetype-dir=#{x11_dir}",
        "--with-mcrypt=#{Formula.factory('mcrypt').prefix}"]

    if ARGV.include? '--without-mysql'
      puts "Not building MySQL (PDO) support"
    else
      puts "Building with MySQL (PDO) support. Pass --without-mysql if not needed."
      configure_args.push("--with-mysql-sock=/tmp/mysql",
      "--with-mysqli=#{HOMEBREW_PREFIX}/bin/mysql_config",
      "--with-mysql=#{HOMEBREW_PREFIX}/lib/mysql",
      "--with-pdo-mysql=#{HOMEBREW_PREFIX}/bin/mysql_config")
    end

    system "./configure", *configure_args

    system "make"
    system "make install"

    system "cp ./php.ini-development #{etc}/php.ini"

    # if ARGV.include? '--with-pear'
    #   system "curl http://pear.php.net/go-pear | #{prefix}/bin/php"
    # end
  end
end
