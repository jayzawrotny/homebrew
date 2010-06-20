require 'formula'

class LighttpdDev <Formula
  head 'svn://svn.lighttpd.net/lighttpd/trunk'
  homepage 'http://www.lighttpd.net/'

  depends_on 'pkg-config'
  depends_on 'pcre'
  depends_on 'glib'
  depends_on :subversion if MACOS_VERSION < 10.6
  
  def install
    args = ["--prefix=#{prefix}", "--disable-dependency-tracking", 
            "--with-openssl", "--with-ldap"]
    
    # Configuring our build. Basically it's just unwrapped autogen.sh script
    # provided by lighttpd, so we can tweak the config options        
    system "glibtoolize --copy --force"
    system "aclocal -I/usr/local/share/aclocal"
    system "autoheader"
    system "automake --add-missing --copy"
    system "autoconf"
    
    system "./configure", *args
    system "make"
    system "make install"
    
    (var+'lighttpd').mkpath
    (prefix+'com.lighttpd.plist').write startup_plist
  end
  
  def patches
    {
      :p1 => ['http://gist.github.com/raw/445793/HEAD']
    }
  end
  
  def caveats; <<-EOS.undent
    If this is your first install, automatically load on login with:
        cp #{prefix}/com.lighttpd.plist ~/Library/LaunchAgents
        launchctl load -w ~/Library/LaunchAgents/com.lighttpd.plist

    If this is an upgrade and you already have the com.lighttpd.plist loaded: 
        launchctl unload -w ~/Library/LaunchAgents/com.lighttpd.plist
        cp #{prefix}/com.lighttpd.plist ~/Library/LaunchAgents
        launchctl load -w ~/Library/LaunchAgents/com.lighttpd.plist
    EOS
  end
  
  def startup_plist; <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>com.lighttpd</string>
      <key>Program</key>
      <string>#{sbin}/lighttpd</string>
      <key>RunAtLoad</key>
      <true/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
      <key>WorkingDirectory</key>
      <string>#{var}/lighttpd</string>
    </dict>
    </plist>
    EOPLIST
  end
  
end

if MACOS_VERSION < 10.6
  class SubversionDownloadStrategy
    def svn
      Formula.factory('subversion').bin+'svn'
    end
  end
end

