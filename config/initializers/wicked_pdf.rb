
  if Rails.env.production?
    WickedPdf.config = {
      exe_path: Gem.bin_path("wkhtmltopdf-binary", "wkhtmltopdf")
    }
  else
    WickedPdf.config = {
      exe_path: "C:/Program Files/wkhtmltopdf/bin/wkhtmltopdf.exe"
    }
  end
