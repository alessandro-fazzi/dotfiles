function gifplease -d "Converts MOV to GIF using ffmpeg and gifsicle"
  ffmpeg -i $argv -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=8 > (string replace -a ' ' _ "$argv.gif")
  set -l gif (string replace -a ' ' _ "$argv.gif")
  echo "👉 \"$gif\""
  open -na Safari "$gif"
end
