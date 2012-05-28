# encoding: utf-8
require "digest"
require 'net/http'
require 'uri'

class Sms < ActiveRecord::Base
  class DeliveryError < Exception
  end
  
  attr_accessible :phone, :subject, :flash, :pl, :localid, :globalid, :status_id, :ok, :sent, :content, :isflash
  after_create :fill_localid
  validates_presence_of :phone, :content
  validates_length_of :content, :maximum => 70
  validates_length_of :phone, :is => 11, :allow_blank => false, :allow_nil => false
  validates_format_of :phone, :with => /\A^48[0-9]+\Z/, :message => "Wrong format of phone number. It should look like 48123123123"

  ERROR_CODES={
    0 => "Brak połączenia z smsc.",
    1 => "Brak autoryzacji, błędny login lub hasło.",
    2 => "Wiadomość została zakolejkowana do wysłania (oczekiwanie na potwierdzenie).",
    3 => "Wiadomość została wysłana do odbiorcy.",
    4 => "Wiadomość odebrana przez odbiorcę (potwierdzenie odbioru).",
    5 => "Błąd wiadomości.",
    6 => "Numer nieaktywny.",
    7 => "Błąd w dostarczeniu wiadomości.",
    8 => "Wiadomość odebrana przez sms center.",
    9 => "Błąd sieci GSM.",
    10 => "Wiadomość wygasła z powodu niemożliwości jej dostarczenia do odbiorcy.",
    11 => "Wiadomość została zakolejkowana do późniejszego wysłania.",
    12 => "Błąd providera, natychmiastowy kontakt z administratorem systemu.",
    103 => "Brak pola text w wiadomości lub pole text niepełne.",
    104 => "Błędnie wypełnione lub brak pola nadawcy.",
    105 => "Pole text jest za długie.",
    106 => "Błędny lub brak pola numer.",
    107 => "Błędny parametr type.",
    110 => "SMSC nie obsługuje danego typu wiadomości.",
    113 => "Pole text jest za długie.",
    201 => "Błąd systemu, natychmiastowy kontakt z administratorem systemu.",
    202 => "Niewystarczająca ilość kredytów na koncie.",
    203 => "Działanie niedozwolone, natychmiastowy kontakt z administratorem systemu.",
    204 => "Konto nieaktywne. Najprawdopodobniej zablokowane.",
    205 => "Sieć docelowa zablokowana.",
    301 => "Brak lub błędny identyfikator wiadomości.",
    500 => "Błędnie wypełnione pole nadawcy lub pole text za długie.",
    600 => "Brak kredytów na koncie premium dla podanego odbiorcy.",
    700 => "Brak potwierdzenia zapisu rekordu.",
    800 => "Deduplikator: Brak Zapisu Rekordu! Wiadomość powtórzona.",
    888 => "Restart zablokowanych smsów.",
    999 => "Zewnętrzna infrastruktura – status przejściowy."
  }

  def self.human_error_code(id)
    ERROR_CODES[id]
  end

  def status
      Sms.human_error_code self.status_id
  end

  def fill_localid
    self.update_attribute(:localid, self.created_at.to_i)
  end

  def status
    Sms.human_error_code self.status_id
  end

  def request_status
    url = URI.parse(APP_CONFIG["gatesms"]["send_url"])
    request = Net::HTTP::Post.new(url.path)
    request.body = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><report>
    <status timestamp="'+self.created_at.to_i.to_s+'" ok="true" globalid="'+self.globalid.to_s+'"/></report>'
    hash_body = Digest::MD5.hexdigest(request.body)
    hash = Digest::MD5.hexdigest("POST/sms_xmlapi.php#{hash_body}Accept:application/xml#{self.created_at.to_i.to_s}#{APP_CONFIG["gatesms"]["SecretKey"]}")
    request["X-GT-Auth"] = "#{APP_CONFIG["gatesms"]["KeyId"]}:" + hash
    request["X-GT-Timestamp"] = self.created_at.to_i.to_s
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["Accept"] = "application/xml"
    request["Expect"] = "100-continue"
    request["X-GT-Action"] = "GET STATUS"
    request.body="body=#{ERB::Util.url_encode(request.body)}"

    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)
    @html = Nokogiri::HTML(response.body)
    @html.search('status').each do |value|
      @status = value
    end
    if @status[:localid].to_i == self.localid
      self.update_attributes(:status_id=>@status.content.to_i, :globalid=>@status[:globalid].to_i, :sent=>@status[:ok].to_boolean)
    end
  end

  def send_message
    url = URI.parse(APP_CONFIG["gatesms"]["send_url"])
    request = Net::HTTP::Post.new(url.path)
    request.body = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><package test="'+APP_CONFIG["gatesms"]["test"].to_s+'">
    <msg pl="true" phone="'+self.phone+'" localid="'+self.localid.to_s+'" isflash="'+self.isflash.to_s+'" from="BrainBox">'+self.content.to_s+'</msg></package>'
    hash_body = Digest::MD5.hexdigest(request.body)
    hash = Digest::MD5.hexdigest("POST/sms_xmlapi.php#{hash_body}Accept:application/xml#{self.created_at.to_i.to_s}#{APP_CONFIG["gatesms"]["SecretKey"]}")
    request["X-GT-Auth"] = "#{APP_CONFIG["gatesms"]["KeyId"]}:" + hash
    request["X-GT-Timestamp"] = self.created_at.to_i.to_s
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["Accept"] = "application/xml"
    request["Expect"] = "100-continue"
    request.body="body=#{ERB::Util.url_encode(request.body)}"

    http = Net::HTTP.new(url.host, url.port)
    #http.set_debug_output $stderr
    response = http.request(request)
    @html = Nokogiri::HTML(response.body)
    @html.search('status').each do |value|
      @status = value
    end
    if @status[:localid].to_i == self.localid
      self.update_attributes(:status_id=>@status.content.to_i, :globalid=>@status[:globalid].to_i, :ok=>@status[:ok].to_boolean, :sent=>true)
    end
    
    raise DeliveryError unless [2, 3, 4].include?(@status.content.to_i)
  end

end
