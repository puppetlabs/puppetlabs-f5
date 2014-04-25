require 'puppet/util/network_device/f5/device'

class Puppet::Provider::F5 < Puppet::Provider

  attr_accessor :device

  # convert 64bit Integer to F5 representation as {:high => 32bit, :low => 32bit}
  def to_32h(value)
    high = (value.to_i & 0xFFFFFFFF00000000) >> 32
    low  = value.to_i & 0xFFFFFFFF
    {:high => high, :low => low}
  end

  # convert F5 representation of 64 bit to string (since Puppet compares string rather than int)
  def to_64s(value)
    ((value[:high].to_i << 32) + value[:low].to_i).to_s
  end

  def network_address(value)
    value.sub(":" + value.split(':').last, '')
  end

  def network_port(value)
    port = value.split(':').last
    port.to_i unless port == '*'
    port
  end

  def self.transport
    if Facter.value(:url) then
      Puppet.debug "Puppet::Util::NetworkDevice::F5: connecting via facter url."
      @device ||= Puppet::Util::NetworkDevice::F5::Device.new(Facter.value(:url))
    else
      @device ||= Puppet::Util::NetworkDevice.current
      raise Puppet::Error, "Puppet::Util::NetworkDevice::F5: device not initialized #{caller.join("\n")}" unless @device
    end

    @tranport = @device.transport
  end

  def transport
    # this calls the class instance of self.transport instead of the object instance which causes an infinite loop.
    self.class.transport
  end

  def delete_file(filename)
    transport['System.ConfigSync'].delete_file(filename)
  end

  # The SOAP API have limits on transfer size, so we must process files in
  # chunks for download and upload.
  def download_file(filename)
    content = ''
    continue = true
    file_offset = 0
    # F5 recommended file processing chunk size.
    # http://devcentral.f5.com/Tutorials/TechTips/tabid/63/articleType/ArticleView/articleId/144/iControl-101--06--File-Transfer-APIs.aspx
    chunk_size = (64*1024)
    while (continue)
      chunk = transport['System.ConfigSync'].download_file(filename, chunk_size, file_offset).first

      content     += chunk.file_data
      file_offset += chunk_size

      continue = false if (chunk.chain_type == 'FILE_LAST') || (chunk.chain_type == 'FILE_FIRST_AND_LAST')
    end

    content
  end

  def upload_file(filename, content)
    continue = true
    chain_type = 'FILE_FIRST'
    file_offset = 0
    continue = true
    chunk_size = (64*1024)

    while (continue)
      if content.size <= chunk_size
        continue = false
        if file_offset == 0
          chain_type = 'FILE_FIRST_AND_LAST'
        else
          chain_type = 'FILE_LAST'
        end
      end

      chunk = content[0..chunk_size-1]
      transport['System.ConfigSync'].upload_file(filename, { :file_data => chunk, :chain_type => chain_type })

      file_offset += chunk_size
      chain_type = 'FILE_MIDDLE'
      content = content[chunk_size..content.size]
    end
  end

end
