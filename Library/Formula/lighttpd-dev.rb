require 'formula'

class LighttpdDev <Formula
  head 'svn://svn.lighttpd.net/lighttpd/trunk'
  homepage 'http://www.lighttpd.net/'

  # depends_on 'pkg-config'
  # depends_on 'pcre'
  depends_on :subversion if MACOS_VERSION < 10.6
  
  def install
    args = ["--prefix=#{prefix}", "--disable-dependency-tracking", 
            "--with-openssl", "--with-ldap"]
    system "./autogen.sh" #, *args
    system "./configure", *args
    system "make"
    system "make install"
  end
  
  def patches
    {
      :p1 => ['http://localhost/homebrew/0001-fix-build-on-mac-os-x.patch']
    }
  end
  
end

if MACOS_VERSION < 10.6
  class SubversionDownloadStrategy
    def svn
      Formula.factory('subversion').bin+'svn'
    end
  end
end

