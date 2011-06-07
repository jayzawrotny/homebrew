require 'formula'

class LighttpdDev < Formula
  head 'svn://svn.lighttpd.net/lighttpd/trunk', :using => :svn
  homepage 'http://www.lighttpd.net/'

  depends_on 'pkg-config'
  depends_on 'pcre'
  depends_on 'glib'

  def install
    args = ["--prefix=#{prefix}", "--sbindir=#{bin}",
            "--disable-dependency-tracking",
            "--with-openssl", "--with-ldap"]
    # We need to give autogen the directory of pkg.m4 from pkg-config
    system "ACLOCAL_FLAGS='-I #{HOMEBREW_PREFIX}/share/aclocal' ./autogen.sh"
    system "./configure", *args
    system "make"
    system "make install"

    # Working dir for lighttpd
    (var+'lighttpd').mkpath
    # Write startup file for lighttpd
    (prefix+'net.lighttpd.lighttpd.plist').write startup_plist
  end

  def patches
    {
      # Fixes building on Mac OS X - default source code does not build properly
      :p1 => 'http://gist.github.com/raw/445793/bfee5b8cc2317f4b3f44d32cf23133933708e031/0001-fix-lighttpd15-build-on-mac-os-x.patch'
    }
  end

  def caveats; <<-EOS.undent
    If this is your first install, automatically load on login with:
        cp #{prefix}/net.lighttpd.lighttpd.plist ~/Library/LaunchAgents
        launchctl load -w ~/Library/LaunchAgents/net.lighttpd.lighttpd.plist

    If this is an upgrade and you already have the net.lighttpd.lighttpd.plist loaded:
        launchctl unload -w ~/Library/LaunchAgents/net.lighttpd.lighttpd.plist
        cp #{prefix}/net.lighttpd.lighttpd.plist ~/Library/LaunchAgents
        launchctl load -w ~/Library/LaunchAgents/net.lighttpd.lighttpd.plist
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
      <string>net.lighttpd.lighttpd</string>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}/lighttpd</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{bin}/lighttpd</string>
        <string>-f#{etc}/lighttpd/lighttpd.conf</string>
        <string>-D</string>
      </array>
    </dict>
    </plist>
    EOPLIST
  end

end
