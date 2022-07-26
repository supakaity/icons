function resize {
    local pattern="$1"
    local dim="$2"
    local dest="$3"

    if [[ ! -f $dest ]]; then
      convert "$pattern" \
        -alpha set -background transparent -gravity center \
        -resize "$dim"! \
        "$dest"
    fi
}

function overlay {
    local src="$1"
    local shape="$2"
    local dest="$3"
    local opts="$4"

    if [[ ! -f $dest ]]; then
      local pattern="assets/${shape}_overlay.png"
      local srcdim=$(identify -format '%Wx%H' "$src")
      local patdim=$(identify -format '%Wx%H' "$pattern")
      if [[ $patdim != $srcdim ]]; then
        local resized="temp/${shape}_overlay_${srcdim}.png"
        resize "$pattern" "$srcdim" "$resized"
        pattern="$resized"
      fi

      convert "${src}" -alpha set \
        "$pattern" -composite \
        -background transparent $opts \
        "$dest"
    fi
}

function wave {
  local shape="flag"
  local pattern="$1"
  local file="$2"

  local folder="dest/${shape}"
  local dest="${folder}/${file}_${shape}.png"

  if [[ ! -f $dest ]]; then
    echo "$file $shape"
    mkdir -p "$folder"

    convert "$pattern" -alpha set -background transparent -gravity center -resize 200x140! -wave -10x200 "temp/${file}-${shape}-wave.png"

    overlay "temp/${file}-${shape}-wave.png" "${shape}" "$dest" "-splice 5x5"
  else
    echo "$file $shape - skipped"
  fi
}

function flat {
  local shape="flat"
  local pattern="$1"
  local file="$2"

  local folder="dest/${shape}"
  local dest="${folder}/${file}_${shape}.png"

  if [[ ! -f $dest ]]; then
    echo "$file $shape"
    mkdir -p "$folder"

    convert "$pattern" -alpha set -background transparent -gravity center -resize 200x140! "$dest"
  else
    echo "$file $shape - skipped"
  fi
}

function colored {
  local shape="$1"
  local color="$2"
  local file="$3"

  local folder="dest/${shape}"
  local dest="${folder}/${file}_${shape}.png"
  
  if [[ ! -f $dest ]]; then
    echo "$file $shape"
    mkdir -p "$folder"

    convert assets/${shape}_mask.png \( +clone \) -alpha off -compose CopyOpacity -composite \
     -fill "$color" -colorize 100% "temp/${file}-${shape}-coloured.png"

    overlay "temp/${file}-${shape}-coloured.png" "${shape}" "$dest" "-splice 5x5"
  else
    echo "$file $shape - skipped"
  fi
}

function backed {
  local shape="$1"
  local pattern="$2"
  local file="$3"

  local folder="dest/${shape}"
  local dest="${folder}/${file}_${shape}.png"

  if [[ ! -f $dest ]]; then
    dim=$(identify -format '%Wx%H' assets/${shape}_mask.png)

    echo "$file $shape ($dim) from $pattern"
    mkdir -p "$folder"

    convert "$pattern" -alpha set -background transparent -gravity center -resize "$dim!" "temp/${file}-${shape}-resized.png"
    
    convert "assets/${shape}_mask.png" \( +clone \) -alpha off -compose CopyOpacity -composite \
    "temp/${file}-${shape}-resized.png" -compose src-in -composite "temp/${file}-${shape}-masked.png"
    
    overlay "temp/${file}-${shape}-masked.png" "$shape" "temp/${file}-${shape}-overlaid.png" \
      "-splice 5x5"
    
    #convert "temp/${file}-${shape}-masked.png" -alpha set -background transparent \
    # "assets/${shape}_overlay.png" -composite \
    # -splice 5x5 \
    # "temp/${file}-${shape}-overlaid.png"

    cp "temp/${file}-${shape}-overlaid.png" "$dest"
  else
    echo "$file $shape - skipped"
  fi
}
